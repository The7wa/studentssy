package com.sms.dao;

import com.sms.entity.Major;
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
 * 专业数据访问。
 */
public class MajorDao {

    private static final String LIST_SQL =
            "SELECT m.id, m.code, m.name, "
            + "(SELECT COUNT(*) FROM clazz c WHERE c.major_id = m.id) AS class_count, "
            + "(SELECT COUNT(*) FROM student s JOIN clazz c2 ON s.clazz_id = c2.id "
            + " WHERE c2.major_id = m.id) AS student_count "
            + "FROM major m ";

    public List<Major> listAll() {
        String sql = LIST_SQL + "ORDER BY m.code";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Major> majors = new ArrayList<>();
            while (rs.next()) {
                majors.add(mapRow(rs));
            }
            return majors;
        } catch (SQLException e) {
            throw new DataAccessException("查询专业列表失败", e);
        }
    }

    public Major findById(int id) {
        String sql = LIST_SQL + "WHERE m.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("查询专业失败", e);
        }
    }

    public boolean existsByCode(String code, Integer excludeId) {
        String sql = "SELECT 1 FROM major WHERE code = ?"
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
            throw new DataAccessException("检查专业代码失败", e);
        }
    }

    public int insert(Major major) {
        String sql = "INSERT INTO major(code, name) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, major.getCode());
            ps.setString(2, major.getName());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    major.setId(keys.getInt(1));
                }
            }
            return major.getId();
        } catch (SQLException e) {
            throw new DataAccessException("新增专业失败", e);
        }
    }

    public void update(Major major) {
        String sql = "UPDATE major SET code=?, name=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, major.getCode());
            ps.setString(2, major.getName());
            ps.setInt(3, major.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("修改专业失败", e);
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM major WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("删除专业失败", e);
        }
    }

    public int countClasses(int majorId) {
        String sql = "SELECT COUNT(*) FROM clazz WHERE major_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, majorId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计专业班级失败", e);
        }
    }

    private Major mapRow(ResultSet rs) throws SQLException {
        Major major = new Major();
        major.setId(rs.getInt("id"));
        major.setCode(rs.getString("code"));
        major.setName(rs.getString("name"));
        major.setClassCount(rs.getInt("class_count"));
        major.setStudentCount(rs.getInt("student_count"));
        return major;
    }
}
