// /static/js/demand-viz-demo-grid.js  (수정본)
document.addEventListener('DOMContentLoaded', () => {
  if (!window.Chart) { console.error('Chart.js missing'); return; }

  // 전역 폰트/컬러 (보기 좋게)
  Chart.defaults.font.family = 'system-ui, -apple-system, Segoe UI, Roboto, "Noto Sans KR", sans-serif';
  Chart.defaults.color = '#1f2937';

  const $ = (id) => document.getElementById(id);
  const palette = ['#2563EB','#10B981','#F59E0B','#EF4444','#8B5CF6','#06B6D4','#84CC16','#F472B6'];

  // ✅ 데모 데이터 (오타 수정: {key:'...', value:숫자})
  const demo = {
    byRegion: [
      {key:'강남구', value:120},{key:'종로구', value:95},{key:'수원시', value:80},
      {key:'부산진구', value:64},{key:'춘천시', value:48},{key:'전주시', value:44},
      {key:'청주시', value:40},{key:'제주시', value:36},{key:'천안시', value:34},{key:'인천시', value:32}
    ],
    byPurpose: [
      {key:'예금', value:130},{key:'대출', value:92},{key:'상담', value:58},{key:'카드', value:44},{key:'기타', value:28}
    ],
    byRegionPurpose: {
      rows:['강남구','종로구','수원시','부산진구','전주시'],
      cols:['예금','대출','상담','카드'],
      values:[
        [60,40,12,8],
        [35,30,20,10],
        [30,28,14,8],
        [28,20,10,6],
        [22,12,8,2]
      ]
    },
    trendDaily: (() => {
      const out = [], today = new Date();
      for (let i=13;i>=0;i--){
        const d = new Date(today); d.setDate(today.getDate()-i);
        const label = d.toISOString().slice(5,10); // MM-DD
        const base = 55 + (6-(i%7))*6; // 요일 효과
        const noise = [0,4,8,12,16][Math.floor(Math.random()*5)];
        out.push({key:label, value: base+noise});
      }
      return out;
    })()
  };

  // 그라디언트(라인 차트 배경)
  function gradient(ctx, hex) {
    const g = ctx.createLinearGradient(0,0,0,ctx.canvas.height);
    g.addColorStop(0, hex + 'B3'); // ~70% 투명
    g.addColorStop(1, hex + '14'); // ~8% 투명
    return g;
  }

  // 1) 지역별 Top10 — 막대
  new Chart($('chartRegion'), {
    type: 'bar',
    data: {
      labels: demo.byRegion.map(d=>d.key),
      datasets: [{ label:'신청 수', data: demo.byRegion.map(d=>d.value), backgroundColor: palette[0] }]
    },
    options: {
      responsive:true, maintainAspectRatio:false,
      plugins:{ legend:{display:false}, tooltip:{callbacks:{label:c=>` ${c.parsed.y.toLocaleString()} 건`}} },
      scales:{ y:{ beginAtZero:true, ticks:{ callback:v=>v.toLocaleString()+'건' } } }
    }
  });

  // 2) 목적별 — 도넛
  new Chart($('chartPurpose'), {
    type: 'doughnut',
    data: {
      labels: demo.byPurpose.map(d=>d.key),
      datasets: [{ data: demo.byPurpose.map(d=>d.value), backgroundColor: palette.slice(0, demo.byPurpose.length) }]
    },
    options: {
      responsive:true, maintainAspectRatio:false,
      plugins:{ legend:{ position:'bottom' }, tooltip:{callbacks:{label:c=>` ${c.label}: ${c.parsed.toLocaleString()} 건`}} }
    }
  });

  // 3) 교차(지역×목적) — 누적 막대
  {
    const rows = demo.byRegionPurpose.rows, cols = demo.byRegionPurpose.cols, vals = demo.byRegionPurpose.values;
    const datasets = cols.map((c, i) => ({
      label: c,
      data: rows.map((_, ri) => vals[ri][i]),
      backgroundColor: palette[i % palette.length],
      stack: 'stack1'
    }));
    new Chart($('chartCross'), {
      type: 'bar',
      data: { labels: rows, datasets },
      options: {
        responsive:true, maintainAspectRatio:false,
        plugins:{ legend:{ position:'bottom' } },
        scales:{ x:{ stacked:true }, y:{ stacked:true, beginAtZero:true, ticks:{callback:v=>v.toLocaleString()+'건'} } }
      }
    });
  }

  // 4) 최근 2주 추이 — 라인
  {
    const T = demo.trendDaily;
    const ctx = $('chartTrend').getContext('2d');
    const base = '#EF4444';
    new Chart(ctx, {
      type:'line',
      data:{
        labels: T.map(d=>d.key),
        datasets: [{
          label:'일별 신청 수',
          data: T.map(d=>d.value),
          tension:.35,
          fill:true,
          backgroundColor: gradient(ctx, base.replace('#','')),
          borderColor: base,
          pointRadius: 2
        }]
      },
      options:{
        responsive:true, maintainAspectRatio:false,
        plugins:{ legend:{display:false}, tooltip:{callbacks:{label:c=>` ${c.parsed.y.toLocaleString()} 건`}} },
        scales:{ y:{ beginAtZero:true, ticks:{ callback:v=>v.toLocaleString()+'건' } } }
      }
    });
  }
});
