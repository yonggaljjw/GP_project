<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<jsp:include page="/WEB-INF/views/layout/start-staff.jsp">
  <jsp:param name="pageTitle" value="대시보드"/>
  <jsp:param name="brand" value="이동점포 · 직원 대시보드"/>
  <jsp:param name="active" value="dashboard"/>
</jsp:include>

<!-- 지역 선택 필터 -->
<form class="filters" method="get" action="${pageContext.request.contextPath}/staff">
  <input class="input" type="search" name="q" placeholder="지역(시/군/구) 검색" value="${param.q}">
  <select class="select" name="sido">
    <option value="">시/도</option>
    <c:forEach var="s" items="${sidoList}">
      <option value="${s}" ${param.sido==s?'selected':''}>${s}</option>
    </c:forEach>
  </select>
  <select class="select" name="sigungu">
    <option value="">시/군/구</option>
    <c:forEach var="g" items="${sigunguList}">
      <option value="${g}" ${param.sigungu==g?'selected':''}>${g}</option>
    </c:forEach>
  </select>
  <select class="select" name="emd">
    <option value="">읍/면/동</option>
    <c:forEach var="e" items="${emdList}">
      <option value="${e}" ${param.emd==e?'selected':''}>${e}</option>
    </c:forEach>
  </select>
  <button class="btn primary" type="submit">적용</button>
</form>

<!-- 상단 4블록 -->
<div class="row">
  <!-- 지역 군집화 -->
  <section class="card">
    <h3>지역 군집화</h3>
    <div class="mapbox" id="clusterMap" aria-label="클러스터 지도"></div>
    <div class="route-chips" style="margin-top:10px">
      <c:forEach var="cidx" items="${clusterLabels}">
        <span class="chip">Cluster ${cidx}</span>
      </c:forEach>
      <c:if test="${empty clusterLabels}">
        <span class="chip">Cluster A</span><span class="chip">Cluster B</span><span class="chip">Cluster C</span>
      </c:if>
    </div>
  </section>

  <!-- 수요 데이터 시각화 -->
  <section class="card">
    <h3>수요 데이터 시각화</h3>
    <div class="chartbox"><canvas id="demandChart" width="420" height="280" aria-label="수요 차트"></canvas></div>
  </section>
</div>

<div class="row" style="margin-top:16px">
  <!-- 금융 포용지수 -->
  <section class="card">
    <h3>금융 포용지수</h3>
    <div class="chartbox"><canvas id="inclusionChart" width="420" height="280" aria-label="포용지수 차트"></canvas></div>
  </section>

  <!-- 지역별 은행 점포 현황 -->
  <section class="card">
    <h3>지역별 은행 점포 현황</h3>
    <div class="list" style="max-height:300px; overflow:auto">
      <c:forEach var="b" items="${branchStats}">
        <div class="item">
          <div><strong>${b.bankName}</strong> · ${b.branchCount}개 지점</div>
          <div class="muted">${b.regionName}</div>
        </div>
      </c:forEach>
      <c:if test="${empty branchStats}">
        <div class="item"><div><strong>국민은행</strong> · 12개 지점</div><div class="muted">강남구</div></div>
        <div class="item"><div><strong>신한은행</strong> · 9개 지점</div><div class="muted">강남구</div></div>
        <div class="item"><div><strong>농협은행</strong> · 8개 지점</div><div class="muted">강남구</div></div>
      </c:if>
    </div>
  </section>
</div>

<!-- 일정 관리 -->
<section class="card" style="margin-top:16px">
  <h3>일정 관리</h3>
  <div class="list">
    <c:forEach var="sch" items="${scheduleList}">
      <div class="rowline">
        <div class="muted">${sch.time}</div>
        <div><strong>${sch.title}</strong> · ${sch.place}</div>
        <div><span class="chip">${sch.status}</span></div>
        <div class="links">
          <a href="${pageContext.request.contextPath}/staff/schedule/${sch.id}">상세</a>
          <a href="${pageContext.request.contextPath}/staff/schedule/${sch.id}/checkin">체크인</a>
          <a href="${pageContext.request.contextPath}/staff/schedule/${sch.id}/complete">완료</a>
        </div>
      </div>
    </c:forEach>
    <c:if test="${empty scheduleList}">
      <div class="rowline">
        <div class="muted">14:00</div>
        <div><strong>강남 이동점포 운영</strong> · 테헤란로</div>
        <div><span class="chip">예정</span></div>
        <div class="links"><a href="#">상세</a><a href="#">체크인</a><a href="#">완료</a></div>
      </div>
    </c:if>
  </div>
</section>

<!-- 간단 Placeholder 스크립트 -->
<script>
document.addEventListener('DOMContentLoaded', ()=>{
  // 수요 차트 placeholder (그대로 OK)

  // 포용지수 차트 placeholder — 수정본
  const ic=document.getElementById('inclusionChart');
  if(ic){
    const ctx=ic.getContext('2d');
    const pts=[40,240, 100,180, 160,120, 200,100, 360,180]; // x,y 반복
    ctx.beginPath(); ctx.moveTo(pts[0],pts[1]);
    for(let i=2;i<pts.length;i+=2){ ctx.lineTo(pts[i],pts[i+1]); }
    ctx.strokeStyle='#2563EB'; ctx.lineWidth=2; ctx.stroke();
  }
});
</script>


<!-- Leaflet (CDN) -->
<link rel="stylesheet" href="<c:url value='/vendor/leaflet/1.9.4/leaflet.css'/>">
<script defer src="<c:url value='/vendor/leaflet/1.9.4/leaflet.js'/>"></script>

<script defer src="<c:url value='/vendor/proj4/proj4.js'/>"></script>

<!-- 대시보드 맵 전용 설정 (GeoJSON 경로 전달) -->
<link rel="stylesheet" href="<c:url value='/css/dashboard-map.css'/>?v=${applicationScope.staticVer}">

<script>window.clusterGeoUrl = '<c:url value="/data/clustered_data.geojson"/>';
  // 대시보드 JSP의 지도 스크립트 로드 전에 넣기
  window.clusterField = 'k_weight_clustering_New_Weighted_KMeans_Cluster';       // <-- 팀원 파일의 클러스터 컬럼명
  window.nameField    = 'SIGUNGU_NM';   // <-- 지역명 컬럼명
  // (선택) 숫자 클러스터를 A/B/C/D로 보이고 싶으면 매핑
  window.clusterLabelMap = {'0':'A','1':'B','2':'C','3':'D', 0:'A',1:'B',2:'C',3:'D'};
</script>
<script defer src="<c:url value='/js/dashboard-map.js'/>?v=${applicationScope.staticVer}"></script>

<jsp:include page="/WEB-INF/views/layout/end-staff.jsp"/>
