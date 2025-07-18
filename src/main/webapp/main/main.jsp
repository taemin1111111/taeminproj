<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, hotplace_info.*, Map.MapDao" %>
<%
    String root = request.getContextPath();
    HotplaceDao hotplaceDao = new HotplaceDao();
    MapDao mapDao = new MapDao();
    List<HotplaceDto> hotplaceList = hotplaceDao.getAllHotplaces();
    List<Map<String, Object>> sigunguCenterList = mapDao.getAllSigunguCenters();
    List<Map<String, Object>> sigunguCategoryCountList = mapDao.getSigunguCategoryCounts();
    List<Map<String, Object>> regionCenters = mapDao.getAllRegionCenters();
    List<Map<String, Object>> regionCategoryCounts = mapDao.getRegionCategoryCounts();
%>

<!-- Kakao Map SDK -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=9c8d14f1fa7135d1f77778321b1e25fa&libraries=services"></script>

<div class="main-container">
  <div class="row gx-4 gy-4 align-items-stretch">
    <div class="col-md-9">
      <div class="card-box h-100" style="min-height:600px; display:flex; flex-direction:column;">
        <h5 class="fw-bold mb-2">🗺️ 핫플 지도</h5>
        <p class="text-muted-small mb-3">지금 가장 핫한 장소들을 지도로 한눈에 확인해보세요.</p>
        <button onclick="moveToCurrentLocation()" class="btn btn-sm btn-outline-primary mb-3 float-end d-flex align-items-center gap-1">
          <i class="bi bi-crosshair"></i>
          현재 위치로 보기
        </button>
        <div id="map" style="width:100%; height:600px; border-radius:12px;"></div>
        <div class="text-end mt-2">
          <a href="<%=root%>/map/full.jsp" class="text-info">지도 전체 보기 →</a>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  // 핫플레이스 데이터
  var hotplaces = [<% for (int i = 0; i < hotplaceList.size(); i++) { HotplaceDto dto = hotplaceList.get(i); %>{id:<%=dto.getId()%>, name:'<%=dto.getName()%>', categoryId:<%=dto.getCategoryId()%>, address:'<%=dto.getAddress()%>', lat:<%=dto.getLat()%>, lng:<%=dto.getLng()%>}<% if (i < hotplaceList.size() - 1) { %>,<% } %><% } %>];
  // 시군구 중심좌표
  var sigunguCenters = [<% for (int i = 0; i < sigunguCenterList.size(); i++) { Map<String, Object> row = sigunguCenterList.get(i); %>{sido:'<%=row.get("sido")%>', sigungu:'<%=row.get("sigungu")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>}<% if (i < sigunguCenterList.size() - 1) { %>,<% } %><% } %>];
  // 시군구별 카테고리별 개수
  var sigunguCategoryCounts = [<% for (int i = 0; i < sigunguCategoryCountList.size(); i++) { Map<String, Object> row = sigunguCategoryCountList.get(i); %>{sigungu:'<%=row.get("sigungu")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>, clubCount:<%=row.get("clubCount")%>, huntingCount:<%=row.get("huntingCount")%>, loungeCount:<%=row.get("loungeCount")%>, pochaCount:<%=row.get("pochaCount")%>}<% if (i < sigunguCategoryCountList.size() - 1) { %>,<% } %><% } %>];
  // 동/구별 중심좌표, 이름, id
  var regionCenters = [<% for (int i = 0; i < regionCenters.size(); i++) { Map<String, Object> row = regionCenters.get(i); %>{id:<%=row.get("id")%>, sido:'<%=row.get("sido")%>', sigungu:'<%=row.get("sigungu")%>', dong:'<%=row.get("dong")%>', lat:<%=row.get("lat")%>, lng:<%=row.get("lng")%>}<% if (i < regionCenters.size() - 1) { %>,<% } %><% } %>];
  // 동/구별 카테고리별 개수
  var regionCategoryCounts = [<% for (int i = 0; i < regionCategoryCounts.size(); i++) { Map<String, Object> row = regionCategoryCounts.get(i); %>{region_id:<%=row.get("region_id")%>, clubCount:<%=row.get("clubCount")%>, huntingCount:<%=row.get("huntingCount")%>, loungeCount:<%=row.get("loungeCount")%>, pochaCount:<%=row.get("pochaCount")%>}<% if (i < regionCategoryCounts.size() - 1) { %>,<% } %><% } %>];

  var mapContainer = document.getElementById('map');
  var mapOptions = {
    center: new kakao.maps.LatLng(37.5665, 126.9780),
    level: 7
  };
  var map = new kakao.maps.Map(mapContainer, mapOptions);

  // 마커/오버레이 배열
  var hotplaceMarkers = [], hotplaceLabels = [], hotplaceInfoWindows = [];
  var guOverlays = [], guCountOverlays = [];
  var dongOverlays = [], dongCountOverlays = [];
  var openInfoWindow = null;
  var openRegionCountOverlay = null;

  // 핫플 마커/상호명/인포윈도우 생성 (처음엔 숨김)
  hotplaces.forEach(function(place) {
    var markerClass = '', markerText = '';
    switch(place.categoryId) {
      case 1: markerClass = 'marker-club'; markerText = 'C'; break;
      case 2: markerClass = 'marker-hunting'; markerText = 'H'; break;
      case 3: markerClass = 'marker-lounge'; markerText = 'L'; break;
      case 4: markerClass = 'marker-pocha'; markerText = 'P'; break;
      default: markerClass = 'marker-club'; markerText = 'C';
    }
    var canvas = document.createElement('canvas');
    canvas.width = 32; canvas.height = 32;
    var ctx = canvas.getContext('2d');
    var gradient;
    switch(place.categoryId) {
      case 1: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#9c27b0'); gradient.addColorStop(1,'#ba68c8'); break;
      case 2: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#f44336'); gradient.addColorStop(1,'#ef5350'); break;
      case 3: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#4caf50'); gradient.addColorStop(1,'#66bb6a'); break;
      case 4: gradient = ctx.createRadialGradient(16,16,0,16,16,16); gradient.addColorStop(0,'#8d6e63'); gradient.addColorStop(1,'#a1887f'); break;
    }
    ctx.fillStyle = gradient;
    ctx.beginPath(); ctx.arc(16,16,16,0,2*Math.PI); ctx.fill();
    ctx.shadowColor = 'rgba(0,0,0,0.3)'; ctx.shadowBlur = 4; ctx.shadowOffsetX = 2; ctx.shadowOffsetY = 2;
    ctx.fillStyle = 'white'; ctx.font = 'bold 14px Arial'; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(markerText, 16, 16);
    var markerImage = new kakao.maps.MarkerImage(canvas.toDataURL(), new kakao.maps.Size(32, 32));
    var marker = new kakao.maps.Marker({ map: null, position: new kakao.maps.LatLng(place.lat, place.lng), image: markerImage });
    var labelOverlay = new kakao.maps.CustomOverlay({ content: '<div class="marker-label">' + place.name + '</div>', position: new kakao.maps.LatLng(place.lat, place.lng), xAnchor: 0.5, yAnchor: 0, map: null });
    var infoContent = ''
      + '<div style="padding:8px; font-size:14px; line-height:1.4;">'
      +   '<strong>' + place.name + '</strong><br/>'
      +   place.address + '<br/>'
      +   '<a href="#" style="color:#1275E0; text-decoration:none;">상세보기</a>'
      + '</div>';
    var infowindow = new kakao.maps.InfoWindow({ content: infoContent });
    kakao.maps.event.addListener(marker, 'click', function() {
      if (openInfoWindow) openInfoWindow.close();
      infowindow.open(map, marker);
      openInfoWindow = infowindow;
    });
    hotplaceMarkers.push(marker);
    hotplaceLabels.push(labelOverlay);
    hotplaceInfoWindows.push(infowindow);
  });

  // 구 오버레이 생성 (17~15)
  sigunguCenters.forEach(function(center) {
    var overlay = new kakao.maps.CustomOverlay({
      content: '<div class="region-label">' + center.sigungu + '</div>',
      position: new kakao.maps.LatLng(center.lat, center.lng),
      xAnchor: 0.5, yAnchor: 0.5, map: null
    });
    guOverlays.push(overlay);
    // 카테고리별 개수 오버레이
    var count = sigunguCategoryCounts.find(c => c.sigungu === center.sigungu);
    var content = '<div class="region-counts">'
      + (count && count.clubCount ? '<span class="region-count-marker marker-club">C <span class="count">' + count.clubCount + '</span></span>' : '')
      + (count && count.huntingCount ? '<span class="region-count-marker marker-hunting">H <span class="count">' + count.huntingCount + '</span></span>' : '')
      + (count && count.loungeCount ? '<span class="region-count-marker marker-lounge">L <span class="count">' + count.loungeCount + '</span></span>' : '')
      + (count && count.pochaCount ? '<span class="region-count-marker marker-pocha">P <span class="count">' + count.pochaCount + '</span></span>' : '')
      + '</div>';
    var countOverlay = new kakao.maps.CustomOverlay({
      content: content,
      position: new kakao.maps.LatLng(center.lat, center.lng),
      xAnchor: 0.5, yAnchor: 1, map: null
    });
    guCountOverlays.push(countOverlay);
  });

  // 동 오버레이 생성 (14~6)
  regionCenters.forEach(function(center) {
    var overlay = new kakao.maps.CustomOverlay({
      content: '<div class="region-label" onclick="showDongCategoryCounts(' + center.id + ',' + center.lat + ',' + center.lng + ')">' + center.dong + '</div>',
      position: new kakao.maps.LatLng(center.lat, center.lng),
      xAnchor: 0.5, yAnchor: 0.5, map: null
    });
    dongOverlays.push(overlay);
    // 카테고리별 개수 오버레이 (기존)
    var count = regionCategoryCounts.find(c => String(c.region_id) === String(center.id));
    var content = '<div class="region-counts">'
      + (count && count.clubCount ? '<span class="region-count-marker marker-club">C <span class="count">' + count.clubCount + '</span></span>' : '')
      + (count && count.huntingCount ? '<span class="region-count-marker marker-hunting">H <span class="count">' + count.huntingCount + '</span></span>' : '')
      + (count && count.loungeCount ? '<span class="region-count-marker marker-lounge">L <span class="count">' + count.loungeCount + '</span></span>' : '')
      + (count && count.pochaCount ? '<span class="region-count-marker marker-pocha">P <span class="count">' + count.pochaCount + '</span></span>' : '')
      + '</div>';
    var countOverlay = new kakao.maps.CustomOverlay({
      content: content,
      position: new kakao.maps.LatLng(center.lat, center.lng),
      xAnchor: 0.5, yAnchor: 1, map: null
    });
    dongCountOverlays.push(countOverlay);
  });

  // 지도 레벨별 표시/숨김 토글 함수
  function updateMapOverlays() {
    var level = map.getLevel();
    // 모두 숨김
    hotplaceMarkers.forEach(m => m.setMap(null));
    hotplaceLabels.forEach(l => l.setMap(null));
    guOverlays.forEach(o => o.setMap(null));
    guCountOverlays.forEach(o => o.setMap(null));
    dongOverlays.forEach(o => o.setMap(null));
    dongCountOverlays.forEach(o => o.setMap(null));
    if (openRegionCountOverlay) {
      openRegionCountOverlay.setMap(null);
      openRegionCountOverlay = null;
    }
    if (level >= 10) {
      // 구 오버레이만 표시
      guOverlays.forEach(o => o.setMap(map));
    } else if (level >= 6) {
      // 동 오버레이만 표시
      dongOverlays.forEach(o => o.setMap(map));
    } else {
      // 핫플 마커/상호명 표시
      hotplaceMarkers.forEach(m => m.setMap(map));
      hotplaceLabels.forEach(l => l.setMap(map));
    }
  }

  kakao.maps.event.addListener(map, 'zoom_changed', updateMapOverlays);
  updateMapOverlays(); // 최초 실행

  // 구 오버레이 클릭 이벤트 (17~15)
  guOverlays.forEach(function(overlay, idx) {
    kakao.maps.event.addListener(overlay, 'click', function() {
      if (openRegionCountOverlay) openRegionCountOverlay.setMap(null);
      guCountOverlays[idx].setMap(map);
      openRegionCountOverlay = guCountOverlays[idx];
    });
  });
  // 동 오버레이 클릭 이벤트 (14~6) 제거

  // 지도 빈 공간 클릭 시 인포윈도우/카테고리 오버레이 닫기
  kakao.maps.event.addListener(map, 'click', function() {
    if (openInfoWindow) {
      openInfoWindow.close();
      openInfoWindow = null;
    }
    if (openRegionCountOverlay) {
      openRegionCountOverlay.setMap(null);
      openRegionCountOverlay = null;
    }
  });

  function moveToCurrentLocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(pos) {
        var loc = new kakao.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
        map.setCenter(loc);
        map.setLevel(5);
        new kakao.maps.Marker({ position: loc, map: map });
      }, function() {
        alert('위치 정보를 가져올 수 없습니다.');
      });
    } else {
      alert('이 브라우저에서는 위치 정보가 지원되지 않습니다.');
    }
  }

  // 오버레이 pointer-events none 적용 (지도 클릭/이동 방지 해제)
  var style = document.createElement('style');
  style.innerHTML = `
    /* 동/구 라벨은 클릭 가능해야 하므로 pointer-events: auto */
    .region-label {
      pointer-events: auto !important;
    }
    /* 카테고리 개수 오버레이만 클릭 막기 */
    .region-counts, .dong-category-counts {
      pointer-events: none !important;
    }
  `;
  document.head.appendChild(style);

  // 전역 함수: 동 카테고리별 개수 오버레이 표시
  function showDongCategoryCounts(id, lat, lng) {
    if (openRegionCountOverlay) openRegionCountOverlay.setMap(null);
    var count = regionCategoryCounts.find(c => String(c.region_id) === String(id));
    var clubCount = (count && typeof count.clubCount === 'number') ? count.clubCount : 0;
    var huntingCount = (count && typeof count.huntingCount === 'number') ? count.huntingCount : 0;
    var loungeCount = (count && typeof count.loungeCount === 'number') ? count.loungeCount : 0;
    var pochaCount = (count && typeof count.pochaCount === 'number') ? count.pochaCount : 0;
    var html = '<div class="dong-category-counts">'
      + '<span class="category-ball marker-club">C</span> : ' + clubCount
      + ' <span class="category-ball marker-hunting">H</span> : ' + huntingCount
      + ' <span class="category-ball marker-lounge">L</span> : ' + loungeCount
      + ' <span class="category-ball marker-pocha">P</span> : ' + pochaCount
      + '</div>';
    var overlay = new kakao.maps.CustomOverlay({
      content: html,
      position: new kakao.maps.LatLng(lat, lng),
      xAnchor: 0.5, yAnchor: 2.0
    });
    overlay.setMap(map);
    openRegionCountOverlay = overlay;
  }
</script>
