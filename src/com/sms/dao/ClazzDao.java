package com.sms.dao;

import com.sms.entity.Clazz;
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
 * 班级数据访问。
 */
public class ClazzDao {

    private static final String SELECT_BASE =
            "SELECT c.id, c.code, c.name, c.major_id, c.grade_year, c.head_teacher_id, "
            + "m.name AS major_name, u.real_name AS head_teacher_name, "
            + "(SELECT COUNT(*) FROM student s WHERE s.clazz_id = c.id) AS student_count "
            + "FROM clazz c "
            + "LEFT JOIN major m ON c.major_id = m.id "
            + "LEFT JOIN sys_user u ON c.head_teacher_id = u.id ";

    public List<Clazz> listAll() {
        String sql = SELECT_BASE + "ORDER BY c.grade_year DESC, c.code";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Clazz> clazzes = new ArrayList<>();
            while (rs.next()) {
                clazzes.add(mapRow(rs));
            }
            return clazzes;
        } catch (SQLException e) {
            throw new DataAccessException("查询班级列表失败", e);
        }
    }

    public Clazz findById(int id) {
        String sql = SELECT_BASE + "WHERE c.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("查询班级失败", e);
        }
    }

    public Clazz findByCode(String code) {
        String sql = SELECT_BASE + "WHERE c.code = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("按代码查询班级失败", e);
        }
    }

    public boolean existsByCode(String code, Integer excludeId) {
        String sql = "SELECT 1 FROM clazz WHERE code = ?"
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
            throw new DataAccessException("检查班级代码失败", e);
        }
    }

    public int insert(Clazz clazz) {
        String sql = "INSERT INTO clazz(code, name, major_id, grade_year, head_teacher_id) "
                + "VALUES (?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, clazz.getCode());
            ps.setString(2, clazz.getName());
            ps.setInt(3, clazz.getMajorId());
            ps.setInt(4, clazz.getGradeYear());
            if (clazz.getHeadTeacherId() == null) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, clazz.getHeadTeacherId());
            }
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    clazz.setId(keys.getInt(1));
                }
            }
            return clazz.getId();
        } catch (SQLException e) {
            throw new DataAccessException("新增班级失败", e);
        }
    }

    public void update(Clazz clazz) {
        String sql = "UPDATE clazz SET code=?, name=?, major_id=?, grade_year=?, head_teacher_id=? "
                + "WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, clazz.getCode());
            ps.setString(2, clazz.getName());
            ps.setInt(3, clazz.getMajorId());
            ps.setInt(4, clazz.getGradeYear());
            if (clazz.getHeadTeacherId() == null) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, clazz.getHeadTeacherId());
            }
            ps.setInt(6, clazz.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("修改班级失败", e);
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM clazz WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("删除班级失败", e);
        }
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM clazz";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new DataAccessException("统计班级失败", e);
        }
    }

    private Clazz mapRow(ResultSet rs) throws SQLException {
        Clazz clazz = new Clazz();
        clazz.setId(rs.getInt("id"));
        clazz.setCode(rs.getString("code"));
        clazz.setName(rs.getString("name"));
        clazz.setMajorId(rs.getInt("major_id"));
        clazz.setMajorName(rs.getString("major_name"));
        clazz.setGradeYear(rs.getInt("grade_year"));
        int headTeacherId = rs.getInt("head_teacher_id");
        clazz.setHeadTeacherId(rs.wasNull() ? null : headTeacherId);
        clazz.setHeadTeacherName(rs.getString("head_teacher_name"));
        clazz.setStudentCount(rs.getInt("student_count"));
        return clazz;
    }
}
