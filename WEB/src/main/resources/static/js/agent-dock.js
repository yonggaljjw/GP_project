document.addEventListener('DOMContentLoaded', function () {
  const $ = (q) => document.querySelector(q);
  const dock = $('#agentDock'), fab = $('#dockFab');
  if (!dock || !fab) { console.warn('[agent-dock] elements not found'); return; }

  const btnMin = $('#btnMin'), btnClear = $('#btnClear');
  const list = $('#msgList'), form = $('#chatForm'), input = $('#chatInput');
  const qpWrap = document.querySelector('.quick-prompts');

  const openDock = () => { dock.classList.remove('collapsed'); fab.style.display='none'; input && input.focus(); };
  const closeDock = () => { dock.classList.add('collapsed'); fab.style.display='inline-flex'; };

  fab.addEventListener('click', openDock);
  btnMin && btnMin.addEventListener('click', closeDock);

  qpWrap && qpWrap.addEventListener('click',(e)=>{
    const t = e.target;
    if (t && t.matches('.chip')) { if (input) { input.value = t.dataset.txt || ''; input.focus(); } }
  });

  const el=(t,c,tx)=>{const n=document.createElement(t); if(c)n.className=c; if(tx)n.textContent=tx; return n;};
  const pushMsg=(role,text)=>{const r=el('div','msg '+(role==='user'?'user':'agent')); r.append(el('div','avatar',role==='user'?'U':'A'),el('div','bubble',text)); list.append(r); list.scrollTop=list.scrollHeight;};
  const setTyping=(on)=>{let t=document.getElementById('typing'); if(on && !t){t=el('div','typing','응답 생성 중…'); t.id='typing'; list.append(t);} if(!on && t){t.remove();} list.scrollTop=list.scrollHeight;};

  btnClear && btnClear.addEventListener('click',()=>{ list.innerHTML=''; sessionStorage.removeItem('agent:conv'); });
  input && input.addEventListener('keydown',(e)=>{ if(e.key==='Enter' && !e.shiftKey){ e.preventDefault(); form && form.dispatchEvent(new Event('submit')); }});

  async function sendViaRest(content){
    const url=(window.ctx||'') + '/staff/agent/chat';
    const res=await fetch(url,{ method:'POST', headers:{'Content-Type':'application/json', ...(window.csrfToken?{'X-CSRF-TOKEN':window.csrfToken}:{})}, body:JSON.stringify({message:content, context:{page:location.pathname}}), credentials:'same-origin' });
    if(!res.ok) throw new Error('Agent 응답 오류 '+res.status);
    const data=await res.json().catch(()=> ({}));
    return data.reply || '(응답 없음)';
  }

  form && form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    const text=(input && input.value || '').trim(); if(!text) return;
    pushMsg('user',text); if(input) input.value=''; setTyping(true);
    try{ const reply=await sendViaRest(text); pushMsg('agent',reply); }
    catch(err){ console.error('[agent-dock]',err); pushMsg('agent','죄송해요, 잠시 후 다시 시도해주세요.'); }
    finally{ setTyping(false); }
  });

  console.debug('[agent-dock] initialized');
});
