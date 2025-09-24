<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>이동점포 · 직원 대시보드</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    :root{
      --bg:#F6F8FB; --panel:#FFFFFF; --line:#E5E7EB; --text:#0F172A; --muted:#6B7280;
      --brand:#2563EB; --brand-2:#1E40AF; --ok:#16A34A; --warn:#F59E0B; --bad:#EF4444;
      --chip:#EEF2FF; --chip-text:#3730A3;
    }
    *{box-sizing:border-box}
    body{margin:0;background:var(--bg);color:var(--text);
      font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif}

    /* Header */
    header{position:sticky;top:0;z-index:50;background:#fff;border-bottom:1px solid var(--line);
      display:flex;align-items:center;justify-content:space-between;padding:12px 18px}
    .brand{font-weight:800;color:var(--brand-2)}
    .user{font-size:14px;color:var(--muted)}
    .user a{color:var(--bad);text-decoration:none;margin-left:6px}

    /* Shell */
    .shell{display:grid;grid-template-columns:240px 1fr;gap:18px;max-width:1400px;margin:20px auto;padding:0 20px}

    /* Sidebar */
    .side{background:#fff;border:1px solid var(--line);border-radius:12px;padding:10px}
    .side h4{margin:4px 8px 10px;font-size:14px;color:#334155}
    .nav a{display:flex;align-items:center;gap:8px;padding:10px 12px;margin:6px;border-radius:10px;
      text-decoration:none;color:#111827;border:1px solid var(--line);background:#fff}
    .nav a.active{border-color:var(--brand);color:var(--brand);background:#EFF6FF}

    /* Main */
    .main{display:flex;flex-direction:column;gap:16px}

    /* Filters */
    .filters{display:grid;grid-template-columns:1fr 120px 140px 140px auto;gap:10px}
    .input,.select,.btn{height:40px;border:1px solid var(--line);border-radius:10px;padding:0 12px;font-weight:600}
    .input{background:#fff}
    .select{background:#fff}
    .btn{background:#fff;color:#374151;cursor:pointer}
    .btn.primary{background:#1F51FF0D;color:var(--brand);border-color:var(--brand)}
    .btn.cta{background:var(--brand);color:#fff;border-color:var(--brand)}
    .btn.cta:hover{background:var(--brand-2)}

    /* KPI */
    .kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}
    .kpi{background:#fff;border:1px solid var(--line);border-radius:12px;padding:12px}
    .kpi .label{font-size:12px;color:var(--muted)}
    .kpi .num{font-size:22px;font-weight:800;margin-top:6px}
    .ok{border-color:#DCFCE7} .warn{border-color:#FEF3C7} .bad{border-color:#FEE2E2}

    /* Grid rows */
    .row{display:grid;grid-template-columns:2fr 1fr;gap:16px}
    .card{background:#fff;border:1px solid var(--line);border-radius:12px;padding:14px}
    .card h3{margin:0 0 10px;font-size:16px}
    .muted{color:var(--muted);font-size:13px}

    /* Map area & route chips */
    .mapbox{height:340px;border:1px dashed var(--line);border-radius:12px;background:linear-gradient(180deg,#FAFBFF, #F2F5FF)}
    .route-chips{display:flex;gap:8px;flex-wrap:wrap;margin-top:10px}
    .chip{background:var(--chip);color:var(--chip-text);border-radius:999px;padding:6px 10px;font-size:12px}

    /* Route options */
    .routes{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}
    .route{background:#fff;border:1px solid var(--line);border-radius:12px;padding:12px}
    .route h4{margin:0 0 6px}
    .meta{display:grid;grid-template-columns:1fr 1fr;gap:6px;color:#111827;font-size:14px}
    .meta .muted{font-size:12px}
    .route .footer{margin-top:8px}
    .route .btn{width:100%}

    /* Right column: chart + alerts */
    .chartbox{height:340px;border:1px dashed var(--line);border-radius:12px;display:flex;align-items:center;justify-content:center}
    canvas{max-width:100%;max-height:100%}

    /* Today schedule + logs */
    .twocol{display:grid;grid-template-columns:2fr 1fr;gap:16px}
    .list{display:flex;flex-direction:column;gap:10px}
    .rowline{display:grid;grid-template-columns:100px 1fr 100px 200px;gap:10px;align-items:center;
      border:1px solid var(--line);border-radius:10px;padding:10px;background:#fff}
    .links a{margin-left:8px;text-decoration:none;color:var(--brand)}
    .links a:hover{color:var(--brand-2)}

    footer{text-align:center;color:#9CA3AF;font-size:12px;margin:20px 0}
    @media (max-width:1100px){ .routes{grid-template-columns:1fr} .row,.twocol{grid-template-columns:1fr} .kpis{grid-template-columns:repeat(2,1fr)} }
    @media (max-width:800px){ .shell{grid-template-columns:1fr} .filters{grid-template-columns:1fr 1fr 1fr 1fr auto} }

    /* === Agent Dock === */
    .agent-dock{
      position: fixed; left: 20px; bottom: 20px; width: 380px; max-height: 70vh;
      background:#fff; border:1px solid var(--line); border-radius:14px;
      box-shadow: 0 12px 30px rgba(2,6,23,.18); overflow: hidden; display:flex; flex-direction:column;
      transition: transform .2s ease, opacity .2s ease; z-index: 10000; /* 위로 */
    }
    .agent-dock.collapsed{ transform: translateY(10px); opacity:0; pointer-events:none; }
    .dock-head{ display:flex; align-items:center; justify-content:space-between; padding:10px 12px;
      border-bottom:1px solid var(--line); background:#F8FAFC; }
    .dock-head .title{ font-weight:800; color:var(--brand-2); }
    .icon-btn{ border:none; background:transparent; cursor:pointer; font-size:16px; margin-left:6px; }
    .dock-body{ display:flex; flex-direction:column; height:100%; }
    .msg-list{ padding:12px; overflow:auto; gap:10px; display:flex; flex-direction:column; min-height:160px; }
    .msg{ display:flex; gap:8px; }
    .msg .avatar{ width:28px; height:28px; border-radius:999px; display:flex; align-items:center; justify-content:center; font-size:14px; }
    .msg.user  .avatar{ background:#DBEAFE; color:#1E3A8A; }   /* U */
    .msg.agent .avatar{ background:#DCFCE7; color:#065F46; }  /* A */
    .bubble{ max-width: 78%; padding:8px 12px; border-radius:12px; border:1px solid var(--line); background:#fff; }
    .msg.user  .bubble{ background:#F0F9FF; border-color:#DBEAFE; }
    .msg.agent .bubble{ background:#F0FFF4; border-color:#DCFCE7; }
    .typing{ font-size:12px; color:#64748B; padding-left:36px; }

    .quick-prompts{ display:flex; gap:8px; padding:0 12px 8px; flex-wrap:wrap;}
    .quick-prompts .chip{ background:#EEF2FF; color:#3730A3; border:none; border-radius:999px; padding:6px 10px; cursor:pointer; }

    .composer{ display:flex; gap:8px; padding:10px; border-top:1px solid var(--line); }
    #chatInput{ flex:1; resize:none; border:1px solid var(--line); border-radius:10px; padding:10px; font-family:inherit; }
    .send-btn{ background:var(--brand); color:#fff; border:none; border-radius:10px; padding:0 14px; font-weight:700; cursor:pointer; }

    .dock-fab{
      position:fixed; left:20px; bottom:20px; width:54px; height:54px; border-radius:999px;
      border:none; background:var(--brand); color:#fff; font-size:22px; cursor:pointer; z-index:9999; /* 위로 */
      box-shadow: 0 10px 24px rgba(2,6,23,.22);
    }
    @media (max-width: 780px){
      .agent-dock{ left: 10px; right: 10px; width: auto; max-height: 65vh; }
    }
  </style>
</head>
<body>
<header>
  <div class="brand">이동점포 · 직원 대시보드</div>
  <div class="user">
    ${sessionScope.staffName} 님
    <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
  </div>
</header>

<div class="shell">
  <!-- Sidebar -->
  <aside class="side">
    <h4>메뉴</h4>
    <nav class="nav">
      <a class="active" href="${pageContext.request.contextPath}/staff">대시보드</a>
      <a href="${pageContext.request.contextPath}/staff/routes">경로 추천</a>
      <a href="${pageContext.request.contextPath}/staff/alerts">알림 관리</a>
      <a href="${pageContext.request.contextPath}/staff/aftercare">사후 관리</a>
    </nav>
  </aside>

  <!-- Main -->
  <main class="main">

    <!-- Filters -->
    <div class="filters">
      <input class="input" type="search" placeholder="지역/동 검색" name="q" value="${param.q}">
      <select class="select" name="month">
        <c:forEach var="m" begin="1" end="12">
          <option value="${m}" <c:if test='${m == requestScope.month}'>selected</c:if>>${m}월</option>
        </c:forEach>
      </select>
      <select class="select" name="scenario">
        <option value="min_cost"  ${requestScope.scenario == 'min_cost' ? 'selected' : ''}>최소 비용</option>
        <option value="max_cover" ${requestScope.scenario == 'max_cover' ? 'selected' : ''}>최대 커버</option>
        <option value="balanced"  ${requestScope.scenario == 'balanced' ? 'selected' : ''}>균형안</option>
      </select>
      <button class="btn primary" onclick="location.href='${pageContext.request.contextPath}/staff/routes/simulate'">시뮬레이션</button>
      <button class="btn cta" onclick="location.href='${pageContext.request.contextPath}/staff/routes/generate'">경로 생성</button>
    </div>

    <!-- KPIs -->
    <div class="kpis">
      <div class="kpi ok">
        <div class="label">예상 처리건수</div>
        <div class="num">${kpi.expectedCount != null ? kpi.expectedCount : 132}건</div>
      </div>
      <div class="kpi">
        <div class="label">총 이동거리</div>
        <div class="num">${kpi.totalDistanceKm != null ? kpi.totalDistanceKm : 84} km</div>
      </div>
      <div class="kpi">
        <div class="label">고TI 커버율</div>
        <div class="num">${kpi.coverage != null ? kpi.coverage : 76}%</div>
      </div>
      <div class="kpi warn">
        <div class="label">예상 비용(만원)</div>
        <div class="num">${kpi.cost != null ? kpi.cost : 215}</div>
      </div>
    </div>

    <!-- Top row: Map + Demand chart -->
    <div class="row">
      <section class="card">
        <h3>추천 경로(시뮬레이션)</h3>
        <div class="mapbox" id="mapBox">
          <!-- TODO: 지도 SDK 연동 -->
        </div>
        <div class="route-chips">
          <c:forEach var="stop" items="${routePreview.stops}">
            <span class="chip">${stop.name}</span>
          </c:forEach>
          <c:if test="${empty routePreview.stops}">
            <span class="chip">정차지 1</span>
            <span class="chip">정차지 2</span>
            <span class="chip">정차지 3</span>
          </c:if>
        </div>
      </section>

      <section class="card">
        <h3>요일별 수요 추이</h3>
        <div class="chartbox">
          <canvas id="dowChart" width="420" height="280" aria-label="요일별 수요 차트"></canvas>
        </div>
      </section>
    </div>

    <!-- Route options -->
    <div class="routes">
      <div class="route">
        <h4>경로안 1 · 최소 비용</h4>
        <div class="meta">
          <div><div class="muted">총 거리</div>${route1.distanceKm != null ? route1.distanceKm : 60} km</div>
          <div><div class="muted">예상 처리</div>${route1.jobs != null ? route1.jobs : 120} 건</div>
          <div><div class="muted">커버율</div>${route1.coverage != null ? route1.coverage : 70}%</div>
          <div><div class="muted">예상 비용</div>${route1.cost != null ? route1.cost : 200} 만원</div>
        </div>
        <div class="footer"><button class="btn" onclick="openRoute('min_cost')">상세 보기</button></div>
      </div>

      <div class="route">
        <h4>경로안 2 · 최대 포용</h4>
        <div class="meta">
          <div><div class="muted">총 거리</div>${route2.distanceKm != null ? route2.distanceKm : 72} km</div>
          <div><div class="muted">예상 처리</div>${route2.jobs != null ? route2.jobs : 110} 건</div>
          <div><div class="muted">커버율</div>${route2.coverage != null ? route2.coverage : 78}%</div>
          <div><div class="muted">예상 비용</div>${route2.cost != null ? route2.cost : 215} 만원</div>
        </div>
        <div class="footer"><button class="btn" onclick="openRoute('max_cover')">상세 보기</button></div>
      </div>

      <div class="route">
        <h4>경로안 3 · 균형안</h4>
        <div class="meta">
          <div><div class="muted">총 거리</div>${route3.distanceKm != null ? route3.distanceKm : 84} km</div>
          <div><div class="muted">예상 처리</div>${route3.jobs != null ? route3.jobs : 100} 건</div>
          <div><div class="muted">커버율</div>${route3.coverage != null ? route3.coverage : 86}%</div>
          <div><div class="muted">예상 비용</div>${route3.cost != null ? route3.cost : 230} 만원</div>
        </div>
        <div class="footer">
          <button class="btn cta" onclick="confirmRoute('balanced')">이 안으로 확정</button>
        </div>
      </div>
    </div>

    <!-- Today schedule + alerts/logs -->
    <div class="twocol">
      <section class="card">
        <h3>오늘 일정</h3>
        <div class="list">
          <c:forEach var="r" items="${todayReservations}">
            <div class="rowline">
              <div class="muted">${r.time}</div>
              <div><strong>${r.customerName}</strong> · ${r.branchName}</div>
              <div>
                <span class="chip" style="background:${r.status eq '확정' ? '#DCFCE7' : r.status eq '대기' ? '#FEF3C7' : '#E5E7EB'};color:#111827">
                  ${r.status}
                </span>
              </div>
              <div class="links">
                <a href="${pageContext.request.contextPath}/staff/reservations/${r.id}">상세</a>
                <a href="${pageContext.request.contextPath}/staff/reservations/${r.id}/confirm">확정</a>
                <a href="${pageContext.request.contextPath}/staff/reservations/${r.id}/checkin">체크인</a>
                <a href="${pageContext.request.contextPath}/staff/reservations/${r.id}/complete">완료</a>
              </div>
            </div>
          </c:forEach>
          <c:if test="${empty todayReservations}">
            <div class="rowline">
              <div class="muted">09:30</div>
              <div><strong>조진원</strong> · 서울 이동점포</div>
              <div><span class="chip">확정</span></div>
              <div class="links">
                <a href="#">상세</a><a href="#">체크인</a><a href="#">완료</a>
              </div>
            </div>
          </c:if>
        </div>
      </section>

      <section class="card">
        <h3>업무 알림</h3>
        <ul class="muted" style="margin:8px 0 16px 18px;">
          <c:forEach var="n" items="${alerts}">
            <li>${n}</li>
          </c:forEach>
          <c:if test="${empty alerts}">
            <li>신규 예약 3건 승인 대기</li>
            <li>오늘 체크인 누락 1건</li>
            <li>명절 운영 공지 업데이트 필요</li>
          </c:if>
        </ul>

        <h3 style="margin-top:6px;">최근 처리 로그</h3>
        <ul class="muted" style="margin:8px 0 0 18px;">
          <c:forEach var="log" items="${recentLogs}">
            <li>${log}</li>
          </c:forEach>
          <c:if test="${empty recentLogs}">
            <li>09:12 조진원 예약 체크인 완료</li>
            <li>09:05 신호섭 예약 확정 처리</li>
            <li>08:55 시스템 점검 체크 완료</li>
          </c:if>
        </ul>
      </section>
    </div>

    <footer>© 이동점포 · Staff Console</footer>
  </main>
</div>

<!-- ===== AI Agent Chat Dock (left-bottom) ===== -->
<div id="agentDock" class="agent-dock collapsed" aria-live="polite" aria-label="AI 상담 챗봇 패널">
  <header class="dock-head" role="heading" aria-level="2">
    <div class="title">AI Agent</div>
    <div class="tools">
      <button id="btnClear" class="icon-btn" title="대화 초기화" aria-label="대화 초기화">🧹</button>
      <button id="btnMin" class="icon-btn" title="접기" aria-label="접기">−</button>
    </div>
  </header>

  <div id="dockBody" class="dock-body">
    <div id="msgList" class="msg-list" role="log" aria-live="polite"></div>

    <div class="quick-prompts" aria-label="빠른 프롬프트">
      <button class="chip" data-txt="10월 경로안 요약해줘">10월 경로 요약</button>
      <button class="chip" data-txt="금주 고TI 커버율 올리는 방안 추천">커버율↑ 방안</button>
      <button class="chip" data-txt="오늘 예약 리스크 체크해줘">오늘 리스크</button>
    </div>

    <form id="chatForm" class="composer" autocomplete="off">
      <textarea id="chatInput" rows="1" placeholder="자연어로 물어보세요. (Shift+Enter 줄바꿈)" aria-label="채팅 입력"></textarea>
      <button id="btnSend" class="send-btn" type="submit" aria-label="전송">▶</button>
    </form>
  </div>
</div>

<!-- 떠있는 열기 버튼 -->
<button id="dockFab" class="dock-fab" aria-label="AI Agent 열기">💬</button>

<script>
  // 경로 상세/확정 액션
  function openRoute(type){
    location.href = '${pageContext.request.contextPath}/staff/routes/detail?type=' + encodeURIComponent(type);
  }
  function confirmRoute(type){
    if(confirm('해당 경로안을 확정하시겠습니까?')){
      location.href='${pageContext.request.contextPath}/staff/routes/confirm?type='+encodeURIComponent(type);
    }
  }

  // 차트 플레이스홀더
  document.addEventListener('DOMContentLoaded', () => {
    const c = document.getElementById('dowChart');
    if(c){
      const ctx = c.getContext('2d'), w = c.width;
      ctx.strokeStyle = '#E5E7EB'; ctx.lineWidth = 1;
      for(let i=0;i<6;i++){ ctx.beginPath(); ctx.moveTo(40,20+i*50); ctx.lineTo(w-10,20+i*50); ctx.stroke(); }
      const pts = [40,220,100,160,160,180,220,120,280,60,340,190,400,210];
      const grad = ctx.createLinearGradient(0,60,0,260);
      grad.addColorStop(0,'rgba(37,99,235,0.35)'); grad.addColorStop(1,'rgba(37,99,235,0.05)');
      ctx.beginPath(); ctx.moveTo(pts[0],pts[1]); for(let i=2;i<pts.length;i+=2){ ctx.lineTo(pts[i],pts[i+1]); }
      ctx.lineTo(pts[pts.length-2],260); ctx.lineTo(40,260); ctx.closePath();
      ctx.fillStyle = grad; ctx.fill();
      ctx.beginPath(); ctx.moveTo(pts[0],pts[1]); for(let i=2;i<pts.length;i+=2){ ctx.lineTo(pts[i],pts[i+1]); }
      ctx.strokeStyle = '#2563EB'; ctx.lineWidth = 2; ctx.stroke();
      const days = ['월','화','수','목','금','토','일'];
      ctx.fillStyle = '#6B7280'; ctx.font = '12px system-ui';
      days.forEach((d,i)=> ctx.fillText(d, 40+ i*60, 275));
    }

    // ===== AI Agent Dock =====
    const $ = (q) => document.querySelector(q);
    const dock = $('#agentDock');
    const fab  = $('#dockFab');
    const btnMin = $('#btnMin');
    const btnClear = $('#btnClear');
    const list = $('#msgList');
    const form = $('#chatForm');
    const input = $('#chatInput');
    const qpWrap = document.querySelector('.quick-prompts');

    // 토글
    const openDock = () => { dock.classList.remove('collapsed'); fab.style.display='none'; input.focus(); };
    const closeDock = () => { dock.classList.add('collapsed'); fab.style.display='inline-flex'; };
    fab.addEventListener('click', openDock);
    btnMin.addEventListener('click', closeDock);

    // 빠른 프롬프트
    qpWrap.addEventListener('click', (e)=>{
      if(e.target.matches('.chip')) {
        input.value = e.target.dataset.txt;
        input.focus();
      }
    });

    // 메시지 DOM 유틸
    const el = (tag, cls, text) => { const n=document.createElement(tag); if(cls) n.className=cls; if(text) n.textContent=text; return n; }
    function pushMsg(role, text){
      const row = el('div','msg '+(role==='user'?'user':'agent'));
      const av  = el('div','avatar', role==='user'?'U':'A');
      const bub = el('div','bubble'); bub.innerText = text;
      row.append(av,bub); list.append(row); list.scrollTop = list.scrollHeight;
    }
    function setTyping(on){
      let t = document.getElementById('typing');
      if(on && !t){ t = el('div','typing'); t.id='typing'; t.textContent='응답 생성 중…'; list.append(t); }
      if(!on && t){ t.remove(); }
      list.scrollTop = list.scrollHeight;
    }

    // 대화 초기화
    btnClear.addEventListener('click', () => {
      list.innerHTML = '';
      sessionStorage.removeItem('agent:conv');
    });

    // Shift+Enter 줄바꿈 / Enter 전송
    input.addEventListener('keydown', (e)=>{
      if(e.key==='Enter' && !e.shiftKey){ e.preventDefault(); form.dispatchEvent(new Event('submit')); }
    });

    // 전송 로직 (REST or SSE 택1) — 기본은 REST로 둠
    async function sendViaRest(content){
      const payload = { message: content, context: { page: location.pathname } };
      const res = await fetch('${pageContext.request.contextPath}/staff/agent/chat', {
        method:'POST',
        headers:{
          'Content-Type':'application/json'
          <c:if test="${not empty _csrf}">,'X-CSRF-TOKEN':'${_csrf.token}'</c:if>
        },
        body: JSON.stringify(payload),
        credentials:'same-origin'
      });
      if(!res.ok) throw new Error('Agent 응답 오류');
      const data = await res.json();
      return data.reply || '(응답 없음)';
    }

    // 필요 시 SSE 버전으로 교체
    const sendMessage = sendViaRest; // sendViaSSE로 바꾸면 스트리밍

    // 전송 핸들러
    form.addEventListener('submit', async (e)=>{
      e.preventDefault();
      const text = input.value.trim();
      if(!text) return;
      pushMsg('user', text);
      input.value = ''; setTyping(true);
      try{
        const reply = await sendMessage(text);
        pushMsg('agent', reply);
      }catch(err){
        pushMsg('agent', '죄송해요, 잠시 후 다시 시도해주세요.');
        console.error(err);
      }finally{ setTyping(false); }
    });
  });
</script>
</body>
</html>
