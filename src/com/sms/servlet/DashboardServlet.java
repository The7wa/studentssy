package com.sms.servlet;

import com.sms.dao.ClazzDao;
import com.sms.dao.CourseDao;
import com.sms.dao.DashboardDao;
import com.sms.dao.ScoreDao;
import com.sms.dao.StudentDao;
import com.sms.dao.UserDao;
import com.sms.entity.Student;
import com.sms.entity.User;
import com.sms.util.WebUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 首页看板：管理员看全校，教师看自己课程，学生看个人成绩。
 */
public class DashboardServlet extends HttpServlet {

    private final StudentDao studentDao = new StudentDao();
    private final ClazzDao clazzDao = new ClazzDao();
    private final CourseDao courseDao = new CourseDao();
    private final ScoreDao scoreDao = new ScoreDao();
    private final UserDao userDao = new UserDao();
    private final DashboardDao dashboardDao = new DashboardDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loginUser");
        if (user == null) {
            WebUtil.redirect(req, resp, "/login.jsp");
            return;
        }

        req.setAttribute("activeNav", "dashboard");
        req.setAttribute("pageTitle", "数据看板");

        if (user.isStudent()) {
            loadStudentDashboard(req, user);
        } else if (user.isTeacher()) {
            loadTeacherDashboard(req, user);
        } else {
            loadAdminDashboard(req);
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }

    private void loadAdminDashboard(HttpServletRequest req) {
        req.setAttribute("studentCount", dashboardDao.count("student"));
        req.setAttribute("clazzCount", clazzDao.countAll());
        req.setAttribute("courseCount", courseDao.countAll());
        req.setAttribute("teacherCount", userDao.countByRole("teacher"));
        req.setAttribute("genderStats", dashboardDao.genderStats());
        req.setAttribute("classStats", dashboardDao.classStats(6));
        req.setAttribute("scoreBands", dashboardDao.scoreBands());
        req.setAttribute("avgScore", dashboardDao.avgScore(null));
        req.setAttribute("passRate", dashboardDao.passRate(null));
        req.setAttribute("courseStats", scoreDao.statsByCourse(null, null));
        req.setAttribute("recentStudents", studentDao.recent(5));
    }

    private void loadTeacherDashboard(HttpServletRequest req, User user) {
        req.setAttribute("myCourses", courseDao.listByTeacher(user.getId()));
        req.setAttribute("courseCount", courseDao.listByTeacher(user.getId()).size());
        req.setAttribute("studentCount", dashboardDao.countStudentsOfTeacher(user.getId()));
        req.setAttribute("avgScore", dashboardDao.avgScore(user.getId()));
        req.setAttribute("passRate", dashboardDao.passRate(user.getId()));
        req.setAttribute("courseStats", scoreDao.statsByCourse(null, user.getId()));
        req.setAttribute("recentScores", scoreDao.recent(user.getId(), 6));
    }

    private void loadStudentDashboard(HttpServletRequest req, User user) {
        Student student = studentDao.findByUserId(user.getId());
        req.setAttribute("student", student);
        if (student == null) {
            return;
        }
        req.setAttribute("scores", scoreDao.findByStudent(student.getId()));
        req.setAttribute("avgScore", scoreDao.avgByStudent(student.getId()));
        req.setAttribute("scoreCount", scoreDao.countByStudent(student.getId()));
        req.setAttribute("passCount", scoreDao.passCountByStudent(student.getId()));
        req.setAttribute("rank", scoreDao.classRank(student.getId()));
        req.setAttribute("classSize", scoreDao.classSize(student.getId()));
    }
}
