package com.sms.servlet;

import com.sms.dao.ClazzDao;
import com.sms.dao.CourseDao;
import com.sms.dao.ScoreDao;
import com.sms.dao.StudentDao;
import com.sms.entity.Course;
import com.sms.entity.Page;
import com.sms.entity.Score;
import com.sms.entity.ScoreEntry;
import com.sms.entity.Student;
import com.sms.entity.User;
import com.sms.util.Constants;
import com.sms.util.DataAccessException;
import com.sms.util.WebUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * 成绩管理：查询、录入（批量）、删除；学生查看自己的成绩。
 */
public class ScoreServlet extends HttpServlet {

    private final ScoreDao scoreDao = new ScoreDao();
    private final CourseDao courseDao = new CourseDao();
    private final ClazzDao clazzDao = new ClazzDao();
    private final StudentDao studentDao = new StudentDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = user(req);
        if (user == null) {
            WebUtil.redirect(req, resp, "/login.jsp");
            return;
        }
        String action = WebUtil.trim(req.getParameter("action"));
        if (user.isStudent()) {
            my(req, resp, user);
            return;
        }
        if ("entry".equals(action)) {
            entry(req, resp, user);
        } else {
            list(req, resp, user);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = user(req);
        if (user == null) {
            WebUtil.redirect(req, resp, "/login.jsp");
            return;
        }
        if (user.isStudent()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String action = WebUtil.trim(req.getParameter("action"));
        if ("saveEntry".equals(action)) {
            saveEntry(req, resp, user);
        } else if ("delete".equals(action)) {
            delete(req, resp, user);
        } else {
            WebUtil.redirect(req, resp, "/score");
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        Integer courseId = WebUtil.intOrNull(req.getParameter("courseId"));
        Integer clazzId = WebUtil.intOrNull(req.getParameter("clazzId"));
        String term = WebUtil.trim(req.getParameter("term"));
        String keyword = WebUtil.trim(req.getParameter("keyword"));
        int page = WebUtil.page(req.getParameter("page"));

        Integer teacherId = user.isTeacher() ? user.getId() : null;
        int total = scoreDao.count(courseId, clazzId, term, keyword, teacherId);
        int totalPages = Math.max(1, (total + Constants.PAGE_SIZE - 1) / Constants.PAGE_SIZE);
        if (page > totalPages) {
            page = totalPages;
        }
        List<Score> scores = scoreDao.list(courseId, clazzId, term, keyword, teacherId,
                (page - 1) * Constants.PAGE_SIZE, Constants.PAGE_SIZE);

        req.setAttribute("page", new Page<>(scores, page, Constants.PAGE_SIZE, total));
        req.setAttribute("courses", user.isTeacher()
                ? courseDao.listByTeacher(user.getId()) : courseDao.listAll());
        req.setAttribute("clazzes", clazzDao.listAll());
        req.setAttribute("stats", scoreDao.statsByCourse(term.isEmpty() ? null : term, teacherId));
        req.setAttribute("terms", Constants.TERMS);
        req.setAttribute("courseId", courseId);
        req.setAttribute("clazzId", clazzId);
        req.setAttribute("term", term);
        req.setAttribute("keyword", keyword);
        req.setAttribute("activeNav", "score");
        req.setAttribute("pageTitle", "成绩管理");
        req.getRequestDispatcher("/WEB-INF/views/score-list.jsp").forward(req, resp);
    }

    private void entry(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        int courseId = WebUtil.intValue(req.getParameter("courseId"), 0);
        int clazzId = WebUtil.intValue(req.getParameter("clazzId"), 0);
        String term = WebUtil.trim(req.getParameter("term"));
        if (term.isEmpty()) {
            term = Constants.DEFAULT_TERM;
        }

        req.setAttribute("courses", user.isTeacher()
                ? courseDao.listByTeacher(user.getId()) : courseDao.listAll());
        req.setAttribute("clazzes", clazzDao.listAll());
        req.setAttribute("terms", Constants.TERMS);
        req.setAttribute("selectedCourseId", courseId);
        req.setAttribute("selectedClazzId", clazzId);
        req.setAttribute("selectedTerm", term);
        req.setAttribute("activeNav", "score");
        req.setAttribute("pageTitle", "成绩录入");

        if (courseId > 0 && clazzId > 0) {
            Course course = courseDao.findById(courseId);
            if (course == null) {
                WebUtil.flash(req, "error", "课程不存在");
                WebUtil.redirect(req, resp, "/score?action=entry");
                return;
            }
            if (!canManage(user, course)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            List<ScoreEntry> entries = scoreDao.listForEntry(courseId, clazzId, term);
            req.setAttribute("course", course);
            req.setAttribute("clazz", clazzDao.findById(clazzId));
            req.setAttribute("entries", entries);
            req.setAttribute("mode", "edit");
        } else {
            req.setAttribute("mode", "select");
        }
        req.getRequestDispatcher("/WEB-INF/views/score-entry.jsp").forward(req, resp);
    }

    private void saveEntry(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {
        int courseId = WebUtil.intValue(req.getParameter("courseId"), 0);
        int clazzId = WebUtil.intValue(req.getParameter("clazzId"), 0);
        String term = WebUtil.trim(req.getParameter("term"));
        String back = "/score?action=entry&courseId=" + courseId + "&clazzId=" + clazzId + "&term=" + term;

        Course course = courseDao.findById(courseId);
        if (course == null || clazzId <= 0 || term.isEmpty()) {
            WebUtil.flash(req, "error", "请选择课程、班级和学期");
            WebUtil.redirect(req, resp, "/score?action=entry");
            return;
        }
        if (!canManage(user, course)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String[] studentIds = req.getParameterValues("studentId");
        String[] scores = req.getParameterValues("score");
        if (studentIds == null || scores == null || studentIds.length != scores.length) {
            WebUtil.flash(req, "error", "提交的数据不完整，请重试");
            WebUtil.redirect(req, resp, back);
            return;
        }

        List<String> invalid = new ArrayList<>();
        for (int i = 0; i < studentIds.length; i++) {
            String text = scores[i] == null ? "" : scores[i].trim();
            if (text.isEmpty()) {
                continue;
            }
            try {
                double value = Double.parseDouble(text);
                if (value < 0 || value > 100) {
                    invalid.add("成绩需在 0-100 之间：" + text);
                }
            } catch (NumberFormatException e) {
                invalid.add("成绩格式不正确：" + text);
            }
        }
        if (!invalid.isEmpty()) {
            WebUtil.flash(req, "error", "保存失败，" + invalid.get(0));
            WebUtil.redirect(req, resp, back);
            return;
        }

        int saved = 0;
        try {
            for (int i = 0; i < studentIds.length; i++) {
                String text = scores[i] == null ? "" : scores[i].trim();
                if (text.isEmpty()) {
                    continue;
                }
                int studentId = Integer.parseInt(studentIds[i]);
                scoreDao.saveOrUpdate(studentId, courseId, term, Double.parseDouble(text));
                saved++;
            }
            WebUtil.flash(req, "success", "已保存 " + saved + " 条成绩（" + course.getName() + " · " + term + "）");
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "保存成绩失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, back);
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Score score = scoreDao.findById(id);
        if (score == null) {
            WebUtil.flash(req, "error", "成绩记录不存在");
            WebUtil.redirect(req, resp, "/score");
            return;
        }
        Course course = courseDao.findById(score.getCourseId());
        if (!canManage(user, course)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            scoreDao.delete(id);
            WebUtil.flash(req, "success", "已删除 " + score.getStudentName() + " 的 " + score.getCourseName() + " 成绩");
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "删除失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/score");
    }

    private void my(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        Student student = studentDao.findByUserId(user.getId());
        req.setAttribute("student", student);
        if (student != null) {
            req.setAttribute("scores", scoreDao.findByStudent(student.getId()));
            req.setAttribute("avgScore", scoreDao.avgByStudent(student.getId()));
            req.setAttribute("rank", scoreDao.classRank(student.getId()));
            req.setAttribute("classSize", scoreDao.classSize(student.getId()));
            req.setAttribute("passCount", scoreDao.passCountByStudent(student.getId()));
        }
        req.setAttribute("activeNav", "myScore");
        req.setAttribute("pageTitle", "我的成绩");
        req.getRequestDispatcher("/WEB-INF/views/score-my.jsp").forward(req, resp);
    }

    private boolean canManage(User user, Course course) {
        if (course == null) {
            return false;
        }
        if (user.isAdmin()) {
            return true;
        }
        return user.isTeacher() && course.getTeacherId() != null
                && course.getTeacherId() == user.getId();
    }

    private User user(HttpServletRequest req) {
        return (User) req.getSession().getAttribute("loginUser");
    }
}
