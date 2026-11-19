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

            <div class="split">
                <section class="card flush">
                    <div class="card-head">
                        <div>
                            <h2>专业列表</h2>
                            <div class="card-sub">共 ${fn:length(majors)} 个专业</div>
                        </div>
                    </div>
                    <div class="table-wrap">
                        <table class="table">
                            <thead>
                            <tr>
                                <th>专业代码</th>
                                <th>专业名称</th>
                                <th>班级数</th>
                                <th>学生数</th>
                                <th style="width:120px">操作</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${majors}" var="major">
                                <tr>
                                    <td><span class="badge badge-muted">${major.code}</span></td>
                                    <td><div class="cell-title"><c:out value="${major.name}"/></div></td>
                                    <td class="num">${major.classCount}</td>
                                    <td class="num">${major.studentCount}</td>
                                    <td>
                                        <div class="row-actions">
                                            <a class="link" href="${ctx}/major?editId=${major.id}">编辑</a>
                                            <form action="${ctx}/major" method="post" data-confirm="确定删除专业「${fn:escapeXml(major.name)}」吗？">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${major.id}">
                                                <button class="link link-danger" type="submit">删除</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty majors}">
                                <tr><td colspan="5"><div class="empty"><h3>还没有专业</h3><p>先在右侧创建第一个专业。</p></div></td></tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </section>

                <aside class="card">
                    <div class="card-head">
                        <div>
                            <h2>${empty editing ? '新增专业' : '编辑专业'}</h2>
                            <div class="card-sub">${empty editing ? '创建后即可在班级中选择' : '修改专业代码与名称'}</div>
                        </div>
                    </div>
                    <form class="form" action="${ctx}/major" method="post" novalidate>
                        <input type="hidden" name="action" value="save">
                        <input type="hidden" name="id" value="${editing.id}">

                        <div class="form-grid" style="grid-template-columns:1fr">
                            <div class="field">
                                <label for="code">专业代码<span class="required">*</span></label>
                                <input class="input ${not empty errors.code ? 'error' : ''}" id="code" name="code"
                                       value="${fn:escapeXml(editing.code)}" placeholder="例如 CS" maxlength="10">
                                <c:if test="${not empty errors.code}"><span class="error-text"><c:out value="${errors.code}"/></span></c:if>
                            </div>
                            <div class="field">
                                <label for="name">专业名称<span class="required">*</span></label>
                                <input class="input ${not empty errors.name ? 'error' : ''}" id="name" name="name"
                                       value="${fn:escapeXml(editing.name)}" placeholder="例如 计算机科学与技术" maxlength="40">
                                <c:if test="${not empty errors.name}"><span class="error-text"><c:out value="${errors.name}"/></span></c:if>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button class="btn btn-primary btn-block" type="submit">${empty editing ? '创建专业' : '保存修改'}</button>
                        </div>
                        <c:if test="${not empty editing}">
                            <a class="btn btn-ghost btn-block" style="margin-top:10px" href="${ctx}/major">取消编辑</a>
                        </c:if>
                    </form>
                </aside>
            </div>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
