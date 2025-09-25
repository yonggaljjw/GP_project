<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<jsp:include page="/WEB-INF/views/layout/start-staff.jsp">
  <jsp:param name="pageTitle" value="알림 관리"/>
  <jsp:param name="brand" value="이동점포 · 알림 관리"/>
  <jsp:param name="active" value="alerts"/>
</jsp:include>

<div class="row">
  <!-- 알림 큐 -->
  <section class="card">
    <h3>알림 큐</h3>
    <div class="list">
      <c:forEach var="n" items="${pendingAlerts}">
        <div class="item">
          <div><strong>${n.title}</strong> · ${n.type} · ${n.scheduledAt}</div>
          <div class="links">
            <a href="${pageContext.request.contextPath}/staff/alerts/${n.id}/approve">승인</a>
            <a href="${pageContext.request.contextPath}/staff/alerts/${n.id}/cancel">취소</a>
          </div>
        </div>
      </c:forEach>
      <c:if test="${empty pendingAlerts}">
        <div class="item"><div><strong>예약 24시간 전 알림</strong> · SMS · 2025-09-27 14:00</div><div class="links"><a href="#">승인</a><a href="#">취소</a></div></div>
      </c:if>
    </div>
  </section>

  <!-- 자동 알림 규칙 -->
  <section class="card">
    <h3>자동 알림 규칙</h3>
    <div class="list">
      <c:forEach var="r" items="${rules}">
        <div class="item">
          <div><strong>${r.name}</strong> · 트리거: ${r.trigger} · 채널: ${r.channel}</div>
          <div class="links">
            <a href="${pageContext.request.contextPath}/staff/alerts/rules/${r.id}">수정</a>
            <a href="${pageContext.request.contextPath}/staff/alerts/rules/${r.id}/toggle">${r.enabled?'비활성화':'활성화'}</a>
          </div>
        </div>
      </c:forEach>
      <c:if test="${empty rules}">
        <div class="item"><div><strong>체크인 누락</strong> · 트리거: 당일 18시 미체크인 · 채널: Slack</div><div class="links"><a href="#">수정</a><a href="#">비활성화</a></div></div>
      </c:if>
    </div>
  </section>
</div>

<div class="row" style="margin-top:16px">
  <!-- 채널 설정 -->
  <section class="card">
    <h3>채널 설정</h3>
    <form method="post" action="${pageContext.request.contextPath}/staff/alerts/channels">
      <div class="list">
        <div class="item">
          <div>SMS 발신번호</div>
          <div><input class="input" type="text" name="smsFrom" value="${channels.smsFrom}" placeholder="예) 010-1234-5678"></div>
        </div>
        <div class="item">
          <div>이메일 발신자명</div>
          <div><input class="input" type="text" name="emailFromName" value="${channels.emailFromName}" placeholder="예) 이동점포 운영팀"></div>
        </div>
        <div class="item">
          <div>Slack Webhook</div>
          <div><input class="input" type="text" name="slackWebhook" value="${channels.slackWebhook}" placeholder="https://hooks.slack.com/..."></div>
        </div>
      </div>
      <div style="margin-top:12px; text-align:right">
        <button class="btn cta" type="submit">저장</button>
      </div>
      <c:if test="${not empty _csrf}"><input type="hidden" name="_csrf" value="${_csrf.token}"></c:if>
    </form>
  </section>

  <!-- 템플릿 -->
  <section class="card">
    <h3>템플릿</h3>
    <form method="post" action="${pageContext.request.contextPath}/staff/alerts/templates">
      <div class="list">
        <div class="item">
          <div>SMS</div>
          <div><textarea class="input" name="tplSms" rows="3" placeholder="[이동점포] ${예약시간} 예약 알림 - ${지점}">${templates.tplSms}</textarea></div>
        </div>
        <div class="item">
          <div>Email</div>
          <div><textarea class="input" name="tplEmail" rows="5" placeholder="이메일 템플릿 HTML/텍스트">${templates.tplEmail}</textarea></div>
        </div>
      </div>
      <div style="margin-top:12px; display:flex; gap:8px; justify-content:flex-end">
        <button class="btn" type="button" onclick="alert('테스트 발송 완료(샘플)')">테스트 발송</button>
        <button class="btn cta" type="submit">저장</button>
      </div>
      <c:if test="${not empty _csrf}"><input type="hidden" name="_csrf" value="${_csrf.token}"></c:if>
    </form>
  </section>
</div>

<jsp:include page="/WEB-INF/views/layout/end-staff.jsp"/>
