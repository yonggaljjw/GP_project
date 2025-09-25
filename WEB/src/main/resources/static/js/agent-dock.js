// src/main/webapp/resources/static/js/agent-dock.js
document.addEventListener('DOMContentLoaded', function () {
  const $ = (q) => document.querySelector(q);
  const dock = $('#agentDock');
  const fab  = $('#dockFab');
  if (!dock || !fab) {
    console.warn('[agent-dock] elements not found');
    return;
  }

  const btnMin   = $('#btnMin');
  const btnClear = $('#btnClear');
  const list     = $('#msgList');
  const form     = $('#chatForm');
  const input    = $('#chatInput');
  const qpWrap   = document.querySelector('.quick-prompts');

  // 열기/닫기
  const openDock  = () => { dock.classList.remove('collapsed'); fab.style.display='none'; input?.focus(); };
  const closeDock = () => { dock.classList.add('collapsed'); fab.style.display='inline-flex'; };

  fab.addEventListener('click', openDock);
  btnMin?.addEventListener('click', closeDock);

  // 빠른 프롬프트
  qpWrap?.addEventListener('click', (e) => {
    if (e.target.matches('.chip')) { input.value = e.target.dataset.txt || ''; input.focus(); }
  });

  // 메시지 유틸
  const el = (t,c,tx) => { const n=document.createElement(t); if(c)n.className=c; if(tx)n.textContent=tx; return n; };
  const pushMsg = (role, text) => {
    const row = el('div','msg '+(role==='user'?'user':'agent'));
    row.append(el('div','avatar', role==='user'?'U':'A'), el('div','bubble', text));
    list.append(row); list.scrollTop = list.scrollHeight;
  };
  const setTyping = (on) => {
    let t = document.getElementById('typing');
    if (on && !t){ t = el('div','typing','응답 생성 중…'); t.id='typing'; list.append(t); }
    if (!on && t){ t.remove(); }
    list.scrollTop = list.scrollHeight;
  };

  // 대화 초기화
  btnClear?.addEventListener('click', () => { list.innerHTML=''; sessionStorage.removeItem('agent:conv'); });

  // Shift+Enter 줄바꿈 / Enter 전송
  input?.addEventListener('keydown',(e)=>{
    if(e.key==='Enter' && !e.shiftKey){ e.preventDefault(); form?.dispatchEvent(new Event('submit')); }
  });

  // 전송 (REST 샘플)
  async function sendViaRest(content){
    const payload = { message: content, context:{ page: location.pathname } };
    const res = await fetch((window.ctx||'') + '/staff/agent/chat', {
      method:'POST',
      headers:{ 'Content-Type':'application/json', ...(window.csrfToken?{'X-CSRF-TOKEN':window.csrfToken}:{}) },
      body: JSON.stringify(payload),
      credentials: 'same-origin'
    });
    if(!res.ok) throw new Error('Agent 응답 오류');
    const data = await res.json().catch(()=> ({}));
    return data.reply || '(응답 없음)';
  }

  form?.addEventListener('submit', async (e)=>{
    e.preventDefault();
    const text = (input?.value || '').trim();
    if(!text) return;
    pushMsg('user', text); if (input) input.value = ''; setTyping(true);
    try { const reply = await sendViaRest(text); pushMsg('agent', reply); }
    catch(err){ console.error(err); pushMsg('agent','죄송해요, 잠시 후 다시 시도해주세요.'); }
    finally { setTyping(false); }
  });
});
