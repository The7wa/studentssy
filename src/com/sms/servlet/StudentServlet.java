package com.sms.servlet;

import com.sms.dao.ClazzDao;
import com.sms.dao.ScoreDao;
import com.sms.dao.StudentDao;
import com.sms.dao.UserDao;
import com.sms.entity.Clazz;
import com.sms.entity.Page;
import com.sms.entity.Score;
import com.sms.entity.Student;
import com.sms.entity.User;
import com.sms.util.Constants;
import com.sms.util.CsvUtil;
import com.sms.util.DataAccessException;
import com.sms.util.PasswordUtil;
import com.sms.util.WebUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * 学生管理：列表、搜索、分页、增删改查、CSV 导入导出。
 */
public class StudentServlet extends HttpServlet {

    private static final Pattern NO_PATTERN = Pattern.compile("^[0-9A-Za-z-]{4,20}$");
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private final StudentDao studentDao = new StudentDao();
    private final ClazzDao clazzDao = new ClazzDao();
    private final UserDao userDao = new UserDao();
    private final ScoreDao scoreDao = new ScoreDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = WebUtil.trim(req.getParameter("action"));
        switch (action) {
            case "toAdd":
                if (!requireAdmin(req, resp)) {
                    return;
                }
                showForm(req, resp, 0);
                break;
            case "toEdit":
                if (!requireAdmin(req, resp)) {
                    return;
                }
                showForm(req, resp, WebUtil.intValue(req.getParameter("id"), 0));
                break;
            case "detail":
                showDetail(req, resp);
                break;
            case "export":
                export(req, resp);
                break;
            case "template":
                template(resp);
                break;
            default:
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
        } else if ("import".equals(action)) {
            importCsv(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/student");
        }
    }

