<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
                        <h2>班级列表</h2>
                        <div class="card-sub">共 ${fn:length(clazzes)} 个班级，按年级从高到低排列</div>
                    </div>
                    <div class="card-actions">
                        <c:if test="${loginUser.admin}">
                            <a class="btn btn-primary" href="${ctx}/clazz?action=toAdd">新增班级</a>
                        </c:if>
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>班级</th>
                            <th>所属专业</th>
                            <th>年级</th>
                            <th>班主任</th>
                            <th>学生人数</th>
                            <th style="width:170px">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${clazzes}" var="clazz">
                            <tr>
                                <td>
                                    <div class="cell-title"><c:out value="${clazz.name}"/></div>
                                    <div class="cell-sub">${clazz.code}</div>
                                </td>
                                <td><c:out value="${clazz.majorName}"/></td>
                                <td class="num">${clazz.gradeYear} 级</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty clazz.headTeacherName}"><span class="cell-sub">未指定</span></c:when>
                                        <c:otherwise><c:out value="${clazz.headTeacherName}"/></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span class="badge ${clazz.studentCount > 0 ? 'badge-info' : 'badge-muted'}">${clazz.studentCount} 人</span>
                                </td>
                                <td>
                                    <div class="row-actions">
                                        <a class="link" href="${ctx}/student?clazzId=${clazz.id}">学生</a>
                                        <c:if test="${loginUser.admin}">
                                            <a class="link" href="${ctx}/clazz?action=toEdit&id=${clazz.id}">编辑</a>
                                            <form action="${ctx}/clazz" method="post" data-confirm="确定删除班级「${fn:escapeXml(clazz.name)}」吗？">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${clazz.id}">
                                                <button class="link link-danger" type="submit">删除</button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty clazzes}">
                            <tr>
                                <td colspan="6">
                                    <div class="empty">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                                        <h3>还没有班级</h3>
                                        <p>新建班级后就可以给学生分配班级了。</p>
                                    </div>
                                </td>
                            </tr>
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
