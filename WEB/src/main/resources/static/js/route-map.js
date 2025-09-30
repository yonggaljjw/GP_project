document.addEventListener('DOMContentLoaded', function() {
    // 충청남도 중심부로 초기화 (공주시 중심)
    const map = L.map('routeMap').setView([36.5, 127.0], 9);
    
    // OpenStreetMap 타일 레이어 추가
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);

    // 충청남도 주요 경유지 데이터
    const stops = [
        {name: '천안시', lat: 36.8151, lng: 127.1135},
        {name: '아산시', lat: 36.7926, lng: 127.0018},
        {name: '공주시', lat: 36.4465, lng: 127.1193},
        {name: '논산시', lat: 36.1873, lng: 127.0986},
        {name: '부여군', lat: 36.2758, lng: 126.9097},
        {name: '서천군', lat: 36.0804, lng: 126.6914}
    ];

    // 실제 도로를 따라가는 경로 포인트 (지그재그 효과)
    const routePoints = [
        [36.8151, 127.1135], // 천안
        [36.7926, 127.0018], // 아산
        [36.6521, 126.9841], // 경유1
        [36.5733, 127.0098], // 경유2
        [36.4465, 127.1193], // 공주
        [36.3245, 127.1086], // 경유3
        [36.1873, 127.0986], // 논산
        [36.2758, 126.9097], // 부여
        [36.1824, 126.8245], // 경유4
        [36.0804, 126.6914]  // 서천
    ];

    // 마커와 팝업 추가
    stops.forEach(stop => {
        L.marker([stop.lat, stop.lng])
         .bindPopup(`<b>${stop.name}</b>`)
         .addTo(map);
    });

    // 경로 라인 그리기 (지그재그 형태)
    L.polyline(routePoints, {
        color: '#FF4B2B',
        weight: 4,
        opacity: 0.7,
        smoothFactor: 1
    }).addTo(map);

    // 서비스 영역 표시 (주요 도시 중심)
    stops.forEach(stop => {
        L.circle([stop.lat, stop.lng], {
            radius: 5000,  // 반경 5km
            color: '#FF4B2B',
            fillColor: '#FF4B2B',
            fillOpacity: 0.1,
            weight: 1
        }).addTo(map);
    });

    // 경로 거리 계산 및 표시
    const bounds = L.latLngBounds(routePoints);
    map.fitBounds(bounds, {
        padding: [50, 50]
    });

    // 도로 패턴을 따라가는 화살표 표시
    routePoints.forEach((point, index) => {
        if (index < routePoints.length - 1) {
            const midPoint = [
                (point[0] + routePoints[index + 1][0]) / 2,
                (point[1] + routePoints[index + 1][1]) / 2
            ];
            
            L.circleMarker(midPoint, {
                radius: 2,
                color: '#FF4B2B',
                fillColor: '#FF4B2B',
                fillOpacity: 1
            }).addTo(map);
        }
    });
});