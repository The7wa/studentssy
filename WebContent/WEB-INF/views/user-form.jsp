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

            <div class="page-tools">
                <a class="btn btn-ghost" href="${ctx}/user">← 返回用户列表</a>
            </div>

            <section class="card" style="max-width:860px">
                <div class="card-head">
                    <div>
                        <h2>${mode eq 'add' ? '新增用户' : '编辑用户'}</h2>
                        <div class="card-sub">角色决定登录后可以看到哪些模块</div>
                    </div>
                </div>

                <form class="form" action="${ctx}/user" method="post" novalidate>
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="id" value="${user.id}">

                    <c:if test="${mode eq 'add'}">
                        <div class="form-note">
                            学生账号建议在学生管理中随学生档案一起创建（用户名 = 学号）。这里适合新增教师或管理员账号。
                        </div>
                    </c:if>

                    <div class="form-grid">
                        <div class="field">
                            <label for="username">登录名<span class="required">*</span></label>
                            <c:choose>
                                <c:when test="${mode eq 'add'}">
                                    <input class="input ${not empty errors.username ? 'error' : ''}" id="username" name="username"
                                           value="${fn:escapeXml(user.username)}" placeholder="3-30 位字母、数字或下划线" maxlength="30">
                                    <c:if test="${not empty errors.username}"><span class="error-text"><c:out value="${errors.username}"/></span></c:if>
                                </c:when>
                                <c:otherwise>
                                    <input class="input" id="username" value="${fn:escapeXml(user.username)}" readonly>
                                    <span class="hint">登录名创建后不可修改。</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="field">
                            <label for="realName">姓名<span class="required">*</span></label>
                            <input class="input ${not empty errors.realName ? 'error' : ''}" id="realName" name="realName"
                                   value="${fn:escapeXml(user.realName)}" placeholder="真实姓名" maxlength="30">
                            <c:if test="${not empty errors.realName}"><span class="error-text"><c:out value="${errors.realName}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="role">角色<span class="required">*</span></label>
                            <select class="select ${not empty errors.role ? 'error' : ''}" id="role" name="role">
                                <option value="teacher" ${user.role eq 'teacher' ? 'selected' : ''}>教师</option>
                                <option value="admin" ${user.role eq 'admin' ? 'selected' : ''}>管理员</option>
                                <option value="student" ${user.role eq 'student' ? 'selected' : ''}>学生</option>
                            </select>
                            <c:if test="${not empty errors.role}"><span class="error-text"><c:out value="${errors.role}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="status">账号状态</label>
                            <select class="select" id="status" name="status">
                                <option value="1" ${user.status eq 1 ? 'selected' : ''}>正常</option>
                                <option value="0" ${user.status eq 0 ? 'selected' : ''}>停用</option>
                            </select>
                        </div>

                        <div class="field">
                            <label for="phone">手机号</label>
                            <input class="input" id="phone" name="phone" value="${fn:escapeXml(user.phone)}" placeholder="选填" maxlength="20">
                        </div>

                        <div class="field">
                            <label for="email">邮箱</label>
                            <input class="input ${not empty errors.email ? 'error' : ''}" id="email" name="email" type="email"
                                   value="${fn:escapeXml(user.email)}" placeholder="选填" maxlength="60">
                            <c:if test="${not empty errors.email}"><span class="error-text"><c:out value="${errors.email}"/></span></c:if>
                        </div>

                        <c:if test="${mode eq 'add'}">
                            <div class="field field-full">
                                <label for="password">初始密码<span class="required">*</span></label>
                                <input class="input ${not empty errors.password ? 'error' : ''}" id="password" name="password" type="password"
                                       placeholder="6-32 位" maxlength="32">
                                <c:if test="${not empty errors.password}"><span class="error-text"><c:out value="${errors.password}"/></span></c:if>
                            </div>
                        </c:if>
                    </div>

                    <div class="form-actions">
                        <button class="btn btn-primary" type="submit">保存用户</button>
                        <a class="btn btn-ghost" href="${ctx}/user">取消</a>
                    </div>
                </form>
            </section>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
