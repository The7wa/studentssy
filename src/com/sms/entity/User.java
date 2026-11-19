package com.sms.entity;

import java.util.Date;

/**
 * 系统用户：管理员 / 教师 / 学生共用一张表。
 */
public class User {

    private int id;
    private String username;
    private String password;
    private String realName;
    private String role;
    private String phone;
    private String email;
    private int status;
    private Date createTime;
    private Date lastLoginTime;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRealName() {
        return realName;
    }

    public void setRealName(String realName) {
        this.realName = realName;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Date getLastLoginTime() {
        return lastLoginTime;
    }

    public void setLastLoginTime(Date lastLoginTime) {
        this.lastLoginTime = lastLoginTime;
    }

    public boolean isAdmin() {
        return "admin".equals(role);
    }

    public boolean isTeacher() {
        return "teacher".equals(role);
    }

    public boolean isStudent() {
        return "student".equals(role);
    }

    public boolean isEnabled() {
        return status == 1;
    }

    public boolean isDisabled() {
        return status != 1;
    }

    public String getRoleName() {
        if (isAdmin()) {
            return "管理员";
        }
        if (isTeacher()) {
            return "教师";
        }
        return "学生";
    }

    public String getInitial() {
        if (realName == null || realName.isEmpty()) {
            return username == null || username.isEmpty() ? "?" : username.substring(0, 1).toUpperCase();
        }
        return realName.substring(0, 1);
    }

    public String getDisplayName() {
        return realName == null || realName.isEmpty() ? username : realName;
    }
}
