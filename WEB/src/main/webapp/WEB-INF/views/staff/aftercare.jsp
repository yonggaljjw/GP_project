<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<jsp:include page="/WEB-INF/views/layout/start-staff.jsp">
  <jsp:param name="pageTitle" value="사후관리"/>
  <jsp:param name="brand" value="이동점포 · 사후관리"/>
  <jsp:param name="active" value="aftercare"/>
</jsp:include>

<!-- 상단 지표 -->
<div class="kpis">
  <div class="kpi"><div class="label">평균 만족도</div><div class="num">${ac.avgScore!=null?ac.avgScore:4.5}</div></div>
  <div class="kpi"><div class="label">피드백 수</div><div class="num">${ac.feedbackCount!=null?ac.feedbackCount:35}건</div></div>
  <div class="kpi"><div class="label">처리 완료율</div><div class="num">${ac.closeRate!=null?ac.closeRate:82}%</div></div>
  <div class="kpi warn"><div class="label">미처리</div><div class="num">${ac.openCount!=null?ac.openCount:6}건</div></div>
</div>

<div class="row" style="margin-top:16px">
  <!-- 고객 피드백 리스트 -->
  <section class="card">
    <h3>고객 피드백</h3>
    <div class="list">
      <c:forEach var="f" items="${feedbackList}">
        <div class="item">
          <div>
            <strong>${f.customerName}</strong> · ${f.visitDate}
            <span class="chip">★ ${f.score}</span>
            <div class="muted" style="margin-top:4px">${f.comment}</div>
          </div>
          <div class="links">
            <a href="${pageContext.request.contextPath}/staff/aftercare/${f.id}">상세</a>
            <a href="${pageContext.request.contextPath}/staff/aftercare/${f.id}/assign">담당 지정</a>
            <a href="${pageContext.request.contextPath}/staff/aftercare/${f.id}/close">완료</a>
          </div>
        </div>
      </c:forEach>
      <c:if test="${empty feedbackList}">
        <div class="item">
          <div><strong>홍길동</strong> · 2025-09-20 <span class="chip">★ 5</span>
            <div class="muted" style="margin-top:4px">직원 응대가 친절했고 대기시간이 짧았어요.</div>
          </div>
          <div class="links"><a href="#">상세</a><a href="#">담당 지정</a><a href="#">완료</a></div>
        </div>
      </c:if>
    </div>
  </section>

  <!-- 사후관리 지표(추이) -->
  <section class="card">
    <h3>사후관리 지표</h3>
    <div class="chartbox"><canvas id="acChart" width="420" height="280" aria-label="사후관리 지표 차트"></canvas></div>
    <div style="margin-top:12px; text-align:right">
      <a class="btn" href="${pageContext.request.contextPath}/staff/aftercare/report">보고서 생성</a>
    </div>
  </section>
</div>

<!-- 조치 내역 -->
<section class="card" style="margin-top:16px">
  <h3>최근 조치 내역</h3>
  <ul class="muted" style="margin:8px 0 0 18px;">
    <c:forEach var="log" items="${actionLogs}"><li>${log}</li></c:forEach>
    <c:if test="${empty actionLogs}">
      <li>09:12 고객 A VOC 처리 완료 (콜백)</li>
      <li>09:05 고객 B 대기시간 개선 요청 전달</li>
      <li>08:55 고객 C 상담 품질 모니터링 등록</li>
    </c:if>
  </ul>
</section>

<script>
document.addEventListener('DOMContentLoaded', ()=>{
  const c=document.getElementById('acChart'); if(!c) return;
  const ctx=c.getContext('2d');
  ctx.fillStyle='#2563EB22'; ctx.fillRect(40,220,50,-60); ctx.fillRect(120,220,50,-90); ctx.fillRect(200,220,50,-70); ctx.fillRect(280,220,50,-110); ctx.fillRect(360,220,50,-80);
  ctx.strokeStyle='#2563EB'; ctx.lineWidth=2; ctx.beginPath(); ctx.moveTo(40,160); ctx.lineTo(120,130); ctx.lineTo(200,150); ctx.lineTo(280,110); ctx.lineTo(360,140); ctx.stroke();
});
</script>

<jsp:include page="/WEB-INF/views/layout/end-staff.jsp"/>
