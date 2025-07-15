<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>

<!-- Kakao Map SDK 스크립트 -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=9c8d14f1fa7135d1f77778321b1e25fa&libraries=services"></script>

<div class="main-container">
  <div class="row gx-4 gy-4 align-items-stretch">
    <!-- 지도 영역 (더 크게) -->
    <div class="col-md-9">
      <div class="card-box h-100" style="min-height:600px; display:flex; flex-direction:column;">
        <h5 class="fw-bold mb-2">🗺️ 핫플 지도</h5>
        <p class="text-muted-small mb-3">지금 가장 핫한 장소들을 지도로 한눈에 확인해보세요.</p>
        <button onclick="moveToCurrentLocation()" class="btn btn-sm btn-outline-primary mb-3 float-end d-flex align-items-center gap-1">
          <i class="bi bi-crosshair"></i>
          현재 위치로 보기
        </button>
        <div id="map" style="width: 100%; height: 600px; border-radius: 12px;"></div>
        <div class="text-end mt-2">
          <a href="<%=root %>/map/full.jsp" class="text-info">지도 전체 보기 →</a>
        </div>
      </div>
    </div>
    <!-- 오늘 핫(랭킹) 관련 코드는 별도 todayHot.jsp로 분리 -->
  </div>
</div>

<!-- 지도 관련 스크립트 -->
<script>
    var container = document.getElementById('map');
    var options = {
        center: new kakao.maps.LatLng(37.5665, 126.9780),
        level: 7
    };
    var map = new kakao.maps.Map(container, options);

    function moveToCurrentLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function (position) {
                var lat = position.coords.latitude;
                var lon = position.coords.longitude;

                var locPosition = new kakao.maps.LatLng(lat, lon);
                map.setCenter(locPosition);
                map.setLevel(5); // ✅ 확대해서 보기

                // 마커 표시
                var marker = new kakao.maps.Marker({
                    position: locPosition
                });
                marker.setMap(map);
            }, function () {
                alert('위치 정보를 가져올 수 없습니다.');
            });
        } else {
            alert('이 브라우저에서는 위치 정보가 지원되지 않습니다.');
        }
    }
</script>
