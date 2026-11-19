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

            <c:choose>
                <c:when test="${empty student}">
                    <section class="card">
                        <div class="empty">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16h.01"/></svg>
                            <h3>账号尚未关联学生档案</h3>
                            <p>请联系管理员把你的账号关联到学生记录后再查看成绩。</p>
                        </div>
                    </section>
                </c:when>
                <c:otherwise>
                    <section class="profile-hero">
                        <span class="avatar avatar-lg ${student.female ? 'avatar-girl' : ''}"><c:out value="${student.initial}"/></span>
                        <div style="min-width:0">
                            <div class="profile-name"><c:out value="${student.name}"/></div>
                            <div class="profile-sub">
                                ${student.studentNo} · <c:out value="${student.majorName}"/> · <c:out value="${student.clazzName}"/>
                            </div>
                            <div class="profile-chips">
                                <span class="badge badge-info">班级排名 ${rank} / ${classSize}</span>
                                <span class="badge ${passCount == fn:length(scores) and fn:length(scores) > 0 ? 'badge-ok' : 'badge-warn'}">
                                    及格 ${passCount} / ${fn:length(scores)}
                                </span>
                            </div>
                        </div>
                    </section>

                    <div class="score-summary">
                        <div><strong><fmt:formatNumber value="${avgScore}" pattern="0.0"/></strong><small>平均分</small></div>
                        <div><strong>${fn:length(scores)}</strong><small>成绩记录</small></div>
                        <div><strong>${rank}</strong><small>班级排名</small></div>
                        <div><strong>${passCount}</strong><small>及格课程</small></div>
                    </div>

                    <section class="card flush" style="margin-top:20px">
                        <div class="card-head">
                            <div>
                                <h2>成绩明细</h2>
                                <div class="card-sub">按学期倒序排列</div>
                            </div>
                        </div>
                        <div class="table-wrap">
                            <table class="table">
                                <thead>
                                <tr>
                                    <th>课程</th>
                                    <th>课程代码</th>
                                    <th>学期</th>
                                    <th>成绩</th>
                                    <th>等级</th>
                                    <th>更新时间</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach items="${scores}" var="score">
                                    <tr>
                                        <td><div class="cell-title"><c:out value="${score.courseName}"/></div></td>
                                        <td><span class="badge badge-muted">${score.courseCode}</span></td>
                                        <td class="cell-sub">${score.term}</td>
                                        <td class="num"><fmt:formatNumber value="${score.score}" pattern="0.0"/></td>
                                        <td><span class="badge ${score.levelClass}">${score.level}</span></td>
                                        <td class="cell-sub"><fmt:formatDate value="${score.updateTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty scores}">
                                    <tr>
                                        <td colspan="6">
                                            <div class="empty">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 3v18h18"/><path d="M7 15l4-4 3 3 5-6"/></svg>
                                                <h3>还没有成绩</h3>
                                                <p>任课教师录入后会显示在这里。</p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
