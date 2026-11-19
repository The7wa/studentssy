<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="code" value="${requestScope['javax.servlet.error.status_code']}"/>
<c:set var="message" value="${requestScope['javax.servlet.error.message']}"/>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>出错了 · 学籍通</title>
    <link rel="stylesheet" href="${ctx}/assets/css/app.css">
</head>
<body class="error-page">
<div class="error-card">
    <div class="error-code">
        <c:choose>
            <c:when test="${code eq 403}">403</c:when>
            <c:when test="${code eq 404}">404</c:when>
            <c:when test="${code eq 500}">500</c:when>
            <c:otherwise>!</c:otherwise>
        </c:choose>
    </div>

    <h1>
        <c:choose>
            <c:when test="${code eq 403}">没有访问权限</c:when>
            <c:when test="${code eq 404}">页面不存在</c:when>
            <c:when test="${code eq 500}">服务器开小差了</c:when>
            <c:otherwise>访问出错</c:otherwise>
        </c:choose>
    </h1>

    <p>
        <c:choose>
            <c:when test="${code eq 403}">当前账号的角色不能访问这个模块，请返回自己的工作台。</c:when>
            <c:when test="${code eq 404}">你访问的地址可能已被删除，或者输入有误。</c:when>
            <c:when test="${code eq 500}">
                请检查数据库是否已启动、<code>src/db.properties</code> 配置是否正确。
                <c:if test="${not empty message}"><br><c:out value="${message}"/></c:if>
            </c:when>
            <c:otherwise>请稍后再试，或返回首页。</c:otherwise>
        </c:choose>
    </p>

    <div class="error-actions">
        <c:choose>
            <c:when test="${not empty sessionScope.loginUser}">
                <a class="btn btn-primary" href="${ctx}/dashboard">返回数据看板</a>
            </c:when>
            <c:otherwise>
                <a class="btn btn-primary" href="${ctx}/login.jsp">去登录</a>
            </c:otherwise>
        </c:choose>
        <a class="btn btn-ghost" href="${ctx}/index.jsp">回到首页</a>
    </div>
</div>
</body>
</html>
