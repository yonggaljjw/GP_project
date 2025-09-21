<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>이동점포 예약 서비스</title>
  <style>
    body { font-family:"Noto Sans KR",sans-serif; text-align:center; margin:80px auto; }
    h1 { font-size:28px; margin-bottom:16px; }
    p { color:#555; margin-bottom:24px; }
    a {
      display:inline-block; margin:0 8px; padding:10px 20px;
      border-radius:6px; text-decoration:none; font-weight:600;
    }
    .btn-primary { background:#2563EB; color:#fff; }
    .btn-primary:hover { background:#1E40AF; }
    .btn-outline { border:1px solid #2563EB; color:#2563EB; }
    .btn-outline:hover { background:#EFF6FF; }
  </style>
</head>
<body>
  <h1>이동점포 예약 서비스</h1>
  <p>고객은 간편하게 예약, 직원은 손쉽게 관리</p>
  <a class="btn-primary" href="${pageContext.request.contextPath}/login">로그인</a>
  <a class="btn-outline" href="${pageContext.request.contextPath}/signup">회원가입</a>
</body>
</html>
