package com.sms.servlet;

import com.sms.dao.ClazzDao;
import com.sms.dao.MajorDao;
import com.sms.dao.StudentDao;
import com.sms.dao.UserDao;
import com.sms.entity.Clazz;
import com.sms.entity.User;
import com.sms.util.DataAccessException;
import com.sms.util.WebUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 班级管理。
 */
public class ClazzServlet extends HttpServlet {

    private final ClazzDao clazzDao = new ClazzDao();
    private final MajorDao majorDao = new MajorDao();
    private final UserDao userDao = new UserDao();
    private final StudentDao studentDao = new StudentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = WebUtil.trim(req.getParameter("action"));
        if ("toAdd".equals(action)) {
            if (!requireAdmin(req, resp)) {
                return;
            }
            showForm(req, resp, 0);
        } else if ("toEdit".equals(action)) {
            if (!requireAdmin(req, resp)) {
                return;
            }
            showForm(req, resp, WebUtil.intValue(req.getParameter("id"), 0));
        } else {
            list(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = WebUtil.trim(req.getParameter("action"));
        if ("save".equals(action)) {
            save(req, resp);
        } else if ("delete".equals(action)) {
            delete(req, resp);
        } else {
            WebUtil.redirect(req, resp, "/clazz");
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("clazzes", clazzDao.listAll());
        req.setAttribute("activeNav", "clazz");
        req.setAttribute("pageTitle", "班级管理");
        req.getRequestDispatcher("/WEB-INF/views/clazz-list.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, int id)
            throws ServletException, IOException {
        Clazz clazz = null;
        if (id > 0) {
            clazz = clazzDao.findById(id);
            if (clazz == null) {
                WebUtil.flash(req, "error", "班级不存在或已被删除");
                WebUtil.redirect(req, resp, "/clazz");
                return;
            }
        }
        req.setAttribute("clazz", clazz);
        req.setAttribute("mode", clazz == null ? "add" : "edit");
        req.setAttribute("majors", majorDao.listAll());
        req.setAttribute("teachers", userDao.listTeachers());
        req.setAttribute("activeNav", "clazz");
        req.setAttribute("pageTitle", clazz == null ? "新增班级" : "编辑班级");
        req.getRequestDispatcher("/WEB-INF/views/clazz-form.jsp").forward(req, resp);
    }

    private void save(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireAdmin(req, resp)) {
            return;
        }
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Clazz clazz = new Clazz();
        clazz.setId(id);
        clazz.setCode(WebUtil.trim(req.getParameter("code")).toUpperCase());
        clazz.setName(WebUtil.trim(req.getParameter("name")));
        clazz.setMajorId(WebUtil.intValue(req.getParameter("majorId"), 0));
        clazz.setGradeYear(WebUtil.intValue(req.getParameter("gradeYear"), 0));
        clazz.setHeadTeacherId(WebUtil.intOrNull(req.getParameter("headTeacherId")));

        Map<String, String> errors = new LinkedHashMap<>();
        if (clazz.getCode().isEmpty() || clazz.getCode().length() > 20) {
            errors.put("code", "请输入 1-20 位班级代码");
        } else if (clazzDao.existsByCode(clazz.getCode(), id == 0 ? null : id)) {
            errors.put("code", "该班级代码已存在");
        }
        if (clazz.getName().isEmpty()) {
            errors.put("name", "请输入班级名称");
        }
        if (clazz.getMajorId() <= 0 || majorDao.findById(clazz.getMajorId()) == null) {
            errors.put("majorId", "请选择所属专业");
        }
        if (clazz.getGradeYear() < 2000 || clazz.getGradeYear() > 2100) {
            errors.put("gradeYear", "请输入有效的年级年份");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.setAttribute("clazz", clazz);
            req.setAttribute("mode", id == 0 ? "add" : "edit");
            req.setAttribute("majors", majorDao.listAll());
            req.setAttribute("teachers", userDao.listTeachers());
            req.setAttribute("activeNav", "clazz");
            req.setAttribute("pageTitle", id == 0 ? "新增班级" : "编辑班级");
            req.getRequestDispatcher("/WEB-INF/views/clazz-form.jsp").forward(req, resp);
            return;
        }

        try {
            if (id == 0) {
                clazzDao.insert(clazz);
                WebUtil.flash(req, "success", "班级 " + clazz.getName() + " 已创建");
            } else {
                clazzDao.update(clazz);
                WebUtil.flash(req, "success", "班级 " + clazz.getName() + " 已更新");
            }
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "保存失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/clazz");
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!requireAdmin(req, resp)) {
            return;
        }
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Clazz clazz = clazzDao.findById(id);
        if (clazz == null) {
            WebUtil.flash(req, "error", "班级不存在或已被删除");
            WebUtil.redirect(req, resp, "/clazz");
            return;
        }
        int count = studentDao.countByClazz(id);
        if (count > 0) {
            WebUtil.flash(req, "error", "班级「" + clazz.getName() + "」下还有 " + count + " 名学生，不能删除");
            WebUtil.redirect(req, resp, "/clazz");
            return;
        }
        try {
            clazzDao.delete(id);
            WebUtil.flash(req, "success", "班级 " + clazz.getName() + " 已删除");
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "删除失败：该班级仍被其他数据引用");
        }
        WebUtil.redirect(req, resp, "/clazz");
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
