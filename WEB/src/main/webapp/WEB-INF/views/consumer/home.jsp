<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<jsp:include page="/WEB-INF/views/layout/start-customer.jsp">
  <jsp:param name="pageTitle" value="소비자 메인"/>
  <jsp:param name="brand" value="미정"/>
  <jsp:param name="pageCss" value="/resources/static/css/customer.css"/>
</jsp:include>

<div class="actions">
  <a class="btn primary soft" href="${pageContext.request.contextPath}/reservation/new">예약하기</a>
  <a class="btn outline" href="${pageContext.request.contextPath}/reservation/list">내 예약</a>
  <a class="btn outline" href="${pageContext.request.contextPath}/notifications">알림</a>
  <a class="btn outline" href="${pageContext.request.contextPath}/support">고객센터</a>
</div>

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

<div class="card">
  <h3>알림</h3>
  <ul class="muted" style="margin:8px 0 0 18px;">
    <li>서류 준비 안내: 신분증, 위임장</li>
    <li>위치 변경 공지: 강남점 → 역삼점</li>
    <li>예약 24시간 전 알림이 발송됩니다.</li>
  </ul>
</div>

<jsp:include page="/WEB-INF/views/layout/end-customer.jsp"/>
