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
                <a class="btn btn-ghost" href="${ctx}/score">← 返回成绩列表</a>
                <span class="spacer"></span>
                <a class="btn btn-ghost" href="${ctx}/course">查看课程</a>
            </div>

            <c:choose>
                <c:when test="${mode eq 'select'}">
                    <section class="card" style="max-width:900px">
                        <div class="card-head">
                            <div>
                                <h2>选择录入范围</h2>
                                <div class="card-sub">先选课程、班级和学期，再逐人录入成绩</div>
                            </div>
                        </div>
                        <div class="card-body">
                            <form class="select-bar" action="${ctx}/score" method="get">
                                <input type="hidden" name="action" value="entry">
                                <div class="field">
                                    <label for="courseId">课程</label>
                                    <select class="select" id="courseId" name="courseId" required>
                                        <option value="">请选择课程</option>
                                        <c:forEach items="${courses}" var="course">
                                            <option value="${course.id}" ${selectedCourseId eq course.id ? 'selected' : ''}>
                                                <c:out value="${course.name}"/>（${course.term}）
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="field">
                                    <label for="clazzId">班级</label>
                                    <select class="select" id="clazzId" name="clazzId" required>
                                        <option value="">请选择班级</option>
                                        <c:forEach items="${clazzes}" var="clazz">
                                            <option value="${clazz.id}" ${selectedClazzId eq clazz.id ? 'selected' : ''}>
                                                <c:out value="${clazz.name}"/>
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="field">
                                    <label for="term">学期</label>
                                    <select class="select" id="term" name="term">
                                        <c:forEach items="${terms}" var="t">
                                            <option value="${t}" ${selectedTerm eq t ? 'selected' : ''}>${t}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <button class="btn btn-primary" type="submit">开始录入</button>
                            </form>
                            <c:if test="${empty courses}">
                                <div class="empty" style="padding:30px 10px">
                                    <h3>暂无可录入的课程</h3>
                                    <p>请联系管理员为你分配课程。</p>
                                </div>
                            </c:if>
                        </div>
                    </section>
                </c:when>
                <c:otherwise>
                    <section class="card flush">
                        <div class="card-head">
                            <div>
                                <h2><c:out value="${course.name}"/> · <c:out value="${clazz.name}"/></h2>
                                <div class="card-sub">${selectedTerm} · 共 ${fn:length(entries)} 名学生，空白表示暂不录入</div>
                            </div>
                            <div class="card-actions">
                                <a class="btn btn-ghost" href="${ctx}/score?action=entry">重新选择</a>
                            </div>
                        </div>

                        <form action="${ctx}/score" method="post">
                            <input type="hidden" name="action" value="saveEntry">
                            <input type="hidden" name="courseId" value="${course.id}">
                            <input type="hidden" name="clazzId" value="${clazz.id}">
                            <input type="hidden" name="term" value="${selectedTerm}">

                            <div class="table-wrap">
                                <table class="table">
                                    <thead>
                                    <tr>
                                        <th style="width:70px">#</th>
                                        <th>学号</th>
                                        <th>姓名</th>
                                        <th>班级</th>
                                        <th>录入状态</th>
                                        <th style="width:150px">成绩（0-100）</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach items="${entries}" var="entry" varStatus="st">
                                        <tr>
                                            <td class="cell-sub">${st.index + 1}</td>
                                            <td class="num">${entry.studentNo}</td>
                                            <td>
                                                <div class="cell-title"><c:out value="${entry.studentName}"/></div>
                                            </td>
                                            <td class="cell-sub"><c:out value="${entry.clazzName}"/></td>
                                            <td>
                                                <span class="badge ${entry.recorded ? 'badge-ok' : 'badge-muted'}">${entry.recorded ? '已录入' : '未录入'}</span>
                                            </td>
                                            <td>
                                                <input type="hidden" name="studentId" value="${entry.studentId}">
                                                <input class="score-input" type="number" name="score" min="0" max="100" step="0.5"
                                                       value="${empty entry.score ? '' : entry.score}">
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty entries}">
                                        <tr><td colspan="6"><div class="empty"><h3>该班级还没有在读学生</h3><p>先去学生管理里添加学生。</p></div></td></tr>
                                    </c:if>
                                    </tbody>
                                </table>
                            </div>

                            <div style="display:flex;align-items:center;gap:12px;padding:18px 20px;border-top:1px solid var(--line)">
                                <button class="btn btn-primary" type="submit">保存本页成绩</button>
                                <span class="hint">支持小数；留空表示跳过该学生。</span>
                            </div>
                        </form>
                    </section>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
