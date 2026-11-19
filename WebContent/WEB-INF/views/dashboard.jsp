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

            <c:choose>
                <%-- ================= 管理员看板 ================= --%>
                <c:when test="${loginUser.admin}">
                    <section class="welcome">
                        <div class="welcome-copy">
                            <span class="welcome-kicker">CAMPUS OVERVIEW</span>
                            <h2>你好，<c:out value="${loginUser.displayName}"/>，今天也把学籍理得清清楚楚。</h2>
                            <p>这里汇总了全校学生、班级、课程与成绩的关键数据。你可以直接进入任意模块维护档案、录入成绩或管理账号。</p>
                            <div class="welcome-meta">
                                <span>学生 <b>${studentCount}</b> 人</span>
                                <span>班级 <b>${clazzCount}</b> 个</span>
                                <span>课程 <b>${courseCount}</b> 门</span>
                                <span>教师 <b>${teacherCount}</b> 人</span>
                            </div>
                        </div>
                        <div class="welcome-figure">
                            <div><strong><fmt:formatNumber value="${avgScore}" pattern="0.0"/></strong><small>全校平均分</small></div>
                            <div><strong><fmt:formatNumber value="${passRate}" pattern="0.0"/>%</strong><small>整体及格率</small></div>
                        </div>
                    </section>

                    <div class="stat-grid">
                        <div class="stat-card">
                            <div class="stat-icon tone-blue">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            </div>
                            <div>
                                <div class="stat-value">${studentCount}</div>
                                <div class="stat-label">在册学生</div>
                                <div class="stat-hint">含在读、休学与毕业</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon tone-green">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            </div>
                            <div>
                                <div class="stat-value">${clazzCount}</div>
                                <div class="stat-label">班级数量</div>
                                <div class="stat-hint">覆盖 ${courseCount} 门课程</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon tone-violet">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2Z"/></svg>
                            </div>
                            <div>
                                <div class="stat-value">${courseCount}</div>
                                <div class="stat-label">开设课程</div>
                                <div class="stat-hint">按学期组织成绩</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon tone-amber">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/><path d="m9 12 2 2 4-4"/></svg>
                            </div>
                            <div>
                                <div class="stat-value">${teacherCount}</div>
                                <div class="stat-label">任课教师</div>
                                <div class="stat-hint">可在用户管理中维护</div>
                            </div>
                        </div>
                    </div>

                    <div class="chart-grid">
                        <section class="card">
                            <div class="card-head">
                                <div>
                                    <h2>成绩分段分布</h2>
                                    <div class="card-sub">全部学期成绩记录</div>
                                </div>
                                <div class="card-actions">
                                    <a class="btn btn-ghost btn-sm" href="${ctx}/score">查看成绩</a>
                                </div>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty scoreBands or scoreBands[0].value + scoreBands[1].value + scoreBands[2].value + scoreBands[3].value + scoreBands[4].value == 0}">
                                        <div class="empty">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 3v18h18"/><path d="M7 15l4-4 3 3 5-6"/></svg>
                                            <h3>还没有成绩数据</h3>
                                            <p>录入成绩后，这里会自动生成分布图。</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="bar-list">
                                            <c:forEach items="${scoreBands}" var="band" varStatus="st">
                                                <div class="bar-row">
                                                    <span class="bar-label">${band.label}</span>
                                                    <span class="bar-track">
                                                        <span class="bar-fill ${st.index == 0 ? 'green' : st.index == 4 ? 'red' : st.index == 3 ? 'amber' : ''}"
                                                              style="width:${band.percent}%"></span>
                                                    </span>
                                                    <span class="bar-value">${band.value} 人</span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </section>

                        <section class="card">
                            <div class="card-head">
                                <div>
                                    <h2>性别构成</h2>
                                    <div class="card-sub">全部在册学生</div>
                                </div>
                            </div>
                            <div class="card-body">
                                <c:set var="girlPct" value="${studentCount > 0 ? genderStats['女'] * 100 / studentCount : 0}"/>
                                <div class="donut-wrap">
                                    <div class="donut" style="--girl:${girlPct}%">
                                        <div class="donut-center">
                                            <strong>${studentCount}</strong>
                                            <small>学生总数</small>
                                        </div>
                                    </div>
                                    <div class="legend">
                                        <div class="legend-item">
                                            <span class="dot"></span>
                                            <span>男生</span>
                                            <strong>${genderStats['男']}</strong>
                                            <small><fmt:formatNumber value="${studentCount > 0 ? genderStats['男'] * 100 / studentCount : 0}" pattern="0"/>%</small>
                                        </div>
                                        <div class="legend-item">
                                            <span class="dot pink"></span>
                                            <span>女生</span>
                                            <strong>${genderStats['女']}</strong>
                                            <small><fmt:formatNumber value="${girlPct}" pattern="0"/>%</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </section>
                    </div>

                    <div class="grid-2" style="margin-top:20px">
                        <section class="card">
                            <div class="card-head">
                                <div>
                                    <h2>班级人数</h2>
                                    <div class="card-sub">人数最多的 6 个班级</div>
                                </div>
                                <div class="card-actions">
                                    <a class="btn btn-ghost btn-sm" href="${ctx}/clazz">班级管理</a>
                                </div>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty classStats}">
                                        <div class="empty"><h3>暂无班级数据</h3><p>先去班级管理里创建班级。</p></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="bar-list">
                                            <c:forEach items="${classStats}" var="item">
                                                <div class="bar-row">
                                                    <span class="bar-label" title="${item.label}"><c:out value="${item.label}"/></span>
                                                    <span class="bar-track"><span class="bar-fill" style="width:${item.percent}%"></span></span>
                                                    <span class="bar-value">${item.value} 人</span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </section>

                        <section class="card">
                            <div class="card-head">
                                <div>
                                    <h2>课程平均分</h2>
                                    <div class="card-sub">按全部成绩记录统计</div>
                                </div>
                                <div class="card-actions">
                                    <a class="btn btn-ghost btn-sm" href="${ctx}/score">成绩管理</a>
                                </div>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty courseStats}">
                                        <div class="empty"><h3>暂无课程数据</h3><p>先去课程管理里创建课程。</p></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="bar-list">
                                            <c:forEach items="${courseStats}" var="course" begin="0" end="5">
                                                <div class="mini-course">
                                                    <div class="mini-course-head">
                                                        <span class="name"><c:out value="${course.courseName}"/></span>
                                                        <span class="teacher"><c:out value="${course.teacherName}"/></span>
                                                        <span class="avg"><fmt:formatNumber value="${course.avgScore}" pattern="0.0"/> 分</span>
                                                    </div>
                                                    <span class="bar-track"><span class="bar-fill" style="width:${course.avgScore}%"></span></span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </section>
                    </div>

                    <section class="card" style="margin-top:20px">
                        <div class="card-head">
                            <div>
                                <h2>最近录入的学生</h2>
                                <div class="card-sub">最新建立的 5 份学生档案</div>
                            </div>
                            <div class="card-actions">
                                <a class="btn btn-primary btn-sm" href="${ctx}/student?action=toAdd">新增学生</a>
                                <a class="btn btn-ghost btn-sm" href="${ctx}/student">全部学生</a>
                            </div>
                        </div>
                        <div class="table-wrap">
                            <table class="table">
                                <thead>
                                <tr>
                                    <th>学生</th>
                                    <th>学号</th>
                                    <th>班级</th>
                                    <th>入学年份</th>
                                    <th>状态</th>
                                    <th style="width:90px">操作</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach items="${recentStudents}" var="student">
                                    <tr>
                                        <td>
                                            <div class="cell-main">
                                                <span class="avatar ${student.female ? 'avatar-girl' : ''}"><c:out value="${student.initial}"/></span>
                                                <div class="cell-text">
                                                    <div class="cell-title"><c:out value="${student.name}"/></div>
                                                    <div class="cell-sub"><c:out value="${student.majorName}"/></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="num">${student.studentNo}</td>
                                        <td><c:out value="${student.clazzName}"/></td>
                                        <td class="num">${student.enrollYear}</td>
                                        <td>
                                            <span class="badge ${student.status eq '在读' ? 'badge-ok' : student.status eq '休学' ? 'badge-warn' : 'badge-muted'}">${student.status}</span>
                                        </td>
                                        <td><a class="link" href="${ctx}/student?action=detail&id=${student.id}">查看</a></td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </c:when>

                <%-- ================= 教师看板 ================= --%>
                <c:when test="${loginUser.teacher}">
                    <section class="welcome">
                        <div class="welcome-copy">
                            <span class="welcome-kicker">TEACHING DESK</span>
                            <h2>你好，<c:out value="${loginUser.displayName}"/> 老师，今天有 ${courseCount} 门课需要关注。</h2>
                            <p>你可以在「成绩管理」里按课程和班级批量录入成绩，也可以查看所授课程的平均分与及格率。</p>
                            <div class="welcome-meta">
                                <span>我的课程 <b>${courseCount}</b> 门</span>
                                <span>覆盖学生 <b>${studentCount}</b> 人</span>
                            </div>
                        </div>
                        <div class="welcome-figure">
                            <div><strong><fmt:formatNumber value="${avgScore}" pattern="0.0"/></strong><small>我的课程平均分</small></div>
                            <div><strong><fmt:formatNumber value="${passRate}" pattern="0.0"/>%</strong><small>我的课程及格率</small></div>
                        </div>
                    </section>

                    <div class="stat-grid">
                        <div class="stat-card">
                            <div class="stat-icon tone-blue">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2Z"/></svg>
                            </div>
                            <div>
                                <div class="stat-value">${courseCount}</div>
                                <div class="stat-label">我的课程</div>
                                <div class="stat-hint">由管理员分配</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon tone-green">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            </div>
                            <div>
                                <div class="stat-value">${studentCount}</div>
                                <div class="stat-label">覆盖学生</div>
                                <div class="stat-hint">已有成绩记录的学生</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon tone-violet">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2 2 7l10 5 10-5-10-5Z"/><path d="m2 17 10 5 10-5"/><path d="m2 12 10 5 10-5"/></svg>
                            </div>
                            <div>
                                <div class="stat-value"><fmt:formatNumber value="${avgScore}" pattern="0.0"/></div>
                                <div class="stat-label">平均分</div>
                                <div class="stat-hint">我授课程全部成绩</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon tone-amber">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 3v18h18"/><rect x="7" y="12" width="3" height="6" rx="0.8"/><rect x="12" y="8" width="3" height="10" rx="0.8"/><rect x="17" y="5" width="3" height="13" rx="0.8"/></svg>
                            </div>
                            <div>
                                <div class="stat-value"><fmt:formatNumber value="${passRate}" pattern="0.0"/>%</div>
                                <div class="stat-label">及格率</div>
                                <div class="stat-hint">我授课程全部成绩</div>
                            </div>
                        </div>
                    </div>

                    <div class="grid-2">
                        <section class="card">
                            <div class="card-head">
                                <div>
                                    <h2>我的课程</h2>
                                    <div class="card-sub">点击课程可直接进入成绩录入</div>
                                </div>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${empty myCourses}">
                                        <div class="empty"><h3>还没有分配课程</h3><p>请联系管理员为你分配课程。</p></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="bar-list">
                                            <c:forEach items="${myCourses}" var="course">
                                                <div class="mini-course">
                                                    <div class="mini-course-head">
                                                        <span class="name"><c:out value="${course.name}"/></span>
                                                        <span class="teacher">${course.code} · ${course.term} · ${course.scoreCount} 人</span>
                                                        <span class="avg">均分 <fmt:formatNumber value="${course.avgScore}" pattern="0.0"/></span>
                                                    </div>
                                                    <span class="bar-track"><span class="bar-fill" style="width:${course.avgScore}%"></span></span>
                                                    <div style="margin-top:6px">
                                                        <a class="link" href="${ctx}/score?action=entry&courseId=${course.id}&term=${course.term}">去录入成绩 →</a>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </section>

                        <section class="card">
                            <div class="card-head">
                                <div>
                                    <h2>最近成绩</h2>
                                    <div class="card-sub">我授课程的最新记录</div>
                                </div>
                                <div class="card-actions">
                                    <a class="btn btn-ghost btn-sm" href="${ctx}/score">全部成绩</a>
                                </div>
                            </div>
                            <div class="table-wrap">
                                <table class="table">
                                    <thead>
                                    <tr>
                                        <th>学生</th>
                                        <th>课程</th>
                                        <th>成绩</th>
                                        <th>学期</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach items="${recentScores}" var="score">
                                        <tr>
                                            <td>
                                                <div class="cell-title"><c:out value="${score.studentName}"/></div>
                                                <div class="cell-sub">${score.studentNo}</div>
                                            </td>
                                            <td><c:out value="${score.courseName}"/></td>
                                            <td>
                                                <span class="badge ${score.levelClass}">
                                                    <fmt:formatNumber value="${score.score}" pattern="0.0"/>
                                                </span>
                                            </td>
                                            <td class="cell-sub">${score.term}</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty recentScores}">
                                        <tr><td colspan="4" class="cell-sub" style="text-align:center;padding:30px">还没有成绩记录</td></tr>
                                    </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </div>
                </c:when>

                <%-- ================= 学生看板 ================= --%>
                <c:otherwise>
                    <c:choose>
                        <c:when test="${empty student}">
                            <section class="card">
                                <div class="empty">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16h.01"/></svg>
                                    <h3>账号尚未关联学生档案</h3>
                                    <p>请联系管理员把你的登录账号关联到学生记录。</p>
                                </div>
                            </section>
                        </c:when>
                        <c:otherwise>
                            <section class="welcome">
                                <div class="welcome-copy">
                                    <span class="welcome-kicker">MY CAMPUS</span>
                                    <h2>你好，<c:out value="${student.name}"/>，这是你的学习档案。</h2>
                                    <p>
                                        <c:out value="${student.majorName}"/> · <c:out value="${student.clazzName}"/> ·
                                        ${student.enrollYear} 级
                                    </p>
                                    <div class="welcome-meta">
                                        <span>班级排名 <b>${rank}</b> / ${classSize}</span>
                                        <span>已修课程 <b>${scoreCount}</b> 门</span>
                                        <span>及格 <b>${passCount}</b> 门</span>
                                    </div>
                                </div>
                                <div class="welcome-figure">
                                    <div><strong><fmt:formatNumber value="${avgScore}" pattern="0.0"/></strong><small>平均分</small></div>
                                    <div><strong>${rank}</strong><small>班级排名</small></div>
                                </div>
                            </section>

                            <div class="stat-grid">
                                <div class="stat-card">
                                    <div class="stat-icon tone-blue">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2Z"/></svg>
                                    </div>
                                    <div>
                                        <div class="stat-value">${scoreCount}</div>
                                        <div class="stat-label">已修课程</div>
                                        <div class="stat-hint">有成绩记录的课程</div>
                                    </div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-icon tone-green">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2 2 7l10 5 10-5-10-5Z"/><path d="m2 17 10 5 10-5"/><path d="m2 12 10 5 10-5"/></svg>
                                    </div>
                                    <div>
                                        <div class="stat-value"><fmt:formatNumber value="${avgScore}" pattern="0.0"/></div>
                                        <div class="stat-label">平均分</div>
                                        <div class="stat-hint">全部课程平均</div>
                                    </div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-icon tone-violet">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M8 21h8M12 17v4"/><path d="M7 4h10v6a5 5 0 0 1-10 0V4Z"/><path d="M17 5h3v2a3 3 0 0 1-3 3"/><path d="M7 5H4v2a3 3 0 0 0 3 3"/></svg>
                                    </div>
                                    <div>
                                        <div class="stat-value">${rank}</div>
                                        <div class="stat-label">班级排名</div>
                                        <div class="stat-hint">共 ${classSize} 人</div>
                                    </div>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-icon tone-amber">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
                                    </div>
                                    <div>
                                        <div class="stat-value">${passCount}</div>
                                        <div class="stat-label">及格课程</div>
                                        <div class="stat-hint">成绩 ≥ 60 分</div>
                                    </div>
                                </div>
                            </div>

                            <div class="grid-2">
                                <section class="card">
                                    <div class="card-head">
                                        <div>
                                            <h2>我的成绩</h2>
                                            <div class="card-sub">按学期倒序</div>
                                        </div>
                                        <div class="card-actions">
                                            <a class="btn btn-ghost btn-sm" href="${ctx}/score?action=my">成绩明细</a>
                                        </div>
                                    </div>
                                    <div class="table-wrap">
                                        <table class="table">
                                            <thead>
                                            <tr>
                                                <th>课程</th>
                                                <th>学期</th>
                                                <th>成绩</th>
                                                <th>等级</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach items="${scores}" var="score" begin="0" end="5">
                                                <tr>
                                                    <td><div class="cell-title"><c:out value="${score.courseName}"/></div></td>
                                                    <td class="cell-sub">${score.term}</td>
                                                    <td class="num"><fmt:formatNumber value="${score.score}" pattern="0.0"/></td>
                                                    <td><span class="badge ${score.levelClass}">${score.level}</span></td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty scores}">
                                                <tr><td colspan="4" class="cell-sub" style="text-align:center;padding:30px">还没有成绩记录</td></tr>
                                            </c:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </section>

                                <section class="card">
                                    <div class="card-head">
                                        <div>
                                            <h2>我的档案</h2>
                                            <div class="card-sub">如需修改请联系教务处</div>
                                        </div>
                                        <div class="card-actions">
                                            <a class="btn btn-ghost btn-sm" href="${ctx}/profile">个人中心</a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="meta-grid">
                                            <div class="meta-item"><div class="meta-label">学号</div><div class="meta-value">${student.studentNo}</div></div>
                                            <div class="meta-item"><div class="meta-label">姓名</div><div class="meta-value"><c:out value="${student.name}"/></div></div>
                                            <div class="meta-item"><div class="meta-label">性别</div><div class="meta-value">${student.gender}</div></div>
                                            <div class="meta-item"><div class="meta-label">年龄</div><div class="meta-value">${student.age} 岁</div></div>
                                            <div class="meta-item"><div class="meta-label">专业</div><div class="meta-value"><c:out value="${student.majorName}"/></div></div>
                                            <div class="meta-item"><div class="meta-label">班级</div><div class="meta-value"><c:out value="${student.clazzName}"/></div></div>
                                            <div class="meta-item"><div class="meta-label">入学年份</div><div class="meta-value">${student.enrollYear}</div></div>
                                            <div class="meta-item"><div class="meta-label">学籍状态</div><div class="meta-value"><span class="badge ${student.status eq '在读' ? 'badge-ok' : student.status eq '休学' ? 'badge-warn' : 'badge-muted'}">${student.status}</span></div></div>
                                        </div>
                                    </div>
                                </section>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
