document.addEventListener('DOMContentLoaded', function () {
  const $ = (q) => document.querySelector(q);
  const dock = $('#agentDock'), fab = $('#dockFab');
  if (!dock || !fab) { console.warn('[agent-dock] elements not found'); return; }

  const btnMin = $('#btnMin'), btnClear = $('#btnClear');
  const list = $('#msgList'), form = $('#chatForm'), input = $('#chatInput');
  const qpWrap = document.querySelector('.quick-prompts');

  // === 상태 ===
  let chatId = null;
  const userId = 1;  // 세션 사용자 ID
  const API_BASE = ; // FastAPI 서버

  // === Dock 열고 닫기 ===
  const openDock = async () => {
    dock.classList.remove('collapsed');
    fab.style.display='none';
    input && input.focus();
    await loadHistory();
  };
  const closeDock = () => {
    dock.classList.add('collapsed');
    fab.style.display='inline-flex';
  };

  fab.addEventListener('click', openDock);
  btnMin && btnMin.addEventListener('click', closeDock);

  // === Quick Prompts ===
  qpWrap && qpWrap.addEventListener('click',(e)=>{
    const t = e.target;
    if (t && t.matches('.chip')) {
      if (input) { input.value = t.dataset.txt || ''; input.focus(); }
    }
  });

  // === DOM Util ===
  const el=(t,c,tx)=>{const n=document.createElement(t); if(c)n.className=c; if(tx)n.textContent=tx; return n;};
  function pushMsg(role,text){
    const r=el('div','msg '+(role==='user'?'user':'agent'));
    const av=el('div','avatar',role==='user'?'U':'A');
    const bub=el('div','bubble');
    // ✅ marked 렌더링
    bub.innerHTML = (window.marked ? marked.parse(text) : text);
    r.append(av,bub); list.append(r); list.scrollTop=list.scrollHeight;
  }
  function setTyping(on){
    let t=document.getElementById('typing');
    if(on && !t){t=el('div','typing','응답 생성 중…'); t.id='typing'; list.append(t);}
    if(!on && t){t.remove();}
    list.scrollTop=list.scrollHeight;
  }

  // === 대화 초기화 ===
  btnClear && btnClear.addEventListener('click',()=>{
    list.innerHTML='';
    chatId=null;
    sessionStorage.removeItem('agent:conv');
  });

  // === Shift+Enter 줄바꿈 ===
  input && input.addEventListener('keydown',(e)=>{
    if(e.key==='Enter' && !e.shiftKey){
      e.preventDefault();
      form && form.dispatchEvent(new Event('submit'));
    }
  });

  // === FastAPI 연동 ===
  async function createChatroom(firstMessage){
    const res=await fetch(API_BASE+"/api/chatroom/create",{
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({ user_id:userId, first_message:firstMessage })
    });
    if(!res.ok) throw new Error('채팅방 생성 실패');
    return await res.json();
  }

  async function sendMessage(chatId,message){
    const res=await fetch(API_BASE+"/api/chat",{
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({ user_id:userId, chat_id:chatId, message })
    });
    if(!res.ok) throw new Error('메시지 전송 실패');
    return await res.json();
  }

  async function loadHistory(){
    if(!chatId) return;
    const res=await fetch(`${API_BASE}/api/chatroom/history/${userId}/${chatId}`);
    if(res.ok){
      const history=await res.json();
      history.forEach(m=>pushMsg(m.role,m.text));
    }
  }

  async function sendViaRest(content){
    if(chatId===null){
      const data=await createChatroom(content);
      chatId=data.chat_id;
      return data.reply ?? data.first_response;
    } else {
      const data=await sendMessage(chatId,content);
      return data.reply ?? data.response;
    }
  }

  // === 전송 처리 ===
  form && form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    const text=(input && input.value || '').trim();
    if(!text) return;
    pushMsg('user',text);
    if(input) input.value='';
    setTyping(true);
    try{
      const reply=await sendViaRest(text);
      pushMsg('agent',reply);
    }
    catch(err){
      console.error('[agent-dock]',err);
      pushMsg('agent','죄송해요, 잠시 후 다시 시도해주세요.');
    }
    finally{ setTyping(false); }
  });

  console.debug('[agent-dock] initialized');
});
