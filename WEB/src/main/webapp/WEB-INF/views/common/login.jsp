<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>로그인</title>
  <style>
    body { font-family:"Noto Sans KR",sans-serif; display:flex; justify-content:center; align-items:center; height:100vh; background:#F9FAFB; }
    .login-box {
      background:#fff; padding:32px; border:1px solid #e5e7eb; border-radius:8px;
      width:320px; text-align:center; box-shadow:0 4px 10px rgba(0,0,0,0.05);
    }
    h2 { margin-bottom:20px; }
    input { width:100%; padding:10px; margin-bottom:12px; border:1px solid #ccc; border-radius:6px; }
    button {
      width:100%; padding:10px; background:#2563EB; color:#fff;
      border:none; border-radius:6px; font-weight:600; cursor:pointer;
    }
    button:hover { background:#1E40AF; }
    p { margin-top:12px; font-size:13px; color:#888; }
  </style>
</head>
<body>
  <div class="login-box">
    <h2>로그인</h2>
    <form action="${pageContext.request.contextPath}/perform_login" method="post">
      <input type="text" name="username" placeholder="아이디" required />
      <input type="password" name="password" placeholder="비밀번호" required />
      <button type="submit">로그인</button>
    </form>

    <c:if test="${param.error != null}">
      <p style="color:red;">로그인 실패. 다시 시도하세요.</p>
    </c:if>
    <c:if test="${param.logout != null}">
      <p style="color:green;">로그아웃 완료.</p>
    </c:if>
  </div>
</body>
</html>