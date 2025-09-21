<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>직원 홈</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    :root{
      --bg:#F5F7FB; --panel:#FFFFFF; --line:#E5E7EB; --text:#111827; --muted:#6B7280;
      --brand:#2563EB; --brand-dark:#1E40AF;
      --chip:#EEF2FF; --chip-text:#3730A3; --danger:#EF4444; --ok:#16A34A; --warn:#F59E0B;
    }
    *{ box-sizing:border-box }
    body{ margin:0; font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif; background:var(--bg); color:var(--text) }
    header{ position:sticky; top:0; z-index:10; background:#fff; border-bottom:1px solid var(--line);
            display:flex; align-items:center; justify-content:space-between; padding:14px 20px }
    .brand{ font-weight:800; color:var(--brand-dark) }
    .user{ color:var(--muted); font-size:14px }
    .container{ max-width:1200px; margin:20px auto; padding:0 20px }
    .actions{ display:flex; gap:10px; flex-wrap:wrap; margin:12px 0 20px }
    .btn{ display:inline-block; padding:10px 14px; border-radius:8px; text-decoration:none; font-weight:600;
          border:1px solid var(--line); background:#fff; color:#374151 }
    .btn.primary{ border-color:var(--brand); color:var(--brand); background:#EFF6FF }
    .btn.danger{ border-color:var(--danger); color:var(--danger); background:#FEF2F2 }
    .grid{ display:grid; grid-template-columns:2fr 1fr; gap:16px }
    .card{ background:#fff; border:1px solid var(--line); border-radius:12px; padding:16px }
    .card h3{ margin:0 0 10px; font-size:16px }
    .muted{ color:var(--muted); font-size:13px }
    .list{ display:flex; flex-direction:column; gap:10px }
    .row{ display:grid; grid-template-columns:130px 1fr 120px 160px; gap:10px;
          align-items:center; background:#fff; border:1px solid var(--line); border-radius:10px; padding:10px }
    .chip{ background:var(--chip); color:var(--chip-text); border-radius:999px; padding:4px 8px; font-size:12px }
    .right{ text-align:right }
    .links a{ margin-left:8px; text-decoration:none; color:var(--brand) }
    .links a:hover{ color:var(--brand-dark) }
    .kpis{ display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:16px }
    .kpi{ background:#fff; border:1px solid var(--line); border-radius:12px; padding:14px }
    .kpi .num{ font-weight:800; font-size:22px }
    .kpi.ok{ border-color:#DCFCE7 }
    .kpi.warn{ border-color:#FEF3C7 }
    .kpi.bad{ border-color:#FEE2E2 }
    footer{ text-align:center; color:#9CA3AF; font-size:12px; margin:26px 0 }
    @media (max-width:1000px){ .grid{ grid-template-columns:1fr } .row{ grid-template-columns:120px 1fr 100px 120px } }
    @media (max-width:700px){ .row{ grid-template-columns:1fr; gap:6px } .right{ text-align:left } }
  </style>
</head>
<body>
<header>
  <div class="brand">미정 · 직원 콘솔</div>
  <div class="user">
    <!-- TODO: 세션/모델에서 직원명 바인딩 -->
    김나경 님 ·
    <a href="${pageContext.request.contextPath}/logout" style="color:var(--danger); text-decoration:none; margin-left:6px;">로그아웃</a>
  </div>
</header>

<div class="container">

  <!-- 퀵액션 -->
  <div class="actions">
    <a class="btn primary" href="${pageContext.request.contextPath}/staff/reservations/today">오늘 방문</a>
    <a class="btn" href="${pageContext.request.contextPath}/staff/reservations/manage">예약 관리</a>
    <a class="btn" href="${pageContext.request.contextPath}/staff/customers/search">고객 검색</a>
    <a class="btn" href="${pageContext.request.contextPath}/staff/notices">공지 관리</a>
    <a class="btn" href="${pageContext.request.contextPath}/staff/reports">통계/리포트</a>
  </div>

  <!-- KPI 카드 -->
  <div class="kpis">
    <div class="kpi ok">
      <div class="muted">오늘 확정 예약</div>
      <div class="num">12</div>
    </div>
    <div class="kpi warn">
      <div class="muted">대기/미확인</div>
      <div class="num">5</div>
    </div>
    <div class="kpi bad">
      <div class="muted">취소/노쇼</div>
      <div class="num">1</div>
    </div>
  </div>

  <div class="grid">
    <!-- 좌: 오늘 일정 / 예약 목록 -->
    <div class="card">
      <h3>오늘 일정</h3>
      <div class="list">
        <!-- 예시 행: 시간 · 고객명/지점 · 상태 · 액션 -->
        <div class="row">
          <div class="muted">09:30</div>
          <div><strong>조진원</strong> · 서울...? 이동점포</div>
          <div><span class="chip">확정</span></div>
          <div class="right links">
            <a href="${pageContext.request.contextPath}/staff/reservations/101">상세</a>
            <a href="${pageContext.request.contextPath}/staff/reservations/101/checkin">체크인</a>
            <a href="${pageContext.request.contextPath}/staff/reservations/101/complete">완료</a>
          </div>
        </div>
        <div class="row">
          <div class="muted">10:10</div>
          <div><strong>신호섭</strong> · 부산 해운대구 이동점포</div>
          <div><span class="chip">대기</span></div>
          <div class="right links">
            <a href="${pageContext.request.contextPath}/staff/reservations/102">상세</a>
            <a href="${pageContext.request.contextPath}/staff/reservations/102/confirm">확정</a>
            <a href="${pageContext.request.contextPath}/staff/reservations/102/cancel">취소</a>
          </div>
        </div>
        <div class="row">
          <div class="muted">11:00</div>
          <div><strong>박하늘</strong> · 역삼 이동점포</div>
          <div><span class="chip">미확인</span></div>
          <div class="right links">
            <a href="${pageContext.request.contextPath}/staff/reservations/103">상세</a>
            <a href="${pageContext.request.contextPath}/staff/reservations/103/confirm">확정</a>
            <a href="${pageContext.request.contextPath}/staff/reservations/103/cancel">취소</a>
          </div>
        </div>
      </div>
    </div>

    <!-- 우: 업무 알림 / 최근 처리 로그 -->
    <div class="card">
      <h3>업무 알림</h3>
      <ul class="muted" style="margin:8px 0 16px 18px;">
        <li>신규 예약 3건 승인 대기</li>
        <li>오늘 체크인 누락 1건</li>
        <li>공지 업데이트 필요 (명절 운영)</li>
      </ul>

      <h3 style="margin-top:6px;">최근 처리 로그</h3>
      <ul class="muted" style="margin:8px 0 0 18px;">
        <li>09:12 조진원 예약 체크인 완료</li>
        <li>09:05 신호섭 예약 확정 처리</li>
        <li>08:55 시스템 점검 체크 완료</li>
      </ul>
    </div>
  </div>

  <footer>© 미정 · Staff Console</footer>
</div>
</body>
</html>
