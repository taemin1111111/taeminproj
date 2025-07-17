<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, hotplace_info.*" %>
<%
    String root = request.getContextPath();
    HotplaceDao dao = new HotplaceDao();
    List<HotplaceDto> hotplaces = dao.getAllHotplaces();  // 모든 핫플 불러오기
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
  var mapContainer = document.getElementById('map');
  var mapOptions = {
    center: new kakao.maps.LatLng(37.5665, 126.9780),
    level: 7
  };
  var map = new kakao.maps.Map(mapContainer, mapOptions);

  // DB에서 가져온 핫플 마커 정보
  var hotplaces = [
    <% for (HotplaceDto dto : hotplaces) { 
         String categoryName = "";
         switch(dto.getCategoryId()) {
           case 1: categoryName = "클럽"; break;
           case 2: categoryName = "헌팅포차"; break;
           case 3: categoryName = "라운지"; break;
           case 4: categoryName = "포차거리"; break;
           default: categoryName = "";
         }
    %>
    {
      id: <%=dto.getId()%>,
      name: "<%=dto.getName()%>",
      category: "<%=categoryName%>",
      address: "<%=dto.getAddress()%>",
      lat: <%=dto.getLat()%>,
      lng: <%=dto.getLng()%>
    },
    <% } %>
  ];

  var openInfoWindow = null;

  hotplaces.forEach(function(place) {
    var marker = new kakao.maps.Marker({
      map: map,
      position: new kakao.maps.LatLng(place.lat, place.lng)
    });

    var content = ''
      + '<div style="padding:8px; font-size:14px; line-height:1.4;">'
      +   '<strong>' + place.name + (place.category ? ' <span style="color:purple;">-' + place.category + '</span>' : '') + '</strong><br/>'
      +   place.address + '<br/>'
      +   '<a href="' + '<%=root%>' + '/map/detail.jsp?id=' + place.id + '" target="_blank" style="color:#1275E0; text-decoration:none;">상세보기</a>'
      + '</div>';

    var infowindow = new kakao.maps.InfoWindow({ content: content });

    kakao.maps.event.addListener(marker, 'click', function() {
      if (openInfoWindow) {
        openInfoWindow.close();
      }
      infowindow.open(map, marker);
      openInfoWindow = infowindow;
    });
  });

  // 지도 빈 공간 클릭 시 인포윈도우 닫기
  kakao.maps.event.addListener(map, 'click', function() {
    if (openInfoWindow) {
      openInfoWindow.close();
      openInfoWindow = null;
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
</script>
