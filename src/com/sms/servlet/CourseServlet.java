package com.sms.servlet;

import com.sms.dao.CourseDao;
import com.sms.dao.UserDao;
import com.sms.entity.Course;
import com.sms.entity.User;
import com.sms.util.Constants;
import com.sms.util.DataAccessException;
import com.sms.util.WebUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 课程管理。
 */
public class CourseServlet extends HttpServlet {

    private final CourseDao courseDao = new CourseDao();
    private final UserDao userDao = new UserDao();

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
            WebUtil.redirect(req, resp, "/course");
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = (User) req.getSession().getAttribute("loginUser");
        if (user != null && user.isTeacher()) {
            req.setAttribute("courses", courseDao.listByTeacher(user.getId()));
        } else {
            req.setAttribute("courses", courseDao.listAll());
        }
        req.setAttribute("activeNav", "course");
        req.setAttribute("pageTitle", "课程管理");
        req.getRequestDispatcher("/WEB-INF/views/course-list.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, int id)
            throws ServletException, IOException {
        Course course = null;
        if (id > 0) {
            course = courseDao.findById(id);
            if (course == null) {
                WebUtil.flash(req, "error", "课程不存在或已被删除");
                WebUtil.redirect(req, resp, "/course");
                return;
            }
        }
        req.setAttribute("course", course);
        req.setAttribute("mode", course == null ? "add" : "edit");
        req.setAttribute("teachers", userDao.listTeachers());
        req.setAttribute("terms", Constants.TERMS);
        req.setAttribute("defaultTerm", Constants.DEFAULT_TERM);
        req.setAttribute("activeNav", "course");
        req.setAttribute("pageTitle", course == null ? "新增课程" : "编辑课程");
        req.getRequestDispatcher("/WEB-INF/views/course-form.jsp").forward(req, resp);
    }

    private void save(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!requireAdmin(req, resp)) {
            return;
        }
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Course course = new Course();
        course.setId(id);
        course.setCode(WebUtil.trim(req.getParameter("code")).toUpperCase());
        course.setName(WebUtil.trim(req.getParameter("name")));
        course.setCredit(WebUtil.doubleValue(req.getParameter("credit"), 0));
        course.setHours(WebUtil.intValue(req.getParameter("hours"), 0));
        course.setTeacherId(WebUtil.intOrNull(req.getParameter("teacherId")));
        course.setTerm(WebUtil.trim(req.getParameter("term")));

        Map<String, String> errors = new LinkedHashMap<>();
        if (course.getCode().isEmpty() || course.getCode().length() > 20) {
            errors.put("code", "请输入 1-20 位课程代码");
        } else if (courseDao.existsByCode(course.getCode(), id == 0 ? null : id)) {
            errors.put("code", "该课程代码已存在");
        }
        if (course.getName().isEmpty()) {
            errors.put("name", "请输入课程名称");
        }
        if (course.getCredit() <= 0 || course.getCredit() > 20) {
            errors.put("credit", "学分需在 0-20 之间");
        }
        if (course.getHours() <= 0 || course.getHours() > 300) {
            errors.put("hours", "学时需在 1-300 之间");
        }
        if (!Constants.TERMS.contains(course.getTerm())) {
            errors.put("term", "请选择学期");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.setAttribute("course", course);
            req.setAttribute("mode", id == 0 ? "add" : "edit");
            req.setAttribute("teachers", userDao.listTeachers());
            req.setAttribute("terms", Constants.TERMS);
            req.setAttribute("defaultTerm", Constants.DEFAULT_TERM);
            req.setAttribute("activeNav", "course");
            req.setAttribute("pageTitle", id == 0 ? "新增课程" : "编辑课程");
            req.getRequestDispatcher("/WEB-INF/views/course-form.jsp").forward(req, resp);
            return;
        }

        try {
            if (id == 0) {
                courseDao.insert(course);
                WebUtil.flash(req, "success", "课程 " + course.getName() + " 已创建");
            } else {
                courseDao.update(course);
                WebUtil.flash(req, "success", "课程 " + course.getName() + " 已更新");
            }
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "保存失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/course");
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (!requireAdmin(req, resp)) {
            return;
        }
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Course course = courseDao.findById(id);
        if (course == null) {
            WebUtil.flash(req, "error", "课程不存在或已被删除");
            WebUtil.redirect(req, resp, "/course");
            return;
        }
        if (course.getScoreCount() > 0) {
            WebUtil.flash(req, "error", "课程「" + course.getName() + "」已有 "
                    + course.getScoreCount() + " 条成绩记录，不能删除");
            WebUtil.redirect(req, resp, "/course");
            return;
        }
        try {
            courseDao.delete(id);
            WebUtil.flash(req, "success", "课程 " + course.getName() + " 已删除");
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "删除失败：该课程仍被其他数据引用");
        }
        WebUtil.redirect(req, resp, "/course");
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
