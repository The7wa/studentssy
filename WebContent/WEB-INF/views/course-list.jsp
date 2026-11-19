<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${pageTitle} · 学籍通</title>
    <link rel="stylesheet" href="${ctx}/assets/css/app.css">
</head>
<body class="app">
<div class="layout">
    <%@ include file="common/sidebar.jspf" %>
    <div class="main">
        <%@ include file="common/topbar.jspf" %>
        <main class="content">
            <%@ include file="common/flash.jspf" %>

            <section class="card flush">
                <div class="card-head">
                    <div>
                        <h2>${loginUser.teacher ? '我的课程' : '课程列表'}</h2>
                        <div class="card-sub">共 ${fn:length(courses)} 门课程 · 平均分与及格率按全部成绩统计</div>
                    </div>
                    <div class="card-actions">
                        <c:if test="${loginUser.admin}">
                            <a class="btn btn-primary" href="${ctx}/course?action=toAdd">新增课程</a>
                        </c:if>
                        <a class="btn btn-ghost" href="${ctx}/score?action=entry">成绩录入</a>
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>课程</th>
                            <th>代码</th>
                            <th>学分 / 学时</th>
                            <th>任课教师</th>
                            <th>学期</th>
                            <th>平均分</th>
                            <th>及格率</th>
                            <th style="width:150px">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${courses}" var="course">
                            <tr>
                                <td>
                                    <div class="cell-title"><c:out value="${course.name}"/></div>
                                    <div class="cell-sub">${course.scoreCount} 条成绩</div>
                                </td>
                                <td><span class="badge badge-muted">${course.code}</span></td>
                                <td class="num"><fmt:formatNumber value="${course.credit}" pattern="0.#"/> / ${course.hours}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty course.teacherName}"><span class="cell-sub">未分配</span></c:when>
                                        <c:otherwise><c:out value="${course.teacherName}"/></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="cell-sub">${course.term}</td>
                                <td class="num"><fmt:formatNumber value="${course.avgScore}" pattern="0.0"/></td>
                                <td>
                                    <span class="badge ${course.passRate >= 90 ? 'badge-ok' : course.passRate >= 60 ? 'badge-info' : 'badge-warn'}">
                                        <fmt:formatNumber value="${course.passRate}" pattern="0.0"/>%
                                    </span>
                                </td>
                                <td>
                                    <div class="row-actions">
                                        <a class="link" href="${ctx}/score?action=entry&courseId=${course.id}&term=${course.term}">录入</a>
                                        <a class="link" href="${ctx}/score?courseId=${course.id}">成绩</a>
                                        <c:if test="${loginUser.admin}">
                                            <a class="link" href="${ctx}/course?action=toEdit&id=${course.id}">编辑</a>
                                            <form action="${ctx}/course" method="post" data-confirm="确定删除课程「${fn:escapeXml(course.name)}」吗？已有成绩的课程不会被删除。">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${course.id}">
                                                <button class="link link-danger" type="submit">删除</button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty courses}">
                            <tr><td colspan="8"><div class="empty"><h3>还没有课程</h3><p>${loginUser.teacher ? '请联系管理员为你分配课程。' : '创建课程后就可以录入成绩了。'}</p></div></td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
