package com.sms.entity;

import java.util.Date;

/**
 * 成绩。
 */
public class Score {

    private int id;
    private int studentId;
    private String studentNo;
    private String studentName;
    private String clazzName;
    private int courseId;
    private String courseName;
    private String courseCode;
    private String term;
    private double score;
    private Date updateTime;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getStudentNo() {
        return studentNo;
    }

    public void setStudentNo(String studentNo) {
        this.studentNo = studentNo;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getClazzName() {
        return clazzName;
    }

    public void setClazzName(String clazzName) {
        this.clazzName = clazzName;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }

    public String getTerm() {
        return term;
    }

    public void setTerm(String term) {
        this.term = term;
    }

    public double getScore() {
        return score;
    }

    public void setScore(double score) {
        this.score = score;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }

    public boolean isPass() {
        return score >= 60;
    }

    /** 优秀 / 良好 / 中等 / 及格 / 不及格。 */
    public String getLevel() {
        if (score >= 90) {
            return "优秀";
        }
        if (score >= 80) {
            return "良好";
        }
        if (score >= 70) {
            return "中等";
        }
        if (score >= 60) {
            return "及格";
        }
        return "不及格";
    }

    public String getLevelClass() {
        if (score >= 90) {
            return "level-a";
        }
        if (score >= 80) {
            return "level-b";
        }
        if (score >= 60) {
            return "level-c";
        }
        return "level-d";
    }
}
