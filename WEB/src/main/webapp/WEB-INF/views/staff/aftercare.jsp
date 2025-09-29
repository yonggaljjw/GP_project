<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<jsp:include page="/WEB-INF/views/layout/start-staff.jsp">
  <jsp:param name="pageTitle" value="사후 관리"/>
  <jsp:param name="brand" value="이동점포 · 사후관리"/>
  <jsp:param name="active" value="aftercare"/>
</jsp:include>

<!-- 필터 -->
<form class="filters" method="get" action="${pageContext.request.contextPath}/staff/aftercare" style="margin-bottom:12px">
  <select class="select" name="range">
    <option value="14" ${param.range=='14'?'selected':''}>최근 14일</option>
    <option value="30" ${param.range=='30'?'selected':''}>최근 30일</option>
    <option value="90" ${param.range=='90'?'selected':''}>최근 90일</option>
  </select>
  <input class="input" type="search" name="q" placeholder="키워드 검색" value="${param.q}">
  <select class="select" name="sigungu">
    <option value="">시/군/구</option>
    <c:forEach var="g" items="${sigunguList}"><option value="${g}" ${param.sigungu==g?'selected':''}>${g}</option></c:forEach>
  </select>
  <select class="select" name="channel">
    <option value="">채널</option>
    <option value="현장" ${param.channel=='현장'?'selected':''}>현장</option>
    <option value="전화" ${param.channel=='전화'?'selected':''}>전화</option>
    <option value="온라인" ${param.channel=='온라인'?'selected':''}>온라인</option>
  </select>
  <select class="select" name="status">
    <option value="">상태</option>
    <option value="미처리" ${param.status=='미처리'?'selected':''}>미처리</option>
    <option value="진행" ${param.status=='진행'?'selected':''}>진행</option>
    <option value="완료" ${param.status=='완료'?'selected':''}>완료</option>
  </select>
  <button class="btn primary" type="submit">적용</button>
</form>

<!-- KPI -->
<div class="kpis">
  <div class="kpi">
    <div class="label">총 피드백</div>
    <div class="num">${ac.total != null ? ac.total : 384}건</div>
  </div>
  <div class="kpi">
    <div class="label">평균 CSAT</div>
    <div class="num">${ac.csat != null ? ac.csat : 4.3}/5</div>
  </div>
  <div class="kpi">
    <div class="label">NPS</div>
    <div class="num">${ac.nps != null ? ac.nps : 38}</div>
  </div>
  <div class="kpi">
    <div class="label">처리율</div>
    <div class="num">${ac.resolveRate != null ? ac.resolveRate : 87}%</div>
  </div>
</div>

<!-- 2열 레이아웃 -->
<div class="row" style="margin-top:12px">
  <!-- 좌: 피드백/로그 -->
  <section class="card">
    <h3>고객 피드백</h3>
    <div class="list">
      <c:forEach var="f" items="${feedbackList}">
        <div class="item" style="align-items:flex-start;gap:10px">
          <div style="flex:1">
            <div style="display:flex;gap:8px;align-items:center">
              <strong>${f.region}</strong>
              <span class="chip" style="background:${f.sentiment=='부정'?'#FEE2E2':f.sentiment=='중립'?'#E5E7EB':'#DCFCE7'}">
                ${f.sentiment}
              </span>
              <span class="muted">${f.createdAt}</span>
              <c:if test="${not empty f.channel}"><span class="muted">· ${f.channel}</span></c:if>
            </div>
            <div class="muted" style="margin-top:6px">${f.content}</div>
            <div class="muted" style="margin-top:6px">
              <c:forEach var="t" items="${f.tags}"><span class="chip">#${t}</span></c:forEach>
            </div>
          </div>
          <div class="links">
            <a href="${pageContext.request.contextPath}/staff/aftercare/feedback/${f.id}">상세</a>
            <a href="${pageContext.request.contextPath}/staff/aftercare/feedback/${f.id}/assign">배정</a>
            <a href="${pageContext.request.contextPath}/staff/aftercare/feedback/${f.id}/resolve">완료</a>
          </div>
        </div>
      </c:forEach>
      <c:if test="${empty feedbackList}">
        <div class="item"><div><strong>강남구</strong> · <span class="chip" style="background:#E5E7EB">중립</span> 상담 대기시간이 길었어요.</div></div>
        <div class="item"><div><strong>종로구</strong> · <span class="chip" style="background:#DCFCE7">긍정</span> 직원 응대가 친절했습니다.</div></div>
        <div class="item"><div><strong>부산진구</strong> · <span class="chip" style="background:#FEE2E2">부정</span> 안내 표지판이 부족합니다.</div></div>
      </c:if>
    </div>

    <h3 style="margin-top:14px">최근 액션 로그</h3>
    <ul class="muted" style="margin:8px 0 0 18px">
      <c:forEach var="log" items="${actionLogs}">
        <li>${log}</li>
      </c:forEach>
      <c:if test="${empty actionLogs}">
        <li>10:12 종로구 민원 #392 배정 → 완료</li>
        <li>09:40 강남구 대기시간 개선 과제 등록</li>
        <li>09:05 부산진구 안내물 리뉴얼 요청</li>
      </c:if>
    </ul>
  </section>

  <!-- 우: 시각화 -->
  <section class="card">
    <h3>운영 현황 시각화</h3>
    <div class="viz-grid">
      <div class="viz-card"><h4>감성 구성</h4><div class="viz-body"><canvas id="acSentiment"></canvas></div></div>
      <div class="viz-card"><h4>주제 Top</h4><div class="viz-body"><canvas id="acTopics"></canvas></div></div>
      <div class="viz-card"><h4>일별 추이</h4><div class="viz-body"><canvas id="acTrend"></canvas></div></div>
      <div class="viz-card"><h4>상태 분포</h4><div class="viz-body"><canvas id="acStatus"></canvas></div></div>
    </div>
  </section>
</div>

<!-- 보고서 -->
<section class="card" style="margin-top:14px">
  <h3>운영 결과 보고서</h3>
  <div style="display:grid;grid-template-columns:1fr 300px;gap:12px">
    <div>
      <textarea id="reportText" style="width:100%;height:160px;border:1px solid var(--line);border-radius:10px;padding:10px"
        placeholder="요약/개선안/이슈를 적어주세요. '초안 생성'을 누르면 최근 데이터로 자동 채움"></textarea>
    </div>
    <div style="display:flex;flex-direction:column;gap:8px">
      <button class="btn primary" type="button" onclick="AC.generateDraft()">초안 생성</button>
      <button class="btn" type="button" onclick="AC.downloadCSV()">CSV 내보내기</button>
      <button class="btn cta" type="button" onclick="AC.print()">미리보기/인쇄(PDF)</button>
    </div>
  </div>
</section>

<!-- 스타일/스크립트 -->
<link rel="stylesheet" href="<c:url value='/css/aftercare.css'/>?v=${applicationScope.staticVer}">
<script defer src="<c:url value='/vendor/chartjs/chart.umd.js'/>"></script>
<script defer src="<c:url value='/js/aftercare.js'/>?v=${applicationScope.staticVer}"></script>

<jsp:include page="/WEB-INF/views/layout/end-staff.jsp"/>
