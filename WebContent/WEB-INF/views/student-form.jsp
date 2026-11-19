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
            </div>

            <div class="split">
                <section class="card">
                    <div class="card-head">
                        <div>
                            <h2>${mode eq 'add' ? '新建学生档案' : '编辑学生档案'}</h2>
                            <div class="card-sub">带 <span style="color:#dc464b">*</span> 的为必填项</div>
                        </div>
                    </div>

                    <form class="form" action="${ctx}/student" method="post" novalidate>
                        <input type="hidden" name="action" value="save">
                        <input type="hidden" name="id" value="${student.id}">

                        <c:if test="${mode eq 'add'}">
                            <div class="form-note">
                                保存后会自动创建登录账号：<strong>用户名 = 学号</strong>，初始密码 <strong>123456</strong>，角色为学生。
                            </div>
                        </c:if>

                        <div class="form-grid">
                            <div class="field">
                                <label for="studentNo">学号<span class="required">*</span></label>
                                <input class="input ${not empty errors.studentNo ? 'error' : ''}" id="studentNo" name="studentNo"
                                       value="${fn:escapeXml(student.studentNo)}" placeholder="例如 20230101" maxlength="20">
                                <c:if test="${not empty errors.studentNo}"><span class="error-text"><c:out value="${errors.studentNo}"/></span></c:if>
                            </div>

                            <div class="field">
                                <label for="name">姓名<span class="required">*</span></label>
                                <input class="input ${not empty errors.name ? 'error' : ''}" id="name" name="name"
                                       value="${fn:escapeXml(student.name)}" placeholder="学生姓名" maxlength="20">
                                <c:if test="${not empty errors.name}"><span class="error-text"><c:out value="${errors.name}"/></span></c:if>
                            </div>

                            <div class="field">
                                <label>性别<span class="required">*</span></label>
                                <div class="radio-row">
                                    <label class="radio-chip">
                                        <input type="radio" name="gender" value="男" ${student.gender ne '女' ? 'checked' : ''}>男
                                    </label>
                                    <label class="radio-chip">
                                        <input type="radio" name="gender" value="女" ${student.gender eq '女' ? 'checked' : ''}>女
                                    </label>
                                </div>
                                <c:if test="${not empty errors.gender}"><span class="error-text"><c:out value="${errors.gender}"/></span></c:if>
                            </div>

                            <div class="field">
                                <label for="birthDate">出生日期</label>
                                <input class="input ${not empty errors.birthDate ? 'error' : ''}" id="birthDate" name="birthDate" type="date"
                                       value="<fmt:formatDate value='${student.birthDate}' pattern='yyyy-MM-dd'/>">
                                <c:if test="${not empty errors.birthDate}"><span class="error-text"><c:out value="${errors.birthDate}"/></span></c:if>
                            </div>

                            <div class="field">
                                <label for="clazzId">班级<span class="required">*</span></label>
                                <select class="select ${not empty errors.clazzId ? 'error' : ''}" id="clazzId" name="clazzId">
                                    <option value="">请选择班级</option>
                                    <c:forEach items="${clazzes}" var="clazz">
                                        <option value="${clazz.id}" ${student.clazzId eq clazz.id ? 'selected' : ''}>
                                            <c:out value="${clazz.name}"/> · <c:out value="${clazz.majorName}"/>（${clazz.gradeYear} 级）
                                        </option>
                                    </c:forEach>
                                </select>
                                <c:if test="${not empty errors.clazzId}"><span class="error-text"><c:out value="${errors.clazzId}"/></span></c:if>
                            </div>

                            <div class="field">
                                <label for="enrollYear">入学年份<span class="required">*</span></label>
                                <input class="input ${not empty errors.enrollYear ? 'error' : ''}" id="enrollYear" name="enrollYear" type="number"
                                       min="2000" max="2100" value="${empty student ? '2023' : student.enrollYear}">
                                <c:if test="${not empty errors.enrollYear}"><span class="error-text"><c:out value="${errors.enrollYear}"/></span></c:if>
                            </div>

                            <div class="field">
                                <label for="status">学籍状态<span class="required">*</span></label>
                                <select class="select" id="status" name="status">
                                    <c:forEach items="${statuses}" var="s">
                                        <option value="${s}" ${(empty student.status and s eq '在读') or student.status eq s ? 'selected' : ''}>${s}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="field">
                                <label for="phone">手机号</label>
                                <input class="input ${not empty errors.phone ? 'error' : ''}" id="phone" name="phone"
                                       value="${fn:escapeXml(student.phone)}" placeholder="11 位手机号" maxlength="20">
                                <c:if test="${not empty errors.phone}"><span class="error-text"><c:out value="${errors.phone}"/></span></c:if>
                            </div>

                            <div class="field">
                                <label for="email">邮箱</label>
                                <input class="input ${not empty errors.email ? 'error' : ''}" id="email" name="email" type="email"
                                       value="${fn:escapeXml(student.email)}" placeholder="name@example.com" maxlength="60">
                                <c:if test="${not empty errors.email}"><span class="error-text"><c:out value="${errors.email}"/></span></c:if>
                            </div>

                            <div class="field field-full">
                                <label for="address">家庭住址</label>
                                <textarea class="textarea" id="address" name="address" maxlength="120"
                                          placeholder="选填"><c:out value="${student.address}"/></textarea>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button class="btn btn-primary" type="submit">保存档案</button>
                            <a class="btn btn-ghost" href="${ctx}/student">取消</a>
                            <span class="spacer"></span>
                            <span class="hint">保存后可在学生列表继续维护成绩与账号。</span>
                        </div>
                    </form>
                </section>

                <aside class="card">
                    <div class="card-head">
                        <div><h2>填写说明</h2></div>
                    </div>
                    <div class="card-body">
                        <div class="bar-list">
                            <div>
                                <div class="cell-title">学号规则</div>
                                <p class="hint" style="margin-top:4px">4-20 位字母、数字或短横线，全系统唯一；学生用学号登录系统。</p>
                            </div>
                            <div>
                                <div class="cell-title">班级与专业</div>
                                <p class="hint" style="margin-top:4px">班级必须先由管理员创建，专业信息会随班级自动带出。</p>
                            </div>
                            <div>
                                <div class="cell-title">登录账号</div>
                                <p class="hint" style="margin-top:4px">新增学生时自动开通账号，初始密码 123456，可在用户管理中重置。</p>
                            </div>
                            <div>
                                <div class="cell-title">批量维护</div>
                                <p class="hint" style="margin-top:4px">学生较多时，用 CSV 模板批量导入，重复学号会更新已有档案。</p>
                            </div>
                        </div>
                    </div>
                </aside>
            </div>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
