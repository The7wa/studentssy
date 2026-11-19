package com.sms.dao;

import com.sms.entity.Course;
import com.sms.util.DBUtil;
import com.sms.util.DataAccessException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * 课程数据访问。
 */
public class CourseDao {

    private static final String SELECT_BASE =
            "SELECT c.id, c.code, c.name, c.credit, c.hours, c.teacher_id, c.term, "
            + "u.real_name AS teacher_name, "
            + "(SELECT COUNT(*) FROM score sc WHERE sc.course_id = c.id) AS score_count, "
            + "COALESCE((SELECT AVG(sc2.score) FROM score sc2 WHERE sc2.course_id = c.id), 0) AS avg_score, "
            + "COALESCE((SELECT AVG(sc3.score >= 60) * 100 FROM score sc3 WHERE sc3.course_id = c.id), 0) AS pass_rate "
            + "FROM course c LEFT JOIN sys_user u ON c.teacher_id = u.id ";

    public List<Course> listAll() {
        return query(SELECT_BASE + "ORDER BY c.code", null);
    }

    public List<Course> listByTeacher(int teacherId) {
        return query(SELECT_BASE + "WHERE c.teacher_id = ? ORDER BY c.code", teacherId);
    }

    public Course findById(int id) {
        String sql = SELECT_BASE + "WHERE c.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("查询课程失败", e);
        }
    }

    public boolean existsByCode(String code, Integer excludeId) {
        String sql = "SELECT 1 FROM course WHERE code = ?"
                + (excludeId == null ? "" : " AND id <> ?") + " LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new DataAccessException("检查课程代码失败", e);
        }
    }

    public int insert(Course course) {
        String sql = "INSERT INTO course(code, name, credit, hours, teacher_id, term) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, course.getCode());
            ps.setString(2, course.getName());
            ps.setDouble(3, course.getCredit());
            ps.setInt(4, course.getHours());
            if (course.getTeacherId() == null) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, course.getTeacherId());
            }
            ps.setString(6, course.getTerm());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    course.setId(keys.getInt(1));
                }
            }
            return course.getId();
        } catch (SQLException e) {
            throw new DataAccessException("新增课程失败", e);
        }
    }

    public void update(Course course) {
        String sql = "UPDATE course SET code=?, name=?, credit=?, hours=?, teacher_id=?, term=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, course.getCode());
            ps.setString(2, course.getName());
            ps.setDouble(3, course.getCredit());
            ps.setInt(4, course.getHours());
            if (course.getTeacherId() == null) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, course.getTeacherId());
            }
            ps.setString(6, course.getTerm());
            ps.setInt(7, course.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("修改课程失败", e);
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM course WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("删除课程失败", e);
        }
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM course";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new DataAccessException("统计课程失败", e);
        }
    }

    private List<Course> query(String sql, Integer teacherId) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (teacherId != null) {
                ps.setInt(1, teacherId);
            }
            List<Course> courses = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    courses.add(mapRow(rs));
                }
            }
            return courses;
        } catch (SQLException e) {
            throw new DataAccessException("查询课程列表失败", e);
        }
    }

    private Course mapRow(ResultSet rs) throws SQLException {
        Course course = new Course();
        course.setId(rs.getInt("id"));
        course.setCode(rs.getString("code"));
        course.setName(rs.getString("name"));
        course.setCredit(rs.getDouble("credit"));
        course.setHours(rs.getInt("hours"));
        int teacherId = rs.getInt("teacher_id");
        course.setTeacherId(rs.wasNull() ? null : teacherId);
        course.setTeacherName(rs.getString("teacher_name"));
        course.setTerm(rs.getString("term"));
        course.setScoreCount(rs.getInt("score_count"));
        course.setAvgScore(rs.getDouble("avg_score"));
        course.setPassRate(rs.getDouble("pass_rate"));
        return course;
    }
}
