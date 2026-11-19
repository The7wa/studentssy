package com.sms.dao;

import com.sms.entity.CourseStat;
import com.sms.entity.Score;
import com.sms.entity.ScoreEntry;
import com.sms.util.DBUtil;
import com.sms.util.DataAccessException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * 成绩数据访问。
 */
public class ScoreDao {

    private static final String SELECT_BASE =
            "SELECT sc.id, sc.student_id, sc.course_id, sc.term, sc.score, sc.update_time, "
            + "s.student_no, s.name AS student_name, cl.name AS clazz_name, "
            + "c.name AS course_name, c.code AS course_code "
            + "FROM score sc "
            + "JOIN student s ON sc.student_id = s.id "
            + "JOIN clazz cl ON s.clazz_id = cl.id "
            + "JOIN course c ON sc.course_id = c.id ";

    public List<Score> list(Integer courseId, Integer clazzId, String term, String keyword,
                            Integer teacherId, int offset, int size) {
        StringBuilder sql = new StringBuilder(SELECT_BASE + "WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, courseId, clazzId, term, keyword, teacherId);
        sql.append(" ORDER BY sc.term DESC, s.student_no LIMIT ?, ?");
        params.add(offset);
        params.add(size);
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            List<Score> scores = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    scores.add(mapRow(rs));
                }
            }
            return scores;
        } catch (SQLException e) {
            throw new DataAccessException("查询成绩失败", e);
        }
    }

    public int count(Integer courseId, Integer clazzId, String term, String keyword, Integer teacherId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM score sc "
                + "JOIN student s ON sc.student_id = s.id "
                + "JOIN course c ON sc.course_id = c.id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, courseId, clazzId, term, keyword, teacherId);
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计成绩失败", e);
        }
    }

    public Score findById(int id) {
        String sql = SELECT_BASE + "WHERE sc.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("查询成绩失败", e);
        }
    }

    public List<Score> findByStudent(int studentId) {
        String sql = SELECT_BASE + "WHERE sc.student_id = ? ORDER BY sc.term DESC, c.name";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            List<Score> scores = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    scores.add(mapRow(rs));
                }
            }
            return scores;
        } catch (SQLException e) {
            throw new DataAccessException("查询学生成绩失败", e);
        }
    }

    public void saveOrUpdate(int studentId, int courseId, String term, double score) {
        String sql = "INSERT INTO score(student_id, course_id, term, score) VALUES (?,?,?,?) "
                + "ON DUPLICATE KEY UPDATE score = VALUES(score)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, courseId);
            ps.setString(3, term);
            ps.setDouble(4, score);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("保存成绩失败", e);
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM score WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("删除成绩失败", e);
        }
    }

    /**
     * 成绩录入页：某班级在某门课、某学期的全部学生（含未录入成绩的）。
     */
    public List<ScoreEntry> listForEntry(int courseId, int clazzId, String term) {
        String sql = "SELECT s.id AS student_id, s.student_no, s.name AS student_name, "
                + "cl.name AS clazz_name, sc.id AS score_id, sc.score "
                + "FROM student s JOIN clazz cl ON s.clazz_id = cl.id "
                + "LEFT JOIN score sc ON sc.student_id = s.id AND sc.course_id = ? AND sc.term = ? "
                + "WHERE s.clazz_id = ? AND s.status = '在读' ORDER BY s.student_no";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setString(2, term);
            ps.setInt(3, clazzId);
            List<ScoreEntry> entries = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ScoreEntry entry = new ScoreEntry();
                    entry.setStudentId(rs.getInt("student_id"));
                    entry.setStudentNo(rs.getString("student_no"));
                    entry.setStudentName(rs.getString("student_name"));
                    entry.setClazzName(rs.getString("clazz_name"));
                    int scoreId = rs.getInt("score_id");
                    entry.setScoreId(rs.wasNull() ? null : scoreId);
                    double score = rs.getDouble("score");
                    entry.setScore(rs.wasNull() ? null : score);
                    entries.add(entry);
                }
            }
            return entries;
        } catch (SQLException e) {
            throw new DataAccessException("查询成绩录入列表失败", e);
        }
    }

    public List<CourseStat> statsByCourse(String term, Integer teacherId) {
        StringBuilder sql = new StringBuilder(
                "SELECT c.id, c.name AS course_name, u.real_name AS teacher_name, "
                + "COUNT(sc.id) AS student_count, "
                + "COALESCE(AVG(sc.score), 0) AS avg_score, "
                + "COALESCE(AVG(sc.score >= 60) * 100, 0) AS pass_rate "
                + "FROM course c "
                + "LEFT JOIN score sc ON sc.course_id = c.id");
        List<Object> params = new ArrayList<>();
        if (term != null && !term.isEmpty()) {
            sql.append(" AND sc.term = ?");
            params.add(term);
        }
        sql.append(" LEFT JOIN sys_user u ON c.teacher_id = u.id");
        if (teacherId != null) {
            sql.append(" WHERE c.teacher_id = ?");
            params.add(teacherId);
        }
        sql.append(" GROUP BY c.id, c.name, u.real_name ORDER BY c.name");
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            List<CourseStat> stats = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    stats.add(new CourseStat(
                            rs.getInt("id"),
                            rs.getString("course_name"),
                            rs.getString("teacher_name"),
                            rs.getInt("student_count"),
                            rs.getDouble("avg_score"),
                            rs.getDouble("pass_rate")));
                }
            }
            return stats;
        } catch (SQLException e) {
            throw new DataAccessException("统计课程成绩失败", e);
        }
    }

    public double avgByStudent(int studentId) {
        String sql = "SELECT COALESCE(AVG(score), 0) FROM score WHERE student_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计学生平均分失败", e);
        }
    }

    public int countByStudent(int studentId) {
        String sql = "SELECT COUNT(*) FROM score WHERE student_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计学生成绩数失败", e);
        }
    }

    public int passCountByStudent(int studentId) {
        String sql = "SELECT COUNT(*) FROM score WHERE student_id=? AND score >= 60";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计及格数失败", e);
        }
    }

    /**
     * 班级内按平均分排名（MySQL 8 窗口函数）。
     */
    public int classRank(int studentId) {
        String sql = "SELECT t.rnk FROM ("
                + "  SELECT s.id, RANK() OVER (ORDER BY AVG(sc.score) DESC) AS rnk"
                + "  FROM student s JOIN score sc ON sc.student_id = s.id"
                + "  WHERE s.clazz_id = (SELECT clazz_id FROM student WHERE id = ?)"
                + "  GROUP BY s.id"
                + ") t WHERE t.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计班级排名失败", e);
        }
    }

    public int classSize(int studentId) {
        String sql = "SELECT COUNT(*) FROM student WHERE clazz_id = "
                + "(SELECT clazz_id FROM student WHERE id = ?) AND status = '在读'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计班级人数失败", e);
        }
    }

    public List<Score> recent(Integer teacherId, int limit) {
        StringBuilder sql = new StringBuilder(SELECT_BASE);
        if (teacherId == null) {
            sql.append(" ORDER BY sc.update_time DESC, sc.id DESC LIMIT ?");
        } else {
            sql.append(" WHERE c.teacher_id = ? ORDER BY sc.update_time DESC, sc.id DESC LIMIT ?");
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (teacherId == null) {
                ps.setInt(1, limit);
            } else {
                ps.setInt(1, teacherId);
                ps.setInt(2, limit);
            }
            List<Score> scores = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    scores.add(mapRow(rs));
                }
            }
            return scores;
        } catch (SQLException e) {
            throw new DataAccessException("查询最近成绩失败", e);
        }
    }

    private void appendFilters(StringBuilder sql, List<Object> params, Integer courseId,
                               Integer clazzId, String term, String keyword, Integer teacherId) {
        if (courseId != null && courseId > 0) {
            sql.append(" AND sc.course_id = ?");
            params.add(courseId);
        }
        if (clazzId != null && clazzId > 0) {
            sql.append(" AND s.clazz_id = ?");
            params.add(clazzId);
        }
        if (term != null && !term.isEmpty()) {
            sql.append(" AND sc.term = ?");
            params.add(term);
        }
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (s.student_no LIKE ? OR s.name LIKE ?)");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }
        if (teacherId != null) {
            sql.append(" AND c.teacher_id = ?");
            params.add(teacherId);
        }
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private Score mapRow(ResultSet rs) throws SQLException {
        Score score = new Score();
        score.setId(rs.getInt("id"));
        score.setStudentId(rs.getInt("student_id"));
        score.setStudentNo(rs.getString("student_no"));
        score.setStudentName(rs.getString("student_name"));
        score.setClazzName(rs.getString("clazz_name"));
        score.setCourseId(rs.getInt("course_id"));
        score.setCourseName(rs.getString("course_name"));
        score.setCourseCode(rs.getString("course_code"));
        score.setTerm(rs.getString("term"));
        score.setScore(rs.getDouble("score"));
        score.setUpdateTime(rs.getTimestamp("update_time"));
        return score;
    }
}
