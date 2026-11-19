package com.sms.entity;

/**
 * 课程成绩统计（平均分、及格率、人数）。
 */
public class CourseStat {

    private int courseId;
    private String courseName;
    private String teacherName;
    private int studentCount;
    private double avgScore;
    private double passRate;

    public CourseStat() {
    }

    public CourseStat(int courseId, String courseName, String teacherName,
                      int studentCount, double avgScore, double passRate) {
        this.courseId = courseId;
        this.courseName = courseName;
        this.teacherName = teacherName;
        this.studentCount = studentCount;
        this.avgScore = avgScore;
        this.passRate = passRate;
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

    public String getTeacherName() {
        return teacherName;
    }

    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }

    public int getStudentCount() {
        return studentCount;
    }

    public void setStudentCount(int studentCount) {
        this.studentCount = studentCount;
    }

    public double getAvgScore() {
        return avgScore;
    }

    public void setAvgScore(double avgScore) {
        this.avgScore = avgScore;
    }

    public double getPassRate() {
        return passRate;
    }

    public void setPassRate(double passRate) {
        this.passRate = passRate;
    }
}
