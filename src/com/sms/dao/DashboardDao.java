package com.sms.dao;

import com.sms.entity.StatItem;
import com.sms.util.DBUtil;
import com.sms.util.DataAccessException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 首页看板的聚合查询。
 */
public class DashboardDao {

    public int count(String table) {
        String sql = "SELECT COUNT(*) FROM " + table;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new DataAccessException("统计失败", e);
        }
    }

    public int countTeachers() {
        return count("sys_user WHERE role='teacher'");
    }

    public Map<String, Integer> genderStats() {
        String sql = "SELECT gender, COUNT(*) FROM student GROUP BY gender";
        Map<String, Integer> map = new LinkedHashMap<>();
        map.put("男", 0);
        map.put("女", 0);
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString(1), rs.getInt(2));
            }
            return map;
        } catch (SQLException e) {
            throw new DataAccessException("统计性别分布失败", e);
        }
    }

    /** 每个班级的人数，按人数从多到少。 */
    public List<StatItem> classStats(int limit) {
        String sql = "SELECT c.name, COUNT(s.id) AS cnt FROM clazz c "
                + "LEFT JOIN student s ON s.clazz_id = c.id "
                + "GROUP BY c.id, c.name ORDER BY cnt DESC, c.name LIMIT ?";
        int total = Math.max(1, count("student"));
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            List<StatItem> items = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int value = rs.getInt("cnt");
                    items.add(new StatItem(rs.getString("name"), value, value * 100.0 / total));
                }
            }
            return items;
        } catch (SQLException e) {
            throw new DataAccessException("统计班级分布失败", e);
        }
    }

    /** 成绩分段：优秀 / 良好 / 中等 / 及格 / 不及格。 */
    public List<StatItem> scoreBands() {
        String sql = "SELECT "
                + "COALESCE(SUM(score >= 90), 0) AS a, "
                + "COALESCE(SUM(score >= 80 AND score < 90), 0) AS b, "
                + "COALESCE(SUM(score >= 70 AND score < 80), 0) AS c, "
                + "COALESCE(SUM(score >= 60 AND score < 70), 0) AS d, "
                + "COALESCE(SUM(score < 60), 0) AS e, COUNT(*) AS total FROM score";
        String[] labels = {"优秀 90+", "良好 80-89", "中等 70-79", "及格 60-69", "不及格 <60"};
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<StatItem> items = new ArrayList<>();
            if (!rs.next()) {
                return items;
            }
            int total = Math.max(1, rs.getInt("total"));
            int[] values = {rs.getInt("a"), rs.getInt("b"), rs.getInt("c"), rs.getInt("d"), rs.getInt("e")};
            for (int i = 0; i < labels.length; i++) {
                items.add(new StatItem(labels[i], values[i], values[i] * 100.0 / total));
            }
            return items;
        } catch (SQLException e) {
            throw new DataAccessException("统计成绩分布失败", e);
        }
    }

    public double avgScore(Integer teacherId) {
        StringBuilder sql = new StringBuilder("SELECT COALESCE(AVG(sc.score), 0) FROM score sc "
                + "JOIN course c ON sc.course_id = c.id");
        if (teacherId != null) {
            sql.append(" WHERE c.teacher_id = ?");
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (teacherId != null) {
                ps.setInt(1, teacherId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计平均分失败", e);
        }
    }

    public double passRate(Integer teacherId) {
        StringBuilder sql = new StringBuilder("SELECT COALESCE(AVG(sc.score >= 60) * 100, 0) "
                + "FROM score sc JOIN course c ON sc.course_id = c.id");
        if (teacherId != null) {
            sql.append(" WHERE c.teacher_id = ?");
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (teacherId != null) {
                ps.setInt(1, teacherId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计及格率失败", e);
        }
    }

    public int countStudentsOfTeacher(int teacherId) {
        String sql = "SELECT COUNT(DISTINCT sc.student_id) FROM score sc "
                + "JOIN course c ON sc.course_id = c.id WHERE c.teacher_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计教师学生数失败", e);
        }
    }
}