    private void list(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = WebUtil.trim(req.getParameter("keyword"));
        Integer clazzId = WebUtil.intOrNull(req.getParameter("clazzId"));
        String status = WebUtil.trim(req.getParameter("status"));
        int page = WebUtil.page(req.getParameter("page"));

        int total = studentDao.count(keyword, clazzId, status);
        int totalPages = Math.max(1, (total + Constants.PAGE_SIZE - 1) / Constants.PAGE_SIZE);
        if (page > totalPages) {
            page = totalPages;
        }
        List<Student> items = studentDao.list(keyword, clazzId, status,
                (page - 1) * Constants.PAGE_SIZE, Constants.PAGE_SIZE);

        req.setAttribute("page", new Page<>(items, page, Constants.PAGE_SIZE, total));
        req.setAttribute("clazzes", clazzDao.listAll());
        req.setAttribute("keyword", keyword);
        req.setAttribute("clazzId", clazzId);
        req.setAttribute("status", status);
        req.setAttribute("activeNav", "student");
        req.setAttribute("pageTitle", "学生管理");
        req.getRequestDispatcher("/WEB-INF/views/student-list.jsp").forward(req, resp);
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, int id)
            throws ServletException, IOException {
        Student student = null;
        if (id > 0) {
            student = studentDao.findById(id);
            if (student == null) {
                WebUtil.flash(req, "error", "学生不存在或已被删除");
                WebUtil.redirect(req, resp, "/student");
                return;
            }
        }
        req.setAttribute("student", student);
        req.setAttribute("mode", student == null ? "add" : "edit");
        req.setAttribute("clazzes", clazzDao.listAll());
        req.setAttribute("genders", Constants.genders());
        req.setAttribute("statuses", Constants.studentStatus());
        req.setAttribute("activeNav", "student");
        req.setAttribute("pageTitle", student == null ? "新增学生" : "编辑学生");
        req.getRequestDispatcher("/WEB-INF/views/student-form.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Student student = studentDao.findById(id);
        if (student == null) {
            WebUtil.flash(req, "error", "学生不存在或已被删除");
            WebUtil.redirect(req, resp, "/student");
            return;
        }
        List<Score> scores = scoreDao.findByStudent(id);
        req.setAttribute("student", student);
        req.setAttribute("scores", scores);
        req.setAttribute("avgScore", scoreDao.avgByStudent(id));
        req.setAttribute("activeNav", "student");
        req.setAttribute("pageTitle", "学生档案");
        req.getRequestDispatcher("/WEB-INF/views/student-detail.jsp").forward(req, resp);
    }

    private void save(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User login = (User) req.getSession().getAttribute("loginUser");
        if (login == null || !login.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int id = WebUtil.intValue(req.getParameter("id"), 0);
        Student student = new Student();
        student.setId(id);
        student.setStudentNo(WebUtil.trim(req.getParameter("studentNo")));
        student.setName(WebUtil.trim(req.getParameter("name")));
        student.setGender(WebUtil.trim(req.getParameter("gender")));
        student.setPhone(WebUtil.trim(req.getParameter("phone")));
        student.setEmail(WebUtil.trim(req.getParameter("email")));
        student.setAddress(WebUtil.trim(req.getParameter("address")));
        student.setClazzId(WebUtil.intValue(req.getParameter("clazzId"), 0));
        student.setEnrollYear(WebUtil.intValue(req.getParameter("enrollYear"), 0));
        student.setStatus(WebUtil.trim(req.getParameter("status")));
        String birthText = WebUtil.trim(req.getParameter("birthDate"));
        try {
            student.setBirthDate(parseDate(birthText));
        } catch (Exception ignored) {
            student.setBirthDate(null);
        }

        Map<String, String> errors = validate(student, birthText, id);
        boolean add = id == 0;

        if (errors.isEmpty() && add && userDao.existsByUsername(student.getStudentNo(), null)) {
            errors.put("studentNo", "该学号已被其他账号占用，无法创建登录账号");
        }

        if (!errors.isEmpty()) {
            req.setAttribute("errors", errors);
            req.setAttribute("student", student);
            req.setAttribute("mode", add ? "add" : "edit");
            req.setAttribute("clazzes", clazzDao.listAll());
            req.setAttribute("genders", Constants.genders());
            req.setAttribute("statuses", Constants.studentStatus());
            req.setAttribute("activeNav", "student");
            req.setAttribute("pageTitle", add ? "新增学生" : "编辑学生");
            req.getRequestDispatcher("/WEB-INF/views/student-form.jsp").forward(req, resp);
            return;
        }

        student.setBirthDate(parseDate(birthText));
        try {
            if (add) {
                User account = new User();
                account.setUsername(student.getStudentNo());
                account.setPassword(PasswordUtil.hash(Constants.DEFAULT_PASSWORD));
                account.setRealName(student.getName());
                account.setRole(Constants.ROLE_STUDENT);
                account.setPhone(student.getPhone());
                account.setEmail(student.getEmail());
                account.setStatus(1);
                int userId = userDao.insert(account);
                student.setUserId(userId);
                studentDao.insert(student);
                WebUtil.flash(req, "success", "学生 " + student.getName() + " 已添加，登录账号为学号，初始密码 123456");
            } else {
                Student old = studentDao.findById(id);
                if (old == null) {
                    WebUtil.flash(req, "error", "学生不存在或已被删除");
                    WebUtil.redirect(req, resp, "/student");
                    return;
                }
                if (old.getUserId() != null) {
                    if (!old.getStudentNo().equals(student.getStudentNo())) {
                        userDao.updateUsername(old.getUserId(), student.getStudentNo());
                    }
                    userDao.updateRealName(old.getUserId(), student.getName());
                    userDao.updateProfile(old.getUserId(), student.getPhone(), student.getEmail());
                }
                studentDao.update(student);
                WebUtil.flash(req, "success", "学生 " + student.getName() + " 的信息已更新");
            }
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "保存失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/student");
    }

    private Map<String, String> validate(Student student, String birthText, int id) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (!NO_PATTERN.matcher(student.getStudentNo()).matches()) {
            errors.put("studentNo", "学号需为 4-20 位字母、数字或短横线");
        } else if (studentDao.existsByNo(student.getStudentNo(), id == 0 ? null : id)) {
            errors.put("studentNo", "该学号已存在");
        }
        if (student.getName().isEmpty()) {
            errors.put("name", "请输入姓名");
        } else if (student.getName().length() > 20) {
            errors.put("name", "姓名不能超过 20 个字符");
        }
        if (!"男".equals(student.getGender()) && !"女".equals(student.getGender())) {
            errors.put("gender", "请选择性别");
        }
        if (student.getClazzId() <= 0 || clazzDao.findById(student.getClazzId()) == null) {
            errors.put("clazzId", "请选择有效的班级");
        }
        if (student.getEnrollYear() < 2000 || student.getEnrollYear() > 2100) {
            errors.put("enrollYear", "请输入有效的入学年份");
        }
        if (!Arrays.asList(Constants.studentStatus()).contains(student.getStatus())) {
            errors.put("status", "请选择学籍状态");
        }
        if (!birthText.isEmpty()) {
            try {
                LocalDate birth = LocalDate.parse(birthText);
                if (birth.isAfter(LocalDate.now())) {
                    errors.put("birthDate", "出生日期不能晚于今天");
                }
            } catch (Exception e) {
                errors.put("birthDate", "出生日期格式应为 yyyy-MM-dd");
            }
        }
        if (!student.getEmail().isEmpty() && !EMAIL_PATTERN.matcher(student.getEmail()).matches()) {
            errors.put("email", "邮箱格式不正确");
        }
        if (!student.getPhone().isEmpty() && !student.getPhone().matches("^[0-9+\\- ]{6,20}$")) {
            errors.put("phone", "手机号格式不正确");
        }
        return errors;
    }

    private void delete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User login = (User) req.getSession().getAttribute("loginUser");
        if (login == null || !login.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int id = WebUtil.intValue(req.getParameter("id"), 0);
        try {
            Student student = studentDao.findById(id);
            if (student == null) {
                WebUtil.flash(req, "error", "学生不存在或已被删除");
            } else {
                studentDao.delete(id);
                if (student.getUserId() != null) {
                    userDao.delete(student.getUserId());
                }
                WebUtil.flash(req, "success", "学生 " + student.getName() + " 及其登录账号已删除");
            }
        } catch (DataAccessException e) {
            WebUtil.flash(req, "error", "删除失败：" + e.getMessage());
        }
        WebUtil.redirect(req, resp, "/student");
    }

    private void export(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String keyword = WebUtil.trim(req.getParameter("keyword"));
        Integer clazzId = WebUtil.intOrNull(req.getParameter("clazzId"));
        String status = WebUtil.trim(req.getParameter("status"));

        List<Student> students = studentDao.list(keyword, clazzId, status, 0, 5000);
        String[] header = {"学号", "姓名", "性别", "出生日期", "班级", "专业", "入学年份", "学籍状态",
                "手机", "邮箱", "家庭住址"};
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
        List<String[]> rows = new ArrayList<>();
        for (Student student : students) {
            rows.add(new String[]{
                    student.getStudentNo(), student.getName(), student.getGender(),
                    student.getBirthDate() == null ? "" : format.format(student.getBirthDate()),
                    student.getClazzName(), student.getMajorName(),
                    String.valueOf(student.getEnrollYear()), student.getStatus(),
                    student.getPhone(), student.getEmail(), student.getAddress()
            });
        }
        CsvUtil.write(resp, "学生名单_" + new SimpleDateFormat("yyyyMMdd").format(new Date()) + ".csv",
                header, rows);
    }

    private void template(HttpServletResponse resp) throws IOException {
        String[] header = {"学号", "姓名", "性别", "出生日期", "班级代码", "入学年份", "学籍状态",
                "手机", "邮箱", "家庭住址"};
        List<String[]> rows = new ArrayList<>();
        rows.add(new String[]{"20230999", "张三", "男", "2005-06-01", "JZ2301", "2023", "在读",
                "13800000000", "zhangsan@example.com", "浙江省杭州市"});
        CsvUtil.write(resp, "学生导入模板.csv", header, rows);
    }

    private void importCsv(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User login = (User) req.getSession().getAttribute("loginUser");
        if (login == null || !login.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Part part;
        try {
            part = req.getPart("file");
        } catch (Exception e) {
            WebUtil.flash(req, "error", "文件上传失败，请重新选择文件");
            WebUtil.redirect(req, resp, "/student");
            return;
        }
        if (part == null || part.getSize() == 0) {
            WebUtil.flash(req, "error", "请选择要导入的 CSV 文件");
            WebUtil.redirect(req, resp, "/student");
            return;
        }

        List<String[]> rows;
        try (InputStream in = part.getInputStream()) {
            rows = CsvUtil.read(in);
        }
        if (rows.size() <= 1) {
            WebUtil.flash(req, "error", "文件里没有数据行");
            WebUtil.redirect(req, resp, "/student");
            return;
        }

        int success = 0;
        List<String> failures = new ArrayList<>();
        // 第一行是表头，从第二行开始
        for (int i = 1; i < rows.size(); i++) {
            String[] row = rows.get(i);
            String rowNo = "第 " + (i + 1) + " 行";
            if (row.length < 7) {
                failures.add(rowNo + "：列数不足");
                continue;
            }
            try {
                String no = row[0].trim();
                String name = row[1].trim();
                String gender = row[2].trim().isEmpty() ? "男" : row[2].trim();
                String birth = row[3].trim();
                String clazzCode = row[4].trim();
                String year = row[5].trim();
                String status = row[6].trim().isEmpty() ? "在读" : row[6].trim();
                String phone = row.length > 7 ? row[7].trim() : "";
                String email = row.length > 8 ? row[8].trim() : "";
                String address = row.length > 9 ? row[9].trim() : "";

                Student student = new Student();
                student.setStudentNo(no);
                student.setName(name);
                student.setGender(gender);
                student.setPhone(phone);
                student.setEmail(email);
                student.setAddress(address);
                Clazz clazz = clazzDao.findByCode(clazzCode);
                if (clazz == null) {
                    failures.add(rowNo + "：班级代码 " + clazzCode + " 不存在");
                    continue;
                }
                student.setClazzId(clazz.getId());
                student.setEnrollYear(Integer.parseInt(year.isEmpty() ? "0" : year));
                student.setStatus(status);
                student.setBirthDate(parseDate(birth));

                Student old = studentDao.findByNo(no);
                if (old != null) {
                    student.setId(old.getId());
                    student.setUserId(old.getUserId());
                    studentDao.update(student);
                    if (old.getUserId() != null) {
                        userDao.updateRealName(old.getUserId(), name);
                    }
                } else {
                    User account = new User();
                    account.setUsername(no);
                    account.setPassword(PasswordUtil.hash(Constants.DEFAULT_PASSWORD));
                    account.setRealName(name);
                    account.setRole(Constants.ROLE_STUDENT);
                    account.setStatus(1);
                    account.setPhone(phone);
                    account.setEmail(email);
                    if (userDao.existsByUsername(no, null)) {
                        failures.add(rowNo + "：登录名 " + no + " 已存在");
                        continue;
                    }
                    student.setUserId(userDao.insert(account));
                    studentDao.insert(student);
                }
                success++;
            } catch (Exception e) {
                failures.add(rowNo + "：" + e.getMessage());
            }
        }

        StringBuilder message = new StringBuilder("导入完成：成功 " + success + " 条");
        if (!failures.isEmpty()) {
            message.append("，失败 ").append(failures.size()).append(" 条");
            message.append("（").append(String.join("；", failures.subList(0, Math.min(3, failures.size()))));
            if (failures.size() > 3) {
                message.append(" 等");
            }
            message.append("）");
            WebUtil.flash(req, "warn", message.toString());
        } else {
            WebUtil.flash(req, "success", message.toString());
        }
        WebUtil.redirect(req, resp, "/student");
    }

    private Date parseDate(String text) {
        if (text == null || text.trim().isEmpty()) {
            return null;
        }
        LocalDate localDate = LocalDate.parse(text.trim());
        return Date.from(localDate.atStartOfDay(ZoneId.systemDefault()).toInstant());
    }

    private boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loginUser");
        if (user == null || !user.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        return true;
    }
}
