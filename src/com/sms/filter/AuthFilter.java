package com.sms.filter;

import com.sms.entity.User;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 登录拦截 + 按角色拦模块。
 *
 * <p>更细的“能不能改”权限放在各个 Servlet 里判断，这里负责把不同角色隔在不该进的模块之外。</p>
 */
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String path = req.getServletPath();
        String ctx = req.getContextPath();

        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loginUser");
        if (user == null) {
            resp.sendRedirect(ctx + "/login.jsp");
            return;
        }

        if (!allowed(path, user)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        chain.doFilter(request, response);
    }

    private boolean isPublic(String path) {
        return "/login".equals(path)
                || "/login.jsp".equals(path)
                || "/error.jsp".equals(path)
                || "/index.jsp".equals(path)
                || "/favicon.ico".equals(path)
                || path.startsWith("/assets/");
    }

    private boolean allowed(String path, User user) {
        if (user.isAdmin()) {
            return true;
        }
        if (user.isStudent()) {
            return "/dashboard".equals(path)
                    || "/profile".equals(path)
                    || "/score".equals(path)
                    || "/logout".equals(path);
        }
        // 教师：不能进用户管理、专业管理
        return !"/user".equals(path) && !"/major".equals(path);
    }

    @Override
    public void destroy() {
    }
}
