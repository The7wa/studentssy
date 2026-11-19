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

            <div class="split">
                <section class="card" style="overflow:hidden">
                    <section class="profile-hero" style="border:none;border-radius:0">
                        <span class="avatar avatar-lg">${user.initial}</span>
                        <div style="min-width:0">
                            <div class="profile-name"><c:out value="${user.realName}"/></div>
                            <div class="profile-sub">${user.username} · ${user.roleName}</div>
                            <div class="profile-chips">
                                <span class="badge ${user.enabled ? 'badge-ok' : 'badge-danger'}">${user.enabled ? '账号正常' : '账号已停用'}</span>
                                <c:if test="${not empty student}">
                                    <span class="badge"><c:out value="${student.clazzName}"/></span>
                                    <span class="badge">${student.studentNo}</span>
                                </c:if>
                            </div>
                        </div>
                    </section>

                    <div class="card-body">
                        <div class="meta-grid">
                            <div class="meta-item"><div class="meta-label">登录名</div><div class="meta-value">${user.username}</div></div>
                            <div class="meta-item"><div class="meta-label">角色</div><div class="meta-value">${user.roleName}</div></div>
                            <div class="meta-item"><div class="meta-label">手机号</div><div class="meta-value">${empty user.phone ? '未填写' : fn:escapeXml(user.phone)}</div></div>
                            <div class="meta-item"><div class="meta-label">邮箱</div><div class="meta-value">${empty user.email ? '未填写' : fn:escapeXml(user.email)}</div></div>
                            <div class="meta-item"><div class="meta-label">创建时间</div><div class="meta-value"><fmt:formatDate value="${user.createTime}" pattern="yyyy-MM-dd HH:mm"/></div></div>
                            <div class="meta-item"><div class="meta-label">最后登录</div><div class="meta-value"><fmt:formatDate value="${user.lastLoginTime}" pattern="yyyy-MM-dd HH:mm"/></div></div>
                        </div>

                        <c:if test="${not empty student}">
                            <div style="margin-top:22px;padding-top:20px;border-top:1px solid var(--line)">
                                <div class="card-sub" style="margin-bottom:14px">学生档案</div>
                                <div class="meta-grid">
                                    <div class="meta-item"><div class="meta-label">学号</div><div class="meta-value">${student.studentNo}</div></div>
                                    <div class="meta-item"><div class="meta-label">专业班级</div><div class="meta-value"><c:out value="${student.majorName}"/> · <c:out value="${student.clazzName}"/></div></div>
                                    <div class="meta-item"><div class="meta-label">学籍状态</div><div class="meta-value">${student.status}</div></div>
                                    <div class="meta-item"><div class="meta-label">平均分 / 班级排名</div><div class="meta-value"><fmt:formatNumber value="${avgScore}" pattern="0.0"/> 分 · 第 ${rank} / ${classSize} 名</div></div>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </section>

                <aside>
                    <section class="card">
                        <div class="card-head">
                            <div><h2>联系方式</h2><div class="card-sub">修改后立即生效</div></div>
                        </div>
                        <form class="form" action="${ctx}/profile" method="post" novalidate>
                            <input type="hidden" name="action" value="profile">
                            <div class="form-grid" style="grid-template-columns:1fr">
                                <div class="field">
                                    <label for="phone">手机号</label>
                                    <input class="input" id="phone" name="phone" value="${fn:escapeXml(user.phone)}" placeholder="选填" maxlength="20">
                                </div>
                                <div class="field">
                                    <label for="email">邮箱</label>
                                    <input class="input" id="email" name="email" type="email" value="${fn:escapeXml(user.email)}" placeholder="选填" maxlength="60">
                                </div>
                            </div>
                            <div class="form-actions">
                                <button class="btn btn-primary" type="submit">保存联系方式</button>
                            </div>
                        </form>
                    </section>

                    <section class="card" style="margin-top:20px">
                        <div class="card-head">
                            <div><h2>修改密码</h2><div class="card-sub">建议定期更换</div></div>
                        </div>
                        <form class="form" action="${ctx}/profile" method="post" novalidate>
                            <input type="hidden" name="action" value="password">
                            <div class="form-grid" style="grid-template-columns:1fr">
                                <div class="field">
                                    <label for="oldPassword">原密码<span class="required">*</span></label>
                                    <input class="input" id="oldPassword" name="oldPassword" type="password" placeholder="当前密码">
                                </div>
                                <div class="field">
                                    <label for="newPassword">新密码<span class="required">*</span></label>
                                    <input class="input" id="newPassword" name="newPassword" type="password" placeholder="6-32 位">
                                </div>
                                <div class="field">
                                    <label for="confirmPassword">确认新密码<span class="required">*</span></label>
                                    <input class="input" id="confirmPassword" name="confirmPassword" type="password" placeholder="再输入一次">
                                </div>
                            </div>
                            <div class="form-actions">
                                <button class="btn btn-primary" type="submit">更新密码</button>
                            </div>
                        </form>
                    </section>
                </aside>
            </div>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
