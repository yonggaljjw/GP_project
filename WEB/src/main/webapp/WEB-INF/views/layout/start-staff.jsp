<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="ko">
<head>
  <jsp:include page="/WEB-INF/views/includes/head.jsp"/>
  <title><c:out value="${empty param.pageTitle ? '이동점포 · 직원 대시보드' : param.pageTitle}"/></title>

    <link rel="stylesheet" href="<c:url value='/css/base.css'/>?v=${applicationScope.staticVer}">
    <link rel="stylesheet" href="<c:url value='/css/layout.css'/>?v=${applicationScope.staticVer}">
    <link rel="stylesheet" href="<c:url value='/css/components.css'/>?v=${applicationScope.staticVer}">
    <c:if test="${not empty param.pageCss}">
      <link rel="stylesheet" href="<c:url value='${param.pageCss}'/>?v=${applicationScope.staticVer}">
    </c:if>


  <script>
    window.ctx='${pageContext.request.contextPath}';
    <c:if test="${not empty _csrf}">window.csrfToken='${_csrf.token}';</c:if>
  </script>
</head>
<body>
<header>
  <div class="brand"><c:out value="${empty param.brand ? '이동점포 · 직원 대시보드' : param.brand}"/></div>
  <div class="user">
    <c:out value="${sessionScope.staffName}"/> 님
    <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
  </div>
</header>

<div class="shell">
  <aside class="side">
    <h4>메뉴</h4>
    <nav class="nav">
      <a class="${param.active eq 'dashboard' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/home">대시보드</a>
      <a class="${param.active eq 'routes'    ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/routes">경로 추천</a>
      <a class="${param.active eq 'alerts'    ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/alerts">알림 관리</a>
      <a class="${param.active eq 'aftercare' ? 'active' : ''}" href="${pageContext.request.contextPath}/staff/aftercare">사후 관리</a>
    </nav>
  </aside>

  <main class="main">
