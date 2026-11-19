<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>登录 · 学籍通</title>
    <link rel="stylesheet" href="${ctx}/assets/css/app.css">
</head>
<body class="auth-page">
<div class="auth-shell">
    <aside class="auth-aside">
        <div class="auth-aside-top">
            <a class="brand light" href="${ctx}/login.jsp" style="display:flex;align-items:center;gap:12px;color:#fff">
                <span class="brand-mark">学</span>
                <span class="brand-text">
                    <strong>学籍通</strong>
                    <small>STUDENT MANAGEMENT</small>
                </span>
            </a>
        </div>

        <div class="auth-aside-copy">
            <span class="eyebrow">CAMPUS DATA · ONE PLACE</span>
            <h1>把每一个学生，<br>放在<em>清晰</em>的档案里。</h1>
            <p>学籍通把学生档案、班级专业、课程与成绩集中到一套系统里。管理员统览全局，教师专注教学，学生随时查看自己的成长记录。</p>

            <div class="auth-visual">
                <div><strong>档案</strong><small>学生信息集中维护</small></div>
                <div><strong>成绩</strong><small>批量录入与统计</small></div>
                <div><strong>班级</strong><small>专业 / 班级分层</small></div>
                <div><strong>权限</strong><small>管理员 / 教师 / 学生</small></div>
            </div>

            <div class="auth-points">
                <span><i></i> 分页与检索</span>
                <span><i></i> 成绩看板</span>
                <span><i></i> CSV 导入导出</span>
            </div>
        </div>

        <div class="auth-aside-bottom">
            <span>JSP · SERVLET · MYSQL</span>
            <span>© 2026 学籍通</span>
        </div>
    </aside>

    <main class="auth-main">
        <div class="auth-card">
            <span class="auth-kicker">WELCOME BACK</span>
            <h2>欢迎回来</h2>
            <p class="auth-sub">使用账号 / 学号登录学生管理系统</p>

            <c:if test="${param.logout eq '1'}">
                <div class="auth-alert info">你已安全退出登录。</div>
            </c:if>

            <c:if test="${dbOk eq false}">
                <div class="auth-alert">
                    <span>!</span>
                    <span>数据库连接失败：请确认 MySQL 已启动，并检查 src/db.properties 中的账号密码。</span>
                </div>
            </c:if>

            <c:if test="${not empty errors.login}">
                <div class="auth-alert">
                    <span>!</span>
                    <span><c:out value="${errors.login}"/></span>
                </div>
            </c:if>

            <form class="auth-form" action="${ctx}/login" method="post" novalidate>
                <div class="field">
                    <label for="username">用户名 / 学号</label>
                    <input class="input ${not empty errors.username ? 'error' : ''}"
                           id="username" name="username" type="text"
                           value="${fn:escapeXml(username)}"
                           placeholder="例如 admin 或 20230101" autocomplete="username" autofocus>
                    <c:if test="${not empty errors.username}">
                        <span class="error-text"><c:out value="${errors.username}"/></span>
                    </c:if>
                </div>

                <div class="field">
                    <label for="password">密码</label>
                    <div class="password-wrap">
                        <input class="input ${not empty errors.password ? 'error' : ''}"
                               id="password" name="password" type="password"
                               placeholder="请输入密码" autocomplete="current-password">
                        <button type="button" class="toggle-password" data-toggle-password="password">显示</button>
                    </div>
                    <c:if test="${not empty errors.password}">
                        <span class="error-text"><c:out value="${errors.password}"/></span>
                    </c:if>
                </div>

                <button type="submit" class="btn btn-primary auth-submit">登 录</button>
            </form>

            <div class="demo-hint">
                演示账号<br>
                管理员：<code>admin</code> / <code>admin123</code><br>
                教师：<code>t_zhangwei</code> / <code>123456</code><br>
                学生：<code>20230101</code> / <code>123456</code>
            </div>

            <p class="auth-mini-footer">© 2026 学籍通 · JSP + Servlet + MySQL 课程设计</p>
        </div>
    </main>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
