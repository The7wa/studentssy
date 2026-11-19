package com.sms.dao;

import com.sms.entity.User;
import com.sms.util.DBUtil;
import com.sms.util.DataAccessException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * 用户数据访问。
 */
public class UserDao {

    private static final String COLUMNS =
            "id, username, password, real_name, role, phone, email, status, create_time, last_login_time";

    public User findByUsername(String username) {
        String sql = "SELECT " + COLUMNS + " FROM sys_user WHERE username = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("查询用户失败", e);
        }
    }

    public User findById(int id) {
        String sql = "SELECT " + COLUMNS + " FROM sys_user WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        } catch (SQLException e) {
            throw new DataAccessException("查询用户失败", e);
        }
    }

    public boolean existsByUsername(String username, Integer excludeId) {
        String sql = "SELECT 1 FROM sys_user WHERE username = ?"
                + (excludeId == null ? "" : " AND id <> ?") + " LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new DataAccessException("检查用户名失败", e);
        }
    }

    public int insert(User user) {
        String sql = "INSERT INTO sys_user(username, password, real_name, role, phone, email, status) "
                + "VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getRealName());
            ps.setString(4, user.getRole());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getEmail());
            ps.setInt(7, user.getStatus());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    user.setId(keys.getInt(1));
                }
            }
            return user.getId();
        } catch (SQLException e) {
            throw new DataAccessException("新增用户失败", e);
        }
    }

    /** 用户名创建后不可修改，避免和学生学号脱节。 */
    public void update(User user) {
        String sql = "UPDATE sys_user SET real_name=?, role=?, phone=?, email=?, status=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getRealName());
            ps.setString(2, user.getRole());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getEmail());
            ps.setInt(5, user.getStatus());
            ps.setInt(6, user.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("修改用户失败", e);
        }
    }

    public void updateProfile(int id, String phone, String email) {
        String sql = "UPDATE sys_user SET phone=?, email=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setString(2, email);
            ps.setInt(3, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("修改个人资料失败", e);
        }
    }

    public void updateUsername(int id, String username) {
        String sql = "UPDATE sys_user SET username=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("同步登录名失败", e);
        }
    }

    public void updateRealName(int id, String realName) {
        String sql = "UPDATE sys_user SET real_name=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, realName);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("同步姓名失败", e);
        }
    }

    public void updatePassword(int id, String passwordHash) {
        String sql = "UPDATE sys_user SET password=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("重置密码失败", e);
        }
    }

    public void updateStatus(int id, int status) {
        String sql = "UPDATE sys_user SET status=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("修改账号状态失败", e);
        }
    }

    public void updateLoginTime(int id) {
        String sql = "UPDATE sys_user SET last_login_time=NOW() WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("更新登录时间失败", e);
        }
    }

    public void delete(int id) {
        String sql = "DELETE FROM sys_user WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DataAccessException("删除用户失败", e);
        }
    }

    public List<User> list(String role, String keyword, int offset, int size) {
        StringBuilder sql = new StringBuilder("SELECT " + COLUMNS + " FROM sys_user WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, role, keyword);
        sql.append(" ORDER BY id DESC LIMIT ?, ?");
        params.add(offset);
        params.add(size);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            List<User> users = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapRow(rs));
                }
            }
            return users;
        } catch (SQLException e) {
            throw new DataAccessException("查询用户列表失败", e);
        }
    }

    public int count(String role, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM sys_user WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, role, keyword);
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计用户失败", e);
        }
    }

    public int countByRole(String role) {
        String sql = "SELECT COUNT(*) FROM sys_user WHERE role=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new DataAccessException("统计用户失败", e);
        }
    }

    public List<User> listTeachers() {
        String sql = "SELECT " + COLUMNS + " FROM sys_user WHERE role='teacher' AND status=1 "
                + "ORDER BY real_name";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<User> users = new ArrayList<>();
            while (rs.next()) {
                users.add(mapRow(rs));
            }
            return users;
        } catch (SQLException e) {
            throw new DataAccessException("查询教师列表失败", e);
        }
    }

    private void appendFilters(StringBuilder sql, List<Object> params, String role, String keyword) {
        if (role != null && !role.isEmpty()) {
            sql.append(" AND role=?");
            params.add(role);
        }
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (username LIKE ? OR real_name LIKE ?)");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }
    }

    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setRealName(rs.getString("real_name"));
        user.setRole(rs.getString("role"));
        user.setPhone(rs.getString("phone"));
        user.setEmail(rs.getString("email"));
        user.setStatus(rs.getInt("status"));
        user.setCreateTime(rs.getTimestamp("create_time"));
        Timestamp last = rs.getTimestamp("last_login_time");
        user.setLastLoginTime(last);
        return user;
    }
}
