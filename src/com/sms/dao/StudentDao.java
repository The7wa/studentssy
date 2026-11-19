package com.sms.dao;

import com.sms.entity.Student;
import com.sms.util.DBUtil;
import com.sms.util.DataAccessException;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * 学生数据访问。
 */
public class StudentDao {

    private static final String SELECT_BASE = "SELECT s.id, s.student_no, s.name, s.gender, s.birth_date, "
            + "s.phone, s.email, s.address, s.clazz_id, s.enroll_year, s.status, s.user_id, s.create_time, "
            + "c.name AS clazz_name, m.name AS major_name "
            + "FROM student s "
            + "LEFT JOIN clazz c ON s.clazz_id = c.id "
            + "LEFT JOIN major m ON c.major_id = m.id ";

    public Student findById(int id) {
        String sql = SELECT_BASE + "WHERE s.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("查询学生失败", e);
        }
    }

    public Student findByUserId(int userId) {
        String sql = SELECT_BASE + "WHERE s.user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("查询学生失败", e);
        }
    }

    public List<Student> list(String keyword, Integer clazzId, String status, int offset, int size) {
        StringBuilder sql = new StringBuilder(SELECT_BASE + "WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, clazzId, status);
        sql.append(" ORDER BY s.student_no LIMIT ?, ?");
        params.add(offset);
        params.add(size);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            List<Student> students = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    students.add(mapRow(rs));
                }
            }
            return students;
        } catch (SQLException e) {
            throw new DataAccessException("查询学生列表失败", e);
        }
    }

    public int count(String keyword, Integer clazzId, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM student s WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, clazzId, status);
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计学生失败", e);
        }
    }

    public Student findByNo(String studentNo) {
        String sql = SELECT_BASE + "WHERE s.student_no = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentNo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("按学号查询学生失败", e);
        }
    }

    public boolean existsByNo(String studentNo, Integer excludeId) {
        String sql = "SELECT 1 FROM student WHERE student_no = ?"
                + (excludeId == null ? "" : " AND id <> ?") + " LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentNo);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new DataAccessException("检查学号失败", e);
        }
    }

    public int insert(Student student) {
        String sql = "INSERT INTO student(student_no, name, gender, birth_date, phone, email, address, "
                + "clazz_id, enroll_year, status, user_id) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, student.getStudentNo());
            ps.setString(2, student.getName());
            ps.setString(3, student.getGender());
            ps.setDate(4, toSqlDate(student));
            ps.setString(5, student.getPhone());
            ps.setString(6, student.getEmail());
            ps.setString(7, student.getAddress());
            ps.setInt(8, student.getClazzId());
            ps.setInt(9, student.getEnrollYear());
            ps.setString(10, student.getStatus());
            if (student.getUserId() == null) {
                ps.setNull(11, java.sql.Types.INTEGER);
            } else {
                ps.setInt(11, student.getUserId());
            }
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    student.setId(keys.getInt(1));
                }
            }
            return student.getId();
        } catch (SQLException e) {
            throw new DataAccessException("新增学生失败", e);
        }
    }

    public void update(Student student) {
        String sql = "UPDATE student SET student_no=?, name=?, gender=?, birth_date=?, phone=?, email=?, "
                + "address=?, clazz_id=?, enroll_year=?, status=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, student.getStudentNo());
            ps.setString(2, student.getName());
            ps.setString(3, student.getGender());
            ps.setDate(4, toSqlDate(student));
            ps.setString(5, student.getPhone());
            ps.setString(6, student.getEmail());
            ps.setString(7, student.getAddress());
            ps.setInt(8, student.getClazzId());
            ps.setInt(9, student.getEnrollYear());
            ps.setString(10, student.getStatus());
            ps.setInt(11, student.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("修改学生失败", e);
        }
    }

    public void updateUserId(int studentId, int userId) {
        String sql = "UPDATE student SET user_id=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, studentId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("关联学生账号失败", e);
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM student WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("删除学生失败", e);
        }
    }

    public List<Student> listByClazz(int clazzId) {
        String sql = SELECT_BASE + "WHERE s.clazz_id = ? ORDER BY s.student_no";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clazzId);
            List<Student> students = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    students.add(mapRow(rs));
                }
            }
            return students;
        } catch (SQLException e) {
            throw new DataAccessException("查询班级学生失败", e);
        }
    }

    public List<Student> recent(int limit) {
        String sql = SELECT_BASE + "ORDER BY s.create_time DESC, s.id DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            List<Student> students = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    students.add(mapRow(rs));
                }
            }
            return students;
        } catch (SQLException e) {
            throw new DataAccessException("查询最近学生失败", e);
        }
    }

    public int countByClazz(int clazzId) {
        String sql = "SELECT COUNT(*) FROM student WHERE clazz_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, clazzId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计班级人数失败", e);
        }
    }

    private void appendFilters(StringBuilder sql, List<Object> params,
                               String keyword, Integer clazzId, String status) {
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (s.student_no LIKE ? OR s.name LIKE ?)");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }
        if (clazzId != null && clazzId > 0) {
            sql.append(" AND s.clazz_id = ?");
            params.add(clazzId);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND s.status = ?");
            params.add(status);
        }
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private Date toSqlDate(Student student) {
        if (student.getBirthDate() == null) {
            return null;
        }
        return new Date(student.getBirthDate().getTime());
    }

    private Student mapRow(ResultSet rs) throws SQLException {
        Student student = new Student();
        student.setId(rs.getInt("id"));
        student.setStudentNo(rs.getString("student_no"));
        student.setName(rs.getString("name"));
        student.setGender(rs.getString("gender"));
        student.setBirthDate(rs.getDate("birth_date"));
        student.setPhone(rs.getString("phone"));
        student.setEmail(rs.getString("email"));
        student.setAddress(rs.getString("address"));
        student.setClazzId(rs.getInt("clazz_id"));
        student.setClazzName(rs.getString("clazz_name"));
        student.setMajorName(rs.getString("major_name"));
        student.setEnrollYear(rs.getInt("enroll_year"));
        student.setStatus(rs.getString("status"));
        int userId = rs.getInt("user_id");
        student.setUserId(rs.wasNull() ? null : userId);
        student.setCreateTime(rs.getTimestamp("create_time"));
        return student;
    }
}
