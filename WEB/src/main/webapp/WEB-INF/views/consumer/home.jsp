<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>소비자 메인</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    :root{
      --bg:#F5F7FB; --panel:#FFFFFF; --line:#E5E7EB; --text:#111827; --muted:#6B7280;
      --brand:#2563EB; --brand-dark:#1E40AF;
      --chip:#F3F4F6;
    }
    *{box-sizing:border-box}
    body{margin:0;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;background:var(--bg);color:var(--text)}
    header{position:sticky;top:0;background:#fff;border-bottom:1px solid var(--line);padding:14px 20px;display:flex;align-items:center;justify-content:space-between}
    .brand{font-weight:800;color:var(--brand-dark)}
    .user{color:var(--muted);font-size:14px}
    .container{max-width:1080px;margin:20px auto;padding:0 20px}
    .actions{display:flex;gap:10px;flex-wrap:wrap;margin:12px 0 20px}
    .btn{display:inline-block;padding:10px 14px;border-radius:8px;border:1px dashed #D1D5DB;background:#F9FAFB;color:#374151;text-decoration:none}
    .btn.primary{border-style:solid;border-color:var(--brand);background:#EFF6FF;color:var(--brand)}
    .grid-3{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}
    .card{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:16px}
    .card h3{margin:0 0 8px;font-size:16px}
    .muted{color:var(--muted);font-size:13px}
    .list{display:flex;flex-direction:column;gap:10px;margin-top:8px}
    .item{background:#fff;border:1px solid var(--line);border-radius:10px;padding:12px;display:flex;align-items:center;justify-content:space-between}
    .chip{background:var(--chip);border-radius:999px;padding:4px 8px;font-size:12px;color:#374151}
    .links a{margin-left:8px;text-decoration:none;color:var(--brand)}
    .links a:hover{color:var(--brand-dark)}
    footer{text-align:center;color:#9CA3AF;font-size:12px;margin:26px 0}
    @media (max-width:900px){ .grid-3{grid-template-columns:1fr} }
  </style>
</head>
<body>
<header>
  <div class="brand">미정</div>
  <div class="user">
    <!-- TODO: 세션의 사용자명 바인딩 -->
    홍길동님 ·
    <a href="${pageContext.request.contextPath}/logout" style="color:#EF4444;text-decoration:none;margin-left:6px;">로그아웃</a>
  </div>
</header>

<div class="container">
  <!-- 상단 퀵액션 -->
  <div class="actions">
    <a class="btn primary" href="${pageContext.request.contextPath}/reservation/new">예약하기</a>
    <a class="btn" href="${pageContext.request.contextPath}/reservation/list">내 예약</a>
    <a class="btn" href="${pageContext.request.contextPath}/notifications">알림</a>
    <a class="btn" href="${pageContext.request.contextPath}/support">고객센터</a>
  </div>

  <!-- 요약 카드 -->
  <div class="grid-3" style="margin-bottom:16px;">
    <div class="card">
      <h3>다음 예약</h3>
      <div class="muted">예: 09/28(일) 14:00 · 강남 이동점포</div>
    </div>
    <div class="card">
      <h3>내 등급/혜택</h3>
      <div class="muted">예: Silver · 우선예약 1회</div>
    </div>
    <div class="card">
      <h3>공지사항</h3>
      <div class="muted">예: 명절 기간 운영시간 안내</div>
    </div>
  </div>

  <!-- 내 예약 목록 -->
  <div class="card" style="margin-bottom:16px;">
    <h3>내 예약</h3>
    <div class="list">
      <div class="item">
        <div>
          <strong>09/28(일) 14:00</strong> · 강남 이동점포
          <span class="chip">확정</span>
        </div>
        <div class="links">
          <a href="${pageContext.request.contextPath}/reservation/1">상세</a>
          <a href="${pageContext.request.contextPath}/reservation/1/cancel">취소</a>
        </div>
      </div>
      <div class="item">
        <div>
          <strong>10/05(일) 10:30</strong> · 판교 이동점포
          <span class="chip">대기</span>
        </div>
        <div class="links">
          <a href="${pageContext.request.contextPath}/reservation/2">상세</a>
          <a href="${pageContext.request.contextPath}/reservation/2/cancel">취소</a>
        </div>
      </div>
    </div>
  </div>

  <!-- 알림/메시지 -->
  <div class="card">
    <h3>알림</h3>
    <ul class="muted" style="margin:8px 0 0 18px;">
      <li>서류 준비 안내: 신분증, 위임장</li>
      <li>위치 변경 공지: 강남점 → 역삼점</li>
      <li>예약 24시간 전 알림이 발송됩니다.</li>
    </ul>
  </div>

  <footer>© 미정</footer>
</div>
</body>
</html>
