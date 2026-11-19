package com.sms.servlet;

import com.sms.dao.StudentDao;
import com.sms.dao.UserDao;
import com.sms.entity.Page;
import com.sms.entity.Student;
import com.sms.entity.User;
import com.sms.util.Constants;
import com.sms.util.DataAccessException;
import com.sms.util.PasswordUtil;
import com.sms.util.WebUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * 用户管理（仅管理员）：列表、新增、编辑、重置密码、启用/停用、删除。
 */
public class UserServlet extends HttpServlet {

    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9_]{3,30}$");
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final List<String> ROLES =
            Arrays.asList(Constants.ROLE_ADMIN, Constants.ROLE_TEACHER, Constants.ROLE_STUDENT);

    private final UserDao userDao = new UserDao();
    private final StudentDao studentDao = new StudentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireAdmin(req, resp)) {
            return;
        }
        String action = WebUtil.trim(req.getParameter("action"));
        if ("toAdd".equals(action)) {
            showForm(req, resp, 0);
        } else if ("toEdit".equals(action)) {
            showForm(req, resp, WebUtil.intValue(req.getParameter("id"), 0));
        } else {
            list(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireAdmin(req, resp)) {
            return;
        }
        req.setCharacterEncoding("UTF-8");
        String action = WebUtil.trim(req.getParameter("action"));
        switch (action) {
            case "save":
                save(req, resp);
                break;
            case "delete":
                delete(req, resp);
                break;
            case "reset":
                reset(req, resp);
                break;
            case "toggle":
                toggle(req, resp);
                break;
            default:
                WebUtil.redirect(req, resp, "/user");
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String role = WebUtil.trim(req.getParameter("role"));
        String keyword = WebUtil.trim(req.getParameter("keyword"));
        int page = WebUtil.page(req.getParameter("page"));
        int total = userDao.count(role, keyword);
        int totalPages = Math.max(1, (total + Constants.PAGE_SIZE - 1) / Constants.PAGE_SIZE);
        if (page > totalPages) {
            page = totalPages;
        }
        List<User> users = userDao.list(role, keyword, (page - 1) * Constants.PAGE_SIZE, Constants.PAGE_SIZE);

        req.setAttribute("page", new Page<>(users, page, Constants.PAGE_SIZE, total));
        req.setAttribute("role", role);
        req.setAttribute("keyword", keyword);
        req.setAttribute("roles", ROLES);
        req.setAttribute("activeNav", "user");
        req.setAttribute("pageTitle", "用户管理");
        req.getRequestDispatcher("/WEB-INF/views/user-list.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, int id)
            throws ServletException, IOException {
        User user = null;
        if (id > 0) {
            user = userDao.findById(id);
            if (user == null) {
                WebUtil.flash(req, "error", "用户不存在或已被删除");
                WebUtil.redirect(req, resp, "/user");
                return;
            }
        }
        req.setAttribute("user", user);
        req.setAttribute("mode", user == null ? "add" : "edit");
        req.setAttribute("roles", ROLES);
        req.setAttribute("activeNav", "user");
        req.setAttribute("pageTitle", user == null ? "新增用户" : "编辑用户");
        req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
    }

    private void save(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        String username = WebUtil.trim(req.getParameter("username"));
        String realName = WebUtil.trim(req.getParameter("realName"));
        String role = WebUtil.trim(req.getParameter("role"));
        String phone = WebUtil.trim(req.getParameter("phone"));
        String email = WebUtil.trim(req.getParameter("email"));
        int status = WebUtil.intValue(req.getParameter("status"), 1);
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");

        User user = new User();
        user.setId(id);
        user.setUsername(id == 0 ? username : null);
        user.setRealName(realName);
        user.setRole(role);
        user.setPhone(phone);
        user.setEmail(email);
        user.setStatus(status);

        User current = (User) req.getSession().getAttribute("loginUser");
        Map<String, String> errors = new LinkedHashMap<>();
        if (id == 0) {
            if (!USERNAME_PATTERN.matcher(username).matches()) {
                errors.put("username", "用户名需为 3-30 位字母、数字或下划线");
            } else if (userDao.existsByUsername(username, null)) {
                errors.put("username", "该用户名已存在");
            }
        }
        if (realName.isEmpty()) {
            errors.put("realName", "请输入姓名");
        }
        if (!ROLES.contains(role)) {
            errors.put("role", "请选择角色");
        }
        if (status != 0 && status != 1) {
            status = 1;
        }
        if (!email.isEmpty() && !EMAIL_PATTERN.matcher(email).matches()) {
            errors.put("email", "邮箱格式不正确");
        }
        if (id == 0 && (password.length() < 6 || password.length() > 32)) {
            errors.put("password", "密码长度需为 6-32 位");
        }
        if (id > 0 && current != null && current.getId() == id) {
            if (!Constants.ROLE_ADMIN.equals(role)) {
                errors.put("role", "不能修改自己的管理员角色");
            }
            if (status != 1) {
                errors.put("status", "不能停用自己的账号");
            }
        }

        if (!errors.isEmpty()) {
            user.setStatus(status);
            req.setAttribute("errors", errors);
            req.setAttribute("user", user);
            req.setAttribute("mode", id == 0 ? "add" : "edit");
            req.setAttribute("roles", ROLES);
            req.setAttribute("activeNav", "user");
            req.setAttribute("pageTitle", id == 0 ? "新增用户" : "编辑用户");
            req.getRequestDispatcher("/WEB-INF/views/user-form.jsp").forward(req, resp);
            return;
        }

        try {
            if (id == 0) {
                user.setPassword(PasswordUtil.hash(password));
                userDao.insert(user);
                WebUtil.flash(req, "success", "用户 " + realName + " 已创建");
            } else {
                userDao.update(user);
                WebUtil.flash(req, "success", "用户 " + realName + " 已更新");
            }
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "保存失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/user");
    }

    private void reset(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        User user = userDao.findById(id);
        if (user == null) {
            WebUtil.flash(req, "error", "用户不存在");
        } else {
            userDao.updatePassword(id, PasswordUtil.hash(Constants.DEFAULT_PASSWORD));
            WebUtil.flash(req, "success", "已将 " + user.getDisplayName() + " 的密码重置为 123456");
        }
        WebUtil.redirect(req, resp, "/user");
    }

    private void toggle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        User current = (User) req.getSession().getAttribute("loginUser");
        if (current != null && current.getId() == id) {
            WebUtil.flash(req, "error", "不能停用自己的账号");
            WebUtil.redirect(req, resp, "/user");
            return;
        }
        User user = userDao.findById(id);
        if (user == null) {
            WebUtil.flash(req, "error", "用户不存在");
        } else {
            int next = user.isEnabled() ? 0 : 1;
            userDao.updateStatus(id, next);
            WebUtil.flash(req, "success", user.getDisplayName() + (next == 1 ? " 已启用" : " 已停用"));
        }
        WebUtil.redirect(req, resp, "/user");
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        User current = (User) req.getSession().getAttribute("loginUser");
        if (current != null && current.getId() == id) {
            WebUtil.flash(req, "error", "不能删除当前登录的账号");
            WebUtil.redirect(req, resp, "/user");
            return;
        }
        User user = userDao.findById(id);
        if (user == null) {
            WebUtil.flash(req, "error", "用户不存在或已被删除");
            WebUtil.redirect(req, resp, "/user");
            return;
        }
        if (user.isAdmin() && userDao.countByRole(Constants.ROLE_ADMIN) <= 1) {
            WebUtil.flash(req, "error", "系统至少需要保留一个管理员账号");
            WebUtil.redirect(req, resp, "/user");
            return;
        }
        Student linked = studentDao.findByUserId(id);
        if (linked != null) {
            WebUtil.flash(req, "error", "该账号关联学生「" + linked.getName() + "」，请先在学生管理中删除该学生");
            WebUtil.redirect(req, resp, "/user");
            return;
        }
        try {
            userDao.delete(id);
            WebUtil.flash(req, "success", "用户 " + user.getDisplayName() + " 已删除");
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "删除失败：该用户仍被课程或班级引用");
        }
        WebUtil.redirect(req, resp, "/user");
    }

    private boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute("loginUser");
        if (user == null || !user.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        return true;
    }
}
