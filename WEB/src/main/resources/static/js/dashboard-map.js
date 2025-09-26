// /static/js/dashboard-map.js  — 완성본
document.addEventListener('DOMContentLoaded', function () {
  const box = document.getElementById('clusterMap');
  if (!box) return;
  if (!window.L) { console.error('[cluster-map] Leaflet not loaded'); return; }

  const map = L.map('clusterMap', { zoomControl: true, attributionControl: false });

  // GeoJSON 경로 (JSP에서 window.clusterGeoUrl을 세팅했다면 그걸 사용)
  const url = window.clusterGeoUrl || '/data/clustered_data.geojson';

  fetch(url, { cache: 'no-cache' })
    .then(r => { if (!r.ok) throw new Error('GeoJSON ' + r.status); return r.json(); })
    .then(srcGeo => {

      // ---- 1) 좌표계 판별
      const guessCrs = (geo) => {
        try {
          const f = (geo.features && geo.features[0]) || null;
          const g = f && f.geometry;
          const c0 = g && (g.type === 'Polygon'       ? g.coordinates[0][0][0]
                      : g.type === 'MultiPolygon'   ? g.coordinates[0][0][0][0]
                      : g.type === 'LineString'     ? g.coordinates[0]
                      : g.type === 'MultiLineString'? g.coordinates[0][0]
                      : g.type === 'Point'          ? g.coordinates
                      : null);
          if (!Array.isArray(c0)) return 'EPSG:4326';
          const [x, y] = c0;
          return (Math.abs(x) > 200 || Math.abs(y) > 200) ? 'EPSG:5179' : 'EPSG:4326';
        } catch { return 'EPSG:4326'; }
      };

      const crs = (srcGeo.crs && srcGeo.crs.properties && srcGeo.crs.properties.name) || guessCrs(srcGeo);

      // ---- 2) 필요 시 EPSG:5179 → EPSG:4326 변환
      let geo = srcGeo;
      if (String(crs).includes('5179') || String(crs) === 'EPSG:5179' || String(crs).includes('5181')) {
        if (!window.proj4) { throw new Error('proj4 not loaded'); }
        const DEF_5179 = '+proj=tmerc +lat_0=38 +lon_0=127.5 +k=0.9996 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +units=m +no_defs';
        const DEF_5181 = '+proj=tmerc +lat_0=38 +lon_0=127 +k=1 +x_0=200000 +y_0=500000 +ellps=GRS80 +units=m +no_defs';
        const from = String(crs).includes('5181') ? DEF_5181 : DEF_5179;
        const to   = 'EPSG:4326';

        const transformCoords = (coords) => {
          if (typeof coords[0] === 'number') {
            const [x, y] = coords;
            const [lng, lat] = proj4(from, to, [x, y]);
            return [lng, lat];
          }
          return coords.map(transformCoords);
        };

        geo = JSON.parse(JSON.stringify(srcGeo));
        geo.features.forEach(feat => {
          feat.geometry.coordinates = transformCoords(feat.geometry.coordinates);
        });
      }

      // ---- 3) 스타일/라벨 (간단 고정 버전)
      // ※ 당신 데이터 기준: 클러스터 = "k_weight_clustering_New_Weighted_KMeans_Cluster" 또는 "k_weight_clustering_Final_Cluster"
      const CLUSTER_FIELD = window.clusterField || 'k_weight_clustering_New_Weighted_KMeans_Cluster';
      const NAME_FIELD    = window.nameField    || 'SIGUNGU_NM';
      const LABEL_MAP     = window.clusterLabelMap || {'0':'A','1':'B','2':'C','3':'D', 0:'A',1:'B',2:'C',3:'D'};
      const COLORS        = { A:'#2563EB', B:'#10B981', C:'#F59E0B', D:'#EF4444' };

      const getLabel = (p) => {
        let v = p[CLUSTER_FIELD];
        if (v == null) return 'A';
        const key = (v in LABEL_MAP) ? v : String(v).trim();
        if (key in LABEL_MAP) return LABEL_MAP[key];
        return (/^\d+$/.test(key) ? (LABEL_MAP[key] || 'A') : key.toUpperCase());
      };

      const layer = L.geoJSON(geo, {
        style: f => {
          const lab = getLabel(f.properties || {});
          return { color:'#374151', weight:0.6, fillColor: COLORS[lab] || '#4B5563', fillOpacity:0.6 };
        },
        onEachFeature: (f, lyr) => {
          const name = (f.properties && f.properties[NAME_FIELD]) || '지역';
          const lab  = getLabel(f.properties || {});
          lyr.bindTooltip(`${name} · Cluster ${lab}`, { sticky:true });
          lyr.on('click', () => { try { map.fitBounds(lyr.getBounds(), { padding:[10,10] }); } catch(e){} });
        }
      }).addTo(map);

      try { map.fitBounds(layer.getBounds(), { padding:[10,10] }); }
      catch { map.setView([36.5,127.8], 7); }

      // ---- 4) 범례 (고정 4개)
      const legend = L.control({ position:'topright' });
      legend.onAdd = () => {
        const div = L.DomUtil.create('div', 'legend');
        div.style.cssText = 'background:#fff;padding:8px 10px;border:1px solid #E5E7EB;border-radius:8px;font:12px system-ui;';
        div.innerHTML = '<b>Cluster</b><br>' +
          ['A','B','C','D'].map(k =>
            `<span style="display:inline-block;width:10px;height:10px;background:${COLORS[k]};border:1px solid #ccc;margin-right:6px"></span>${k}`
          ).join('<br>');
        return div;
      };
      legend.addTo(map);
    })
    .catch(err => {
      console.error('[cluster-map]', err);
      const warn = document.createElement('div');
      warn.className = 'muted';
      warn.style.padding = '8px';
      warn.textContent = 'GeoJSON을 불러오지 못했습니다.';
      box.appendChild(warn);
    });
}); // ← DOMContentLoaded 닫기
