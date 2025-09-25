<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<jsp:include page="/WEB-INF/views/layout/start-staff.jsp">
  <jsp:param name="pageTitle" value="경로 추천"/>
  <jsp:param name="brand" value="이동점포 · 경로 추천"/>
  <jsp:param name="active" value="routes"/>
  <jsp:param name="pageCss" value="/resources/static/css/staff.css"/>
</jsp:include>

<!-- 상단: 추천 경로 맵 + 경로별 요약 -->
<div class="row">
  <section class="card">
    <h3>추천 경로(시뮬레이션)</h3>
    <div class="mapbox" id="routeMap"></div>
    <div class="route-chips">
      <c:forEach var="stop" items="${routePreview.stops}">
        <span class="chip">${stop.name}</span>
      </c:forEach>
      <c:if test="${empty routePreview.stops}">
        <span class="chip">정차지 1</span><span class="chip">정차지 2</span><span class="chip">정차지 3</span>
      </c:if>
    </div>
  </section>

  <section class="card">
    <h3>경로별 정보</h3>
    <div class="kpis">
      <div class="kpi"><div class="label">총 거리</div><div class="num">${kpi.totalDistanceKm!=null?kpi.totalDistanceKm:84} km</div></div>
      <div class="kpi"><div class="label">예상 처리</div><div class="num">${kpi.expectedCount!=null?kpi.expectedCount:132}건</div></div>
      <div class="kpi"><div class="label">커버율</div><div class="num">${kpi.coverage!=null?kpi.coverage:76}%</div></div>
      <div class="kpi warn"><div class="label">예상 비용(만원)</div><div class="num">${kpi.cost!=null?kpi.cost:215}</div></div>
    </div>
  </section>
</div>

<!-- 세부 조정 폼 -->
<section class="card">
  <h3>세부 조정</h3>
  <form method="post" action="${pageContext.request.contextPath}/staff/routes/adjust">
    <div class="list">
      <div class="item">
        <div>운영일자</div>
        <div>
          <input class="input" type="date" name="date" value="${param.date}">
          <input class="input" type="time" name="startTime" value="${param.startTime}">
        </div>
      </div>
      <div class="item">
        <div>차량/인력</div>
        <div>
          <input class="input" type="number" name="vehicles" min="1" placeholder="차량 수" style="width:140px">
          <input class="input" type="number" name="staff" min="1" placeholder="인원" style="width:140px">
        </div>
      </div>
      <div class="item">
        <div>제약 조건</div>
        <div>
          <input class="input" type="number" name="maxDistance" placeholder="최대 이동거리(km)" style="width:180px">
          <input class="input" type="number" name="maxStops" placeholder="최대 정차 수" style="width:160px">
          <select class="select" name="scenario" style="width:180px">
            <option value="min_cost">최소 비용</option>
            <option value="max_cover">최대 커버</option>
            <option value="balanced" selected>균형안</option>
          </select>
        </div>
      </div>
      <div class="item">
        <div>정차지 조정</div>
        <div>
          <textarea class="input" name="customStops" rows="3" placeholder="예) 역삼역→선릉역→정자역 순서로 변경" style="width:100%;height:76px"></textarea>
        </div>
      </div>
    </div>
    <div style="margin-top:12px; display:flex; gap:8px; justify-content:flex-end">
      <button class="btn primary" type="submit" name="action" value="simulate">재시뮬레이션</button>
      <button class="btn cta" type="submit" name="action" value="confirm">경로 확정</button>
      <a class="btn" href="${pageContext.request.contextPath}/staff/routes/report" style="text-decoration:none">보고서 생성</a>
    </div>
    <c:if test="${not empty _csrf}">
      <input type="hidden" name="_csrf" value="${_csrf.token}">
    </c:if>
  </form>
</section>

<!-- 대안 경로 카드 -->
<div class="routes">
  <div class="route">
    <h4>경로안 1 · 최소 비용</h4>
    <div class="meta">
      <div><div class="muted">총 거리</div>${route1.distanceKm!=null?route1.distanceKm:60} km</div>
      <div><div class="muted">예상 처리</div>${route1.jobs!=null?route1.jobs:120} 건</div>
      <div><div class="muted">커버율</div>${route1.coverage!=null?route1.coverage:70}%</div>
      <div><div class="muted">예상 비용</div>${route1.cost!=null?route1.cost:200} 만원</div>
    </div>
    <div class="footer"><button class="btn" onclick="location.href='${pageContext.request.contextPath}/staff/routes/detail?type=min_cost'">상세 보기</button></div>
  </div>

  <div class="route">
    <h4>경로안 2 · 최대 포용</h4>
    <div class="meta">
      <div><div class="muted">총 거리</div>${route2.distanceKm!=null?route2.distanceKm:72} km</div>
      <div><div class="muted">예상 처리</div>${route2.jobs!=null?route2.jobs:110} 건</div>
      <div><div class="muted">커버율</div>${route2.coverage!=null?route2.coverage:78}%</div>
      <div><div class="muted">예상 비용</div>${route2.cost!=null?route2.cost:215} 만원</div>
    </div>
    <div class="footer"><button class="btn" onclick="location.href='${pageContext.request.contextPath}/staff/routes/detail?type=max_cover'">상세 보기</button></div>
  </div>

  <div class="route">
    <h4>경로안 3 · 균형안</h4>
    <div class="meta">
      <div><div class="muted">총 거리</div>${route3.distanceKm!=null?route3.distanceKm:84} km</div>
      <div><div class="muted">예상 처리</div>${route3.jobs!=null?route3.jobs:100} 건</div>
      <div><div class="muted">커버율</div>${route3.coverage!=null?route3.coverage:86}%</div>
      <div><div class="muted">예상 비용</div>${route3.cost!=null?route3.cost:230} 만원</div>
    </div>
    <div class="footer"><button class="btn cta" onclick="if(confirm('해당 경로안을 확정할까요?')) location.href='${pageContext.request.contextPath}/staff/routes/confirm?type=balanced'">이 안으로 확정</button></div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/layout/end-staff.jsp"/>
