<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

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

<button id="dockFab" class="dock-fab" aria-label="AI Agent 열기" type="button" title="AI Agent 열기">
  <!-- chat-bubble SVG -->
  <svg width="24" height="24" viewBox="0 0 24 24" aria-hidden="true">
    <path d="M4 4h16v10a4 4 0 0 1-4 4H9l-5 3v-3.5A3.5 3.5 0 0 1 0 14V8a4 4 0 0 1 4-4Z" fill="currentColor"/>
  </svg>
</button>
