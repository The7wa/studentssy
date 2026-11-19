package com.sms.servlet;

import com.sms.dao.MajorDao;
import com.sms.entity.Major;
import com.sms.entity.User;
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
 * 专业管理：列表、新增、编辑、删除。
 */
public class MajorServlet extends HttpServlet {

    private final MajorDao majorDao = new MajorDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int editId = WebUtil.intValue(req.getParameter("editId"), 0);
        Major editing = editId > 0 ? majorDao.findById(editId) : null;
        req.setAttribute("majors", majorDao.listAll());
        req.setAttribute("editing", editing);
        req.setAttribute("activeNav", "major");
        req.setAttribute("pageTitle", "专业管理");
        req.getRequestDispatcher("/WEB-INF/views/major-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!requireAdmin(req, resp)) {
            return;
        }
        String action = WebUtil.trim(req.getParameter("action"));
        if ("delete".equals(action)) {
            delete(req, resp);
            return;
        }

        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Major major = new Major();
        major.setId(id);
        major.setCode(WebUtil.trim(req.getParameter("code")).toUpperCase());
        major.setName(WebUtil.trim(req.getParameter("name")));

        Map<String, String> errors = new LinkedHashMap<>();
        if (major.getCode().isEmpty() || major.getCode().length() > 10) {
            errors.put("code", "请输入 1-10 位专业代码");
        } else if (majorDao.existsByCode(major.getCode(), id == 0 ? null : id)) {
            errors.put("code", "该专业代码已存在");
        }
        if (major.getName().isEmpty()) {
            errors.put("name", "请输入专业名称");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.setAttribute("majors", majorDao.listAll());
            req.setAttribute("editing", major);
            req.setAttribute("activeNav", "major");
            req.setAttribute("pageTitle", "专业管理");
            req.getRequestDispatcher("/WEB-INF/views/major-list.jsp").forward(req, resp);
            return;
        }

        try {
            if (id == 0) {
                majorDao.insert(major);
                WebUtil.flash(req, "success", "专业 " + major.getName() + " 已创建");
            } else {
                majorDao.update(major);
                WebUtil.flash(req, "success", "专业 " + major.getName() + " 已更新");
            }
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "保存失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/major");
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Major major = majorDao.findById(id);
        if (major == null) {
            WebUtil.flash(req, "error", "专业不存在或已被删除");
            WebUtil.redirect(req, resp, "/major");
            return;
        }
        if (major.getClassCount() > 0) {
            WebUtil.flash(req, "error", "专业「" + major.getName() + "」下还有 "
                    + major.getClassCount() + " 个班级，不能删除");
            WebUtil.redirect(req, resp, "/major");
            return;
        }
        try {
            majorDao.delete(id);
            WebUtil.flash(req, "success", "专业 " + major.getName() + " 已删除");
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "删除失败：该专业仍被其他数据引用");
        }
        WebUtil.redirect(req, resp, "/major");
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
