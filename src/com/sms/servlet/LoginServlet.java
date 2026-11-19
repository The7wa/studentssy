package com.sms.servlet;

import com.sms.dao.UserDao;
import com.sms.entity.User;
import com.sms.util.DBUtil;
import com.sms.util.PasswordUtil;
import com.sms.util.WebUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 登录。
 */
public class LoginServlet extends HttpServlet {

    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("loginUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.setAttribute("dbOk", DBUtil.testConnection());
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = WebUtil.trim(req.getParameter("username"));
        String password = req.getParameter("password") == null ? "" : req.getParameter("password");

        Map<String, String> errors = new LinkedHashMap<>();
        if (username.isEmpty()) {
            errors.put("username", "请输入用户名 / 学号");
        }
        if (password.isEmpty()) {
            errors.put("password", "请输入密码");
        }

        User user = null;
        if (errors.isEmpty()) {
            user = userDao.findByUsername(username);
            if (user == null || !PasswordUtil.verify(password, user.getPassword())) {
                errors.put("login", "用户名或密码错误，请重新输入");
            } else if (!user.isEnabled()) {
                errors.put("login", "该账号已被停用，请联系管理员");
            }
        }

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.setAttribute("username", username);
            req.setAttribute("dbOk", DBUtil.testConnection());
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        user.setPassword(null);
        HttpSession session = req.getSession(true);
        req.changeSessionId();
        session.setAttribute("loginUser", user);
        session.setMaxInactiveInterval(60 * 60);
        try {
            userDao.updateLoginTime(user.getId());
        } catch (Exception ignored) {
            // 登录时间更新失败不影响登录
        }

        WebUtil.flash(req, "success", WebUtil.greeting() + "，" + user.getDisplayName() + "，欢迎回来");
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }
}
