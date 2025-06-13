<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
%>

<!-- Kakao Map SDK 스크립트 -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=9c8d14f1fa7135d1f77778321b1e25fa&libraries=services"></script>

<div class="main-container">

    <!-- 🔥 오늘 핫 -->
    <div class="section mb-5">
        <h3 class="section-title">
            <img src="<%=root %>/logo/fire.png">
            오늘 핫
        </h3>
        <div class="row gx-3 gy-4">
            <!-- 1위~3위 카드 반복 -->
            <div class="col-md-4">
                <div class="card-box">
                    <div class="fs-5 fw-bold">1위 · 종로 포차거리</div>
                    <div class="text-muted-small">🔥 투표율 41% | 후기 39건</div>
                    <div class="mt-2 text-secondary">#헌팅각 #포차 #시끌벅적 #20대</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card-box">
                    <div class="fs-5 fw-bold">2위 · 홍대 거리</div>
                    <div class="text-muted-small">🔥 투표율 34% | 후기 28건</div>
                    <div class="mt-2 text-secondary">#술집 #썸각 #혼잡 #밤감성</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card-box">
                    <div class="fs-5 fw-bold">3위 · 강남역</div>
                    <div class="text-muted-small">🔥 투표율 25% | 후기 19건</div>
                    <div class="mt-2 text-secondary">#깔끔 #소개팅 #고급술집 #데이트</div>
                </div>
            </div>
        </div>
    </div>

    <!-- 🗺️ 지도 + 어제 핫 -->
    <div class="row gx-3 gy-4">
        <!-- 지도 영역 -->
        <div class="col-md-8">
            <div class="card-box">
                <h5 class="fw-bold mb-2">🗺️ 핫플 지도</h5>
                <p class="text-muted-small mb-3">지금 가장 핫한 장소들을 지도로 한눈에 확인해보세요.</p>

                <!-- 현재 위치 보기 버튼 -->
                <button onclick="moveToCurrentLocation()" class="btn btn-sm btn-outline-primary mb-3 float-end d-flex align-items-center gap-1">
                    <i class="bi bi-crosshair"></i>
                    현재 위치로 보기
                </button>

                <!-- 실제 지도 표시 -->
                <div id="map" style="width: 100%; height: 400px; border-radius: 12px;"></div>

                <div class="text-end mt-2">
                    <a href="<%=root %>/map/full.jsp" class="text-info">지도 전체 보기 →</a>
                </div>
            </div>
        </div>

        <!-- 어제 핫했던 지역 -->
        <div class="col-md-4">
            <div class="card-box">
                <h5 class="fw-bold mb-3">🕙 어제 핫했던 곳</h5>
                <ul class="list-unstyled">
                    <li class="mb-3">
                        <strong>1위 · 신림 포차거리</strong><br>
                        <span class="text-muted-small">💬 후기 52건 | 추천 31</span>
                    </li>
                    <li class="mb-3">
                        <strong>2위 · 이태원</strong><br>
                        <span class="text-muted-small">💬 후기 37건 | 추천 24</span>
                    </li>
                    <li>
                        <strong>3위 · 건대입구</strong><br>
                        <span class="text-muted-small">💬 후기 21건 | 추천 18</span>
                    </li>
                </ul>
            </div>
        </div>
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
