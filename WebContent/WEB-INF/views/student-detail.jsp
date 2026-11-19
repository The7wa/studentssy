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

            <div class="page-tools">
                <a class="btn btn-ghost" href="${ctx}/student">← 返回学生列表</a>
                <span class="spacer"></span>
                <c:if test="${loginUser.admin}">
                    <a class="btn btn-primary" href="${ctx}/student?action=toEdit&id=${student.id}">编辑档案</a>
                </c:if>
            </div>

            <section class="profile-hero">
                <span class="avatar avatar-lg ${student.female ? 'avatar-girl' : ''}"><c:out value="${student.initial}"/></span>
                <div style="min-width:0">
                    <div class="profile-name"><c:out value="${student.name}"/></div>
                    <div class="profile-sub">
                        ${student.studentNo} · <c:out value="${student.majorName}"/> · <c:out value="${student.clazzName}"/>
                    </div>
                    <div class="profile-chips">
                        <span class="badge ${student.status eq '在读' ? 'badge-ok' : student.status eq '休学' ? 'badge-warn' : 'badge-muted'}">${student.status}</span>
                        <span class="badge">${student.gender}</span>
                        <span class="badge">${student.age} 岁</span>
                        <span class="badge">${student.enrollYear} 级</span>
                    </div>
                </div>
            </section>

            <div class="score-summary">
                <div><strong><fmt:formatNumber value="${avgScore}" pattern="0.0"/></strong><small>平均分</small></div>
                <div><strong>${fn:length(scores)}</strong><small>成绩记录</small></div>
                <div>
                    <c:set var="passCount" value="0"/>
                    <c:forEach items="${scores}" var="s">
                        <c:if test="${s.score >= 60}"><c:set var="passCount" value="${passCount + 1}"/></c:if>
                    </c:forEach>
                    <strong>${passCount}</strong><small>及格课程</small>
                </div>
                <div><strong>${fn:length(scores) - passCount}</strong><small>不及格课程</small></div>
            </div>

            <div class="grid-2" style="margin-top:20px">
                <section class="card">
                    <div class="card-head"><div><h2>基本信息</h2></div></div>
                    <div class="card-body">
                        <div class="meta-grid">
                            <div class="meta-item"><div class="meta-label">学号</div><div class="meta-value">${student.studentNo}</div></div>
                            <div class="meta-item"><div class="meta-label">姓名</div><div class="meta-value"><c:out value="${student.name}"/></div></div>
                            <div class="meta-item"><div class="meta-label">性别</div><div class="meta-value">${student.gender}</div></div>
                            <div class="meta-item"><div class="meta-label">出生日期</div><div class="meta-value"><fmt:formatDate value="${student.birthDate}" pattern="yyyy-MM-dd"/></div></div>
                            <div class="meta-item"><div class="meta-label">手机号</div><div class="meta-value">${empty student.phone ? '—' : fn:escapeXml(student.phone)}</div></div>
                            <div class="meta-item"><div class="meta-label">邮箱</div><div class="meta-value">${empty student.email ? '—' : fn:escapeXml(student.email)}</div></div>
                            <div class="meta-item"><div class="meta-label">专业</div><div class="meta-value"><c:out value="${student.majorName}"/></div></div>
                            <div class="meta-item"><div class="meta-label">班级</div><div class="meta-value"><c:out value="${student.clazzName}"/></div></div>
                            <div class="meta-item"><div class="meta-label">入学年份</div><div class="meta-value">${student.enrollYear}</div></div>
                            <div class="meta-item"><div class="meta-label">档案创建时间</div><div class="meta-value"><fmt:formatDate value="${student.createTime}" pattern="yyyy-MM-dd HH:mm"/></div></div>
                            <div class="meta-item" style="grid-column:1/-1"><div class="meta-label">家庭住址</div><div class="meta-value">${empty student.address ? '—' : fn:escapeXml(student.address)}</div></div>
                        </div>
                    </div>
                </section>

                <section class="card">
                    <div class="card-head">
                        <div><h2>成绩记录</h2><div class="card-sub">全部学期</div></div>
                    </div>
                    <div class="table-wrap">
                        <table class="table" style="min-width:auto">
                            <thead>
                            <tr><th>课程</th><th>学期</th><th>成绩</th><th>等级</th></tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${scores}" var="score">
                                <tr>
                                    <td><div class="cell-title"><c:out value="${score.courseName}"/></div><div class="cell-sub">${score.courseCode}</div></td>
                                    <td class="cell-sub">${score.term}</td>
                                    <td class="num"><fmt:formatNumber value="${score.score}" pattern="0.0"/></td>
                                    <td><span class="badge ${score.levelClass}">${score.level}</span></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty scores}">
                                <tr><td colspan="4"><div class="empty"><h3>还没有成绩</h3><p>任课教师录入后会显示在这里。</p></div></td></tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
