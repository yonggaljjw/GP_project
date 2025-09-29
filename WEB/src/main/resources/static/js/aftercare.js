// /static/js/aftercare.js
window.AC = (function(){
  const $ = (q)=>document.querySelector(q);
  if(!window.Chart){ console.error('Chart.js missing'); return {}; }

  // 전역 폰트
  Chart.defaults.font.family='system-ui,-apple-system,Segoe UI,Roboto,"Noto Sans KR",sans-serif';
  Chart.defaults.color='#1f2937';

  // 데모 데이터(실데이터 연결 전)
  const demo = {
    sentiment: [{key:'긍정',value:182},{key:'중립',value:126},{key:'부정',value:76}],
    topics:    [{key:'대기시간',value:88},{key:'응대',value:74},{key:'안내',value:52},{key:'접근성',value:44},{key:'영업시간',value:28}],
    trend:     (()=>{
      const out=[], today=new Date();
      for(let i=13;i>=0;i--){ const d=new Date(today); d.setDate(today.getDate()-i);
        out.push({key:d.toISOString().slice(5,10), value: 40+(i%7)*6 + [0,4,8,12][Math.floor(Math.random()*4)]});
      }
      return out;
    })(),
    status:    [{key:'미처리',value:22},{key:'진행',value:29},{key:'완료',value:333}]
  };

  // 차트 만들기
  function doughnut(id, labels, values, colors){
    return new Chart($(id), {type:'doughnut',
      data:{labels, datasets:[{data:values, backgroundColor:colors}]},
      options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'bottom'}}}
    });
  }
  function bar(id, labels, values, color){
    return new Chart($(id), {type:'bar',
      data:{labels, datasets:[{label:'건수', data:values, backgroundColor:color}]},
      options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true}}}
    });
  }
  function line(id, labels, values, color){
    return new Chart($(id), {type:'line',
      data:{labels, datasets:[{label:'일별', data:values, tension:.35, borderColor:color, fill:false, pointRadius:2}]},
      options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true}}}
    });
  }

  // 렌더
  function render(){
    doughnut('#acSentiment',
      demo.sentiment.map(d=>d.key),
      demo.sentiment.map(d=>d.value),
      ['#10B981','#E5E7EB','#EF4444']
    );
    bar('#acTopics',
      demo.topics.map(d=>d.key),
      demo.topics.map(d=>d.value),
      '#2563EB'
    );
    line('#acTrend',
      demo.trend.map(d=>d.key),
      demo.trend.map(d=>d.value),
      '#F59E0B'
    );
    doughnut('#acStatus',
      demo.status.map(d=>d.key),
      demo.status.map(d=>d.value),
      ['#F59E0B','#06B6D4','#10B981']
    );
  }

  // 보고서 헬퍼
  function generateDraft(){
    const el = $('#reportText');
    const total = (window.ac && window.ac.total) || 384;
    const csat  = (window.ac && window.ac.csat) || 4.3;
    const nps   = (window.ac && window.ac.nps)  || 38;
    const best  = (demo.topics[0]?.key) || '대기시간';
    const worst = '안내/표지';
    const txt = [
      `■ 운영 요약`,
      `- 총 피드백: ${total}건 / 평균 CSAT: ${csat} / NPS: ${nps}`,
      `- 긍정/중립/부정 비중: ${demo.sentiment.map(d=>d.key+': '+d.value+'건').join(', ')}`,
      ``,
      `■ 주요 이슈`,
      `- 최다 이슈: ${best} (집중 개선 필요)`,
      `- 불편 의견: ${worst} 관련 다수`,
      ``,
      `■ 개선안`,
      `1) 대기시간 실시간 안내 배너 및 번호표 알림 도입`,
      `2) 안내 동선 리뉴얼(표지판, 바닥 스티커)`,
      `3) 피크 시간대 인력 증원 및 예약 간격 조정`
    ].join('\n');
    el.value = txt;
  }
  function print(){
    const w = window.open('', 'reportWin');
    const body = `
      <html><head><meta charset="UTF-8"><title>사후관리 보고서</title>
      <style>body{font-family:system-ui,"Noto Sans KR";padding:20px;line-height:1.6}
      h1{margin:0 0 10px} pre{white-space:pre-wrap;border:1px solid #ddd;border-radius:8px;padding:12px}</style>
      </head><body>
      <h1>사후관리 보고서</h1>
      <pre>${($('#reportText')?.value||'')}</pre>
      </body></html>`;
    w.document.write(body); w.document.close(); w.focus(); w.print();
  }
  function downloadCSV(){
    const rows = [['구분','값'],
      ...demo.sentiment.map(d=>['감성:'+d.key, d.value]),
      ...demo.topics.map(d=>['주제:'+d.key, d.value]),
      ...demo.trend.map(d=>['일자:'+d.key, d.value]),
      ...demo.status.map(d=>['상태:'+d.key, d.value])
    ];
    const csv = rows.map(r=> r.map(c=> `"${String(c).replace(/"/g,'""')}"`).join(',')).join('\n');
    const blob = new Blob([csv], {type:'text/csv;charset=utf-8;'});
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob); a.download = 'aftercare_summary.csv'; a.click();
  }

  // init
  document.addEventListener('DOMContentLoaded', render);
  return { generateDraft, print, downloadCSV };
})();
