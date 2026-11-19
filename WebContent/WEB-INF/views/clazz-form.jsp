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
                <a class="btn btn-ghost" href="${ctx}/clazz">← 返回班级列表</a>
            </div>

            <section class="card" style="max-width:860px">
                <div class="card-head">
                    <div>
                        <h2>${mode eq 'add' ? '新建班级' : '编辑班级'}</h2>
                        <div class="card-sub">班级代码用于批量导入学生时定位班级</div>
                    </div>
                </div>

                <form class="form" action="${ctx}/clazz" method="post" novalidate>
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="id" value="${clazz.id}">

                    <div class="form-grid">
                        <div class="field">
                            <label for="code">班级代码<span class="required">*</span></label>
                            <input class="input ${not empty errors.code ? 'error' : ''}" id="code" name="code"
                                   value="${fn:escapeXml(clazz.code)}" placeholder="例如 JZ2301" maxlength="20">
                            <c:if test="${not empty errors.code}"><span class="error-text"><c:out value="${errors.code}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="name">班级名称<span class="required">*</span></label>
                            <input class="input ${not empty errors.name ? 'error' : ''}" id="name" name="name"
                                   value="${fn:escapeXml(clazz.name)}" placeholder="例如 计科 2301" maxlength="40">
                            <c:if test="${not empty errors.name}"><span class="error-text"><c:out value="${errors.name}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="majorId">所属专业<span class="required">*</span></label>
                            <select class="select ${not empty errors.majorId ? 'error' : ''}" id="majorId" name="majorId">
                                <option value="">请选择专业</option>
                                <c:forEach items="${majors}" var="major">
                                    <option value="${major.id}" ${clazz.majorId eq major.id ? 'selected' : ''}>
                                        <c:out value="${major.name}"/>（${major.code}）
                                    </option>
                                </c:forEach>
                            </select>
                            <c:if test="${not empty errors.majorId}"><span class="error-text"><c:out value="${errors.majorId}"/></span></c:if>
                        </div>

                        <div class="field">
                            <label for="gradeYear">年级<span class="required">*</span></label>
                            <input class="input ${not empty errors.gradeYear ? 'error' : ''}" id="gradeYear" name="gradeYear" type="number"
                                   min="2000" max="2100" value="${empty clazz ? '2023' : clazz.gradeYear}">
                            <c:if test="${not empty errors.gradeYear}"><span class="error-text"><c:out value="${errors.gradeYear}"/></span></c:if>
                        </div>

                        <div class="field field-full">
                            <label for="headTeacherId">班主任</label>
                            <select class="select" id="headTeacherId" name="headTeacherId">
                                <option value="">暂不指定</option>
                                <c:forEach items="${teachers}" var="teacher">
                                    <option value="${teacher.id}" ${clazz.headTeacherId eq teacher.id ? 'selected' : ''}>
                                        <c:out value="${teacher.realName}"/>（${teacher.username}）
                                    </option>
                                </c:forEach>
                            </select>
                            <span class="hint">只列出角色为「教师」且状态正常的账号。</span>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button class="btn btn-primary" type="submit">保存班级</button>
                        <a class="btn btn-ghost" href="${ctx}/clazz">取消</a>
                    </div>
                </form>
            </section>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
