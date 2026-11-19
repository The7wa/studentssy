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
                        <h2>成绩记录</h2>
                        <div class="card-sub">按课程、班级、学期筛选，共 ${page.total} 条</div>
                    </div>
                    <div class="card-actions">
                        <a class="btn btn-primary" href="${ctx}/score?action=entry">录入成绩</a>
                    </div>
                </div>

                <div class="toolbar">
                    <form action="${ctx}/score" method="get">
                        <select class="select" name="courseId">
                            <option value="">全部课程</option>
                            <c:forEach items="${courses}" var="course">
                                <option value="${course.id}" ${courseId eq course.id ? 'selected' : ''}>
                                    <c:out value="${course.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <select class="select" name="clazzId">
                            <option value="">全部班级</option>
                            <c:forEach items="${clazzes}" var="clazz">
                                <option value="${clazz.id}" ${clazzId eq clazz.id ? 'selected' : ''}>
                                    <c:out value="${clazz.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <select class="select" name="term">
                            <option value="">全部学期</option>
                            <c:forEach items="${terms}" var="t">
                                <option value="${t}" ${term eq t ? 'selected' : ''}>${t}</option>
                            </c:forEach>
                        </select>
                        <div class="search-box">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.2-3.2"/></svg>
                            <input type="text" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="学号 / 姓名">
                        </div>
                        <button class="btn btn-primary" type="submit">查询</button>
                        <a class="btn btn-ghost" href="${ctx}/score">重置</a>
                    </form>
                </div>

                <div class="table-wrap">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>学生</th>
                            <th>班级</th>
                            <th>课程</th>
                            <th>学期</th>
                            <th>成绩</th>
                            <th>等级</th>
                            <th style="width:100px">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${page.items}" var="score">
                            <tr>
                                <td>
                                    <div class="cell-title"><c:out value="${score.studentName}"/></div>
                                    <div class="cell-sub">${score.studentNo}</div>
                                </td>
                                <td><c:out value="${score.clazzName}"/></td>
                                <td>
                                    <div class="cell-title"><c:out value="${score.courseName}"/></div>
                                    <div class="cell-sub">${score.courseCode}</div>
                                </td>
                                <td class="cell-sub">${score.term}</td>
                                <td class="num"><fmt:formatNumber value="${score.score}" pattern="0.0"/></td>
                                <td><span class="badge ${score.levelClass}">${score.level}</span></td>
                                <td>
                                    <div class="row-actions">
                                        <a class="link" href="${ctx}/score?action=entry&courseId=${score.courseId}&term=${score.term}">录入</a>
                                        <form action="${ctx}/score" method="post" data-confirm="确定删除这条成绩吗？">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${score.id}">
                                            <button class="link link-danger" type="submit">删除</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty page.items}">
                            <tr>
                                <td colspan="7">
                                    <div class="empty">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 3v18h18"/><path d="M7 15l4-4 3 3 5-6"/></svg>
                                        <h3>没有符合条件的成绩</h3>
                                        <p>调整筛选条件，或去「录入成绩」补充数据。</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="pager">
                    <span class="pager-info">共 ${page.total} 条，第 ${page.page} / ${page.totalPages} 页</span>
                    <c:url var="prevUrl" value="/score">
                        <c:param name="courseId" value="${courseId}"/>
                        <c:param name="clazzId" value="${clazzId}"/>
                        <c:param name="term" value="${term}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="page" value="${page.prevPage}"/>
                    </c:url>
                    <a class="${page.hasPrev ? '' : 'disabled'}" href="${prevUrl}">上一页</a>
                    <c:forEach begin="1" end="${page.totalPages}" var="i">
                        <c:if test="${i == 1 or i == page.totalPages or (i >= page.page - 2 and i <= page.page + 2)}">
                            <c:url var="numUrl" value="/score">
                                <c:param name="courseId" value="${courseId}"/>
                                <c:param name="clazzId" value="${clazzId}"/>
                                <c:param name="term" value="${term}"/>
                                <c:param name="keyword" value="${keyword}"/>
                                <c:param name="page" value="${i}"/>
                            </c:url>
                            <c:choose>
                                <c:when test="${i == page.page}"><span class="current">${i}</span></c:when>
                                <c:otherwise><a href="${numUrl}">${i}</a></c:otherwise>
                            </c:choose>
                        </c:if>
                    </c:forEach>
                    <c:url var="nextUrl" value="/score">
                        <c:param name="courseId" value="${courseId}"/>
                        <c:param name="clazzId" value="${clazzId}"/>
                        <c:param name="term" value="${term}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="page" value="${page.nextPage}"/>
                    </c:url>
                    <a class="${page.hasNext ? '' : 'disabled'}" href="${nextUrl}">下一页</a>
                </div>
            </section>

            <section class="card" style="margin-top:20px">
                <div class="card-head">
                    <div>
                        <h2>课程成绩统计</h2>
                        <div class="card-sub">${empty term ? '全部学期' : term} · 平均分与及格率</div>
                    </div>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty stats}">
                            <div class="empty"><h3>暂无统计数据</h3><p>录入成绩后自动生成。</p></div>
                        </c:when>
                        <c:otherwise>
                            <div class="bar-list two-col">
                                <c:forEach items="${stats}" var="stat">
                                    <div class="mini-course">
                                        <div class="mini-course-head">
                                            <span class="name"><c:out value="${stat.courseName}"/></span>
                                            <span class="teacher">${stat.studentCount} 人</span>
                                            <span class="avg">均分 <fmt:formatNumber value="${stat.avgScore}" pattern="0.0"/> · 及格 <fmt:formatNumber value="${stat.passRate}" pattern="0"/>%</span>
                                        </div>
                                        <span class="bar-track"><span class="bar-fill" style="width:${stat.avgScore}%"></span></span>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
