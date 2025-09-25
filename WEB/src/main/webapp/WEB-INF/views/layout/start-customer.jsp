<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="ko">
<head>
  <jsp:include page="/WEB-INF/views/includes/head.jsp"/>
  <title><c:out value="${empty param.pageTitle ? '소비자 메인' : param.pageTitle}"/></title>

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
  <div class="brand"><c:out value="${empty param.brand ? '미정' : param.brand}"/></div>
  <div class="user">
    <c:out value="${sessionScope.customerName != null ? sessionScope.customerName : '고객'}"/>님 ·
    <a href="${pageContext.request.contextPath}/logout" style="color:#EF4444;text-decoration:none;margin-left:6px;">로그아웃</a>
  </div>
</header>

<div class="container">
  <main class="main">
