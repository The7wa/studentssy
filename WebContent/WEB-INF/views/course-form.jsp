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
                <a class="btn btn-ghost" href="${ctx}/course">← 返回课程列表</a>
            </div>

            <section class="card" style="max-width:860px">
                <div class="card-head">
                    <div>
                        <h2>${mode eq 'add' ? '新增课程' : '编辑课程'}</h2>
                        <div class="card-sub">课程代码会显示在成绩单中</div>
                    </div>
                </div>

                <form class="form" action="${ctx}/course" method="post" novalidate>
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="id" value="${course.id}">

                    <div class="form-grid">
                        <div class="field">
                            <label for="code">课程代码<span class="required">*</span></label>
                            <input class="input ${not empty errors.code ? 'error' : ''}" id="code" name="code"
                                   value="${fn:escapeXml(course.code)}" placeholder="例如 CS101" maxlength="20">
                            <c:if test="${not empty errors.code}"><span class="error-text"><c:out value="${errors.code}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="name">课程名称<span class="required">*</span></label>
                            <input class="input ${not empty errors.name ? 'error' : ''}" id="name" name="name"
                                   value="${fn:escapeXml(course.name)}" placeholder="例如 数据结构" maxlength="40">
                            <c:if test="${not empty errors.name}"><span class="error-text"><c:out value="${errors.name}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="credit">学分<span class="required">*</span></label>
                            <input class="input ${not empty errors.credit ? 'error' : ''}" id="credit" name="credit" type="number"
                                   step="0.5" min="0.5" max="20" value="${empty course ? '3' : course.credit}">
                            <c:if test="${not empty errors.credit}"><span class="error-text"><c:out value="${errors.credit}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="hours">学时<span class="required">*</span></label>
                            <input class="input ${not empty errors.hours ? 'error' : ''}" id="hours" name="hours" type="number"
                                   min="1" max="300" value="${empty course ? '48' : course.hours}">
                            <c:if test="${not empty errors.hours}"><span class="error-text"><c:out value="${errors.hours}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="teacherId">任课教师</label>
                            <select class="select" id="teacherId" name="teacherId">
                                <option value="">暂不分配</option>
                                <c:forEach items="${teachers}" var="teacher">
                                    <option value="${teacher.id}" ${course.teacherId eq teacher.id ? 'selected' : ''}>
                                        <c:out value="${teacher.realName}"/>（${teacher.username}）
                                    </option>
                                </c:forEach>
                            </select>
                            <span class="hint">教师只能录入自己课程的成绩。</span>
                        </div>

                        <div class="field">
                            <label for="term">开课学期<span class="required">*</span></label>
                            <select class="select ${not empty errors.term ? 'error' : ''}" id="term" name="term">
                                <c:forEach items="${terms}" var="t">
                                    <option value="${t}" ${(empty course.term and t eq defaultTerm) or course.term eq t ? 'selected' : ''}>${t}</option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty errors.term}"><span class="error-text"><c:out value="${errors.term}"/></span></c:if>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn btn-primary" type="submit">保存课程</button>
                        <a class="btn btn-ghost" href="${ctx}/course">取消</a>
                    </div>
                </form>
            </section>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
