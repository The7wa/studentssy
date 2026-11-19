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
                <div class="toolbar">
                    <form action="${ctx}/student" method="get">
                        <div class="search-box">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.2-3.2"/></svg>
                            <input type="text" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="搜索学号或姓名" autocomplete="off">
                        </div>
                        <select class="select" name="clazzId">
                            <option value="">全部班级</option>
                            <c:forEach items="${clazzes}" var="clazz">
                                <option value="${clazz.id}" ${clazzId eq clazz.id ? 'selected' : ''}>
                                    <c:out value="${clazz.name}"/>（${clazz.gradeYear} 级）
                                </option>
                            </c:forEach>
                        </select>
                        <select class="select" name="status">
                            <option value="">全部状态</option>
                            <option value="在读" ${status eq '在读' ? 'selected' : ''}>在读</option>
                            <option value="休学" ${status eq '休学' ? 'selected' : ''}>休学</option>
                            <option value="毕业" ${status eq '毕业' ? 'selected' : ''}>毕业</option>
                        </select>
                        <button class="btn btn-primary" type="submit">查询</button>
                        <a class="btn btn-ghost" href="${ctx}/student">重置</a>
                        <span class="spacer"></span>
                        <a class="btn btn-ghost" href="${ctx}/student?action=export&keyword=${fn:escapeXml(keyword)}&clazzId=${clazzId == null ? '' : clazzId}&status=${fn:escapeXml(status)}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m7 10 5 5 5-5"/><path d="M12 15V3"/></svg>
                            导出 CSV
                        </a>
                        <c:if test="${loginUser.admin}">
                            <a class="btn btn-primary" href="${ctx}/student?action=toAdd">新增学生</a>
                        </c:if>
                    </form>
                </div>

                <c:if test="${loginUser.admin}">
                    <details class="import-box">
                        <summary>批量导入 / 下载模板</summary>
                        <div class="import-body">
                            <div>
                                <p class="hint">按模板列顺序填写 CSV（UTF-8）：学号、姓名、性别、出生日期、班级代码、入学年份、学籍状态、手机、邮箱、家庭住址。学号即登录名，初始密码 123456。</p>
                                <a class="link" href="${ctx}/student?action=template">下载导入模板</a>
                            </div>
                            <form action="${ctx}/student" method="post" enctype="multipart/form-data" data-confirm="确定导入该文件吗？已存在的学号会被更新。">
                                <input type="hidden" name="action" value="import">
                                <input type="file" name="file" accept=".csv,text/csv" required data-filename="importFileLabel">
                                <span class="hint" id="importFileLabel">未选择文件</span>
                                <button class="btn btn-soft" type="submit">开始导入</button>
                            </form>
                        </div>
                    </details>
                </c:if>

                <div class="table-wrap">
                    <table class="table">
                        <thead>
                        <tr>
                            <th>学生</th>
                            <th>学号</th>
                            <th>班级 / 专业</th>
                            <th>入学</th>
                            <th>学籍状态</th>
                            <th>联系方式</th>
                            <th style="width:150px">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${page.items}" var="student">
                            <tr>
                                <td>
                                    <div class="cell-main">
                                        <span class="avatar ${student.female ? 'avatar-girl' : ''}"><c:out value="${student.initial}"/></span>
                                        <div class="cell-text">
                                            <div class="cell-title"><c:out value="${student.name}"/></div>
                                            <div class="cell-sub">${student.gender} · ${student.age} 岁</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="num">${student.studentNo}</td>
                                <td>
                                    <div class="cell-title"><c:out value="${student.clazzName}"/></div>
                                    <div class="cell-sub"><c:out value="${student.majorName}"/></div>
                                </td>
                                <td class="num">${student.enrollYear}</td>
                                <td>
                                    <span class="badge ${student.status eq '在读' ? 'badge-ok' : student.status eq '休学' ? 'badge-warn' : 'badge-muted'}">${student.status}</span>
                                </td>
                                <td>
                                    <div class="cell-sub">${fn:escapeXml(student.phone)}</div>
                                    <div class="cell-sub">${fn:escapeXml(student.email)}</div>
                                </td>
                                <td>
                                    <div class="row-actions">
                                        <a class="link" href="${ctx}/student?action=detail&id=${student.id}">档案</a>
                                        <c:if test="${loginUser.admin}">
                                            <a class="link" href="${ctx}/student?action=toEdit&id=${student.id}">编辑</a>
                                            <form action="${ctx}/student" method="post" data-confirm="删除后该学生的成绩和登录账号也会一并删除，确定吗？">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${student.id}">
                                                <button class="link link-danger" type="submit">删除</button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty page.items}">
                            <tr>
                                <td colspan="7">
                                    <div class="empty">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.2-3.2"/><path d="M8 11h6"/></svg>
                                        <h3>没有找到学生</h3>
                                        <p>换个关键词或筛选条件试试。</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="pager">
                    <span class="pager-info">共 ${page.total} 条，第 ${page.page} / ${page.totalPages} 页</span>
                    <c:url var="prevUrl" value="/student">
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="clazzId" value="${clazzId}"/>
                        <c:param name="status" value="${status}"/>
                        <c:param name="page" value="${page.prevPage}"/>
                    </c:url>
                    <a class="${page.hasPrev ? '' : 'disabled'}" href="${prevUrl}">上一页</a>
                    <c:forEach begin="1" end="${page.totalPages}" var="i">
                        <c:if test="${i == 1 or i == page.totalPages or (i >= page.page - 2 and i <= page.page + 2)}">
                            <c:url var="numUrl" value="/student">
                                <c:param name="keyword" value="${keyword}"/>
                                <c:param name="clazzId" value="${clazzId}"/>
                                <c:param name="status" value="${status}"/>
                                <c:param name="page" value="${i}"/>
                            </c:url>
                            <c:choose>
                                <c:when test="${i == page.page}"><span class="current">${i}</span></c:when>
                                <c:otherwise><a href="${numUrl}">${i}</a></c:otherwise>
                            </c:choose>
                        </c:if>
                    </c:forEach>
                    <c:url var="nextUrl" value="/student">
                        <c:param name="keyword" value="${keyword}"/>
                        <c:param name="clazzId" value="${clazzId}"/>
                        <c:param name="status" value="${status}"/>
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
