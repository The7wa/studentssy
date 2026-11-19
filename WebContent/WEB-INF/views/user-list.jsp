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
                        <h2>用户账号</h2>
                        <div class="card-sub">共 ${page.total} 个账号 · 管理员 / 教师 / 学生共用一套登录</div>
                    </div>
                    <div class="card-actions">
                        <a class="btn btn-primary" href="${ctx}/user?action=toAdd">新增用户</a>
                    </div>
                </div>

                <div class="toolbar">
                    <form action="${ctx}/user" method="get">
                        <select class="select" name="role">
                            <option value="">全部角色</option>
                            <option value="admin" ${role eq 'admin' ? 'selected' : ''}>管理员</option>
                            <option value="teacher" ${role eq 'teacher' ? 'selected' : ''}>教师</option>
                            <option value="student" ${role eq 'student' ? 'selected' : ''}>学生</option>
                        </select>
                        <div class="search-box">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.2-3.2"/></svg>
                            <input type="text" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="用户名或姓名" autocomplete="off">
                        </div>
                        <button class="btn btn-primary" type="submit">查询</button>
                        <a class="btn btn-ghost" href="${ctx}/user">重置</a>
                    </form>
                </div>

                <div class="table-wrap">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>用户</th>
                            <th>登录名</th>
                            <th>角色</th>
                            <th>状态</th>
                            <th>最后登录</th>
                            <th>创建时间</th>
                            <th style="width:200px">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${page.items}" var="item">
                            <tr>
                                <td>
                                    <div class="cell-main">
                                        <span class="avatar"><c:out value="${item.initial}"/></span>
                                        <div class="cell-text">
                                            <div class="cell-title"><c:out value="${item.realName}"/></div>
                                            <div class="cell-sub">${empty item.email ? '未填写邮箱' : fn:escapeXml(item.email)}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="num">${item.username}</td>
                                <td>
                                    <span class="badge ${item.admin ? 'badge-violet' : item.teacher ? 'badge-info' : 'badge-muted'}">${item.roleName}</span>
                                </td>
                                <td>
                                    <span class="badge ${item.enabled ? 'badge-ok' : 'badge-danger'}">${item.enabled ? '正常' : '已停用'}</span>
                                </td>
                                <td class="cell-sub">
                                    <c:choose>
                                        <c:when test="${empty item.lastLoginTime}">从未登录</c:when>
                                        <c:otherwise><fmt:formatDate value="${item.lastLoginTime}" pattern="yyyy-MM-dd HH:mm"/></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="cell-sub"><fmt:formatDate value="${item.createTime}" pattern="yyyy-MM-dd"/></td>
                                <td>
                                    <div class="row-actions">
                                        <a class="link" href="${ctx}/user?action=toEdit&id=${item.id}">编辑</a>
                                        <form action="${ctx}/user" method="post" data-confirm="确定把「${fn:escapeXml(item.realName)}」的密码重置为 123456 吗？">
                                            <input type="hidden" name="action" value="reset">
                                            <input type="hidden" name="id" value="${item.id}">
                                            <button class="link" type="submit">重置</button>
                                        </form>
                                        <c:if test="${item.id ne loginUser.id}">
                                            <form action="${ctx}/user" method="post" data-confirm="确定${item.enabled ? '停用' : '启用'}该账号吗？">
                                                <input type="hidden" name="action" value="toggle">
                                                <input type="hidden" name="id" value="${item.id}">
                                                <button class="link" type="submit">${item.enabled ? '停用' : '启用'}</button>
                                            </form>
                                            <form action="${ctx}/user" method="post" data-confirm="确定删除账号「${fn:escapeXml(item.realName)}」吗？此操作不可恢复。">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${item.id}">
                                                <button class="link link-danger" type="submit">删除</button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty page.items}">
                            <tr><td colspan="7"><div class="empty"><h3>没有找到用户</h3><p>换个筛选条件试试。</p></div></td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="pager">
                    <span class="pager-info">共 ${page.total} 条，第 ${page.page} / ${page.totalPages} 页</span>
                    <c:url var="prevUrl" value="/user">
                        <c:param name="role" value="${role}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="page" value="${page.prevPage}"/>
                    </c:url>
                    <a class="${page.hasPrev ? '' : 'disabled'}" href="${prevUrl}">上一页</a>
                    <c:forEach begin="1" end="${page.totalPages}" var="i">
                        <c:if test="${i == 1 or i == page.totalPages or (i >= page.page - 2 and i <= page.page + 2)}">
                            <c:url var="numUrl" value="/user">
                                <c:param name="role" value="${role}"/>
                                <c:param name="keyword" value="${keyword}"/>
                                <c:param name="page" value="${i}"/>
                            </c:url>
                            <c:choose>
                                <c:when test="${i == page.page}"><span class="current">${i}</span></c:when>
                                <c:otherwise><a href="${numUrl}">${i}</a></c:otherwise>
                            </c:choose>
                        </c:if>
                    </c:forEach>
                    <c:url var="nextUrl" value="/user">
                        <c:param name="role" value="${role}"/>
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="page" value="${page.nextPage}"/>
                    </c:url>
                    <a class="${page.hasNext ? '' : 'disabled'}" href="${nextUrl}">下一页</a>
                </div>
            </section>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
