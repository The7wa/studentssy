package com.sms.servlet;

import com.sms.dao.ScoreDao;
import com.sms.dao.StudentDao;
import com.sms.dao.UserDao;
import com.sms.entity.Student;
import com.sms.entity.User;
import com.sms.util.DataAccessException;
import com.sms.util.PasswordUtil;
import com.sms.util.WebUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * 个人中心：查看资料、修改联系方式、修改密码。
 */
public class ProfileServlet extends HttpServlet {

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private final UserDao userDao = new UserDao();
    private final StudentDao studentDao = new StudentDao();
    private final ScoreDao scoreDao = new ScoreDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        show(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User sessionUser = (User) req.getSession().getAttribute("loginUser");
        if (sessionUser == null) {
            WebUtil.redirect(req, resp, "/login.jsp");
            return;
        }
        String action = WebUtil.trim(req.getParameter("action"));
        if ("password".equals(action)) {
            updatePassword(req, resp, sessionUser);
        } else {
            updateProfile(req, resp, sessionUser);
        }
    }

    private void show(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User sessionUser = (User) req.getSession().getAttribute("loginUser");
        User user = userDao.findById(sessionUser.getId());
        if (user != null) {
            user.setPassword(null);
            req.getSession().setAttribute("loginUser", user);
        } else {
            user = sessionUser;
        }
        req.setAttribute("user", user);
        if (user.isStudent()) {
            Student student = studentDao.findByUserId(user.getId());
            req.setAttribute("student", student);
            if (student != null) {
                req.setAttribute("avgScore", scoreDao.avgByStudent(student.getId()));
                req.setAttribute("rank", scoreDao.classRank(student.getId()));
                req.setAttribute("classSize", scoreDao.classSize(student.getId()));
            }
        }
        req.setAttribute("activeNav", "profile");
        req.setAttribute("pageTitle", "个人中心");
        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp, User sessionUser)
            throws IOException {
        String phone = WebUtil.trim(req.getParameter("phone"));
        String email = WebUtil.trim(req.getParameter("email"));
        Map<String, String> errors = new LinkedHashMap<>();
        if (!email.isEmpty() && !EMAIL_PATTERN.matcher(email).matches()) {
            errors.put("email", "邮箱格式不正确");
        }
        if (!phone.isEmpty() && !phone.matches("^[0-9+\\- ]{6,20}$")) {
            errors.put("phone", "手机号格式不正确");
        }
        if (!errors.isEmpty()) {
            WebUtil.flash(req, "error", "保存失败：" + errors.values().iterator().next());
            WebUtil.redirect(req, resp, "/profile");
            return;
        }
        try {
            userDao.updateProfile(sessionUser.getId(), phone, email);
            sessionUser.setPhone(phone);
            sessionUser.setEmail(email);
            req.getSession().setAttribute("loginUser", sessionUser);
            WebUtil.flash(req, "success", "联系方式已更新");
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "保存失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/profile");
    }

    private void updatePassword(HttpServletRequest req, HttpServletResponse resp, User sessionUser)
            throws IOException {
        String oldPassword = req.getParameter("oldPassword") == null ? "" : req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword") == null ? "" : req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword") == null
                ? "" : req.getParameter("confirmPassword");

        User dbUser = userDao.findById(sessionUser.getId());
        if (dbUser == null) {
            WebUtil.flash(req, "error", "账号不存在，请重新登录");
            WebUtil.redirect(req, resp, "/login.jsp");
            return;
        }
        if (!PasswordUtil.verify(oldPassword, dbUser.getPassword())) {
            WebUtil.flash(req, "error", "原密码不正确");
            WebUtil.redirect(req, resp, "/profile");
            return;
        }
        if (newPassword.length() < 6 || newPassword.length() > 32) {
            WebUtil.flash(req, "error", "新密码长度需为 6-32 位");
            WebUtil.redirect(req, resp, "/profile");
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            WebUtil.flash(req, "error", "两次输入的新密码不一致");
            WebUtil.redirect(req, resp, "/profile");
            return;
        }
        try {
            userDao.updatePassword(sessionUser.getId(), PasswordUtil.hash(newPassword));
            WebUtil.flash(req, "success", "密码修改成功，下次登录请使用新密码");
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "修改密码失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/profile");
    }
}
