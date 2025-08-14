<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, hotplace_info.*, Map.MapDao, ClubGenre.*, content_images.*, content_info.*" %>
<%
    String root = request.getContextPath();
    HotplaceDao hotplaceDao = new HotplaceDao();
    MapDao mapDao = new MapDao();
    ClubGenreDao clubGenreDao = new ClubGenreDao();
    ContentImagesDao contentImagesDao = new ContentImagesDao();
    ContentInfoDao contentInfoDao = new ContentInfoDao();
    List<HotplaceDto> hotplaceList = hotplaceDao.getAllHotplaces();
    List<Map<String, Object>> sigunguCenterList = mapDao.getAllSigunguCenters();
    List<Map<String, Object>> sigunguCategoryCountList = mapDao.getSigunguCategoryCounts();
    List<Map<String, Object>> regionCenters = mapDao.getAllRegionCenters();
    List<Map<String, Object>> regionCategoryCounts = mapDao.getRegionCategoryCounts();
    String loginId = (String)session.getAttribute("loginid");
    String provider = (String)session.getAttribute("provider");
    System.out.println("loginId in session: " + loginId); 
    List<String> regionNameList = mapDao.getAllRegionNames();
    List<String> hotplaceNameList = hotplaceDao.getAllHotplaceNames();
    
    // ✅ 지역별 평균 평점 데이터 로드
    Map<String, Double> regionRatings = mapDao.getRegionAverageRatings();
%>
<script>
  var root = '<%=root%>';
  var isLoggedIn = <%= (loginId != null) ? "true" : "false" %>;
  var loginUserId = '<%= (loginId != null ? loginId : "") %>';
  var isAdmin = <%= (provider != null && "admin".equals(provider)) ? "true" : "false" %>;
  var regionNameList = [<% for(int i=0;i<regionNameList.size();i++){ %>'<%=regionNameList.get(i).replace("'", "\\'")%>'<% if(i<regionNameList.size()-1){%>,<%}}%>];
  var hotplaceNameList = [<% for(int i=0;i<hotplaceNameList.size();i++){ %>'<%=hotplaceNameList.get(i).replace("'", "\\'")%>'<% if(i<hotplaceNameList.size()-1){%>,<%}}%>];
  
  // ✅ 지역별 평균 평점 데이터
  var regionRatings = {<% 
    java.util.Iterator<Map.Entry<String, Double>> iterator = regionRatings.entrySet().iterator();
    while(iterator.hasNext()) { 
      Map.Entry<String, Double> entry = iterator.next(); 
  %>'<%=entry.getKey().replace("'", "\\'")%>':<%=entry.getValue()%><% if(iterator.hasNext()) { %>,<% } %><% } %>};
  
  // URL 파라미터에서 lat, lng 가져오기
  var urlParams = new URLSearchParams(window.location.search);
  var targetLat = urlParams.get('lat');
  var targetLng = urlParams.get('lng');
  
  // URL 파라미터가 있으면 해당 위치로 이동할 준비
  if (targetLat && targetLng) {
    console.log('URL 파라미터 감지: lat=' + targetLat + ', lng=' + targetLng);
  }
</script>
<script>
  var dongToRegionId = {
    <% for(int i=0;i<regionCenters.size();i++){ Map<String,Object> row=regionCenters.get(i); %>
      '<%=row.get("dong")%>': <%=row.get("id")%><% if(i<regionCenters.size()-1){%>,<%}%>
    <% } %>
  };
</script>

<!-- Kakao Map SDK -->
<script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=9c8d14f1fa7135d1f77778321b1e25fa&libraries=services"></script>
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/all.css">

<div class="main-container">
  <div class="row gx-4 gy-4 align-items-stretch">
    <div class="col-md-9">
      <div class="card-box h-100" style="min-height:600px; display:flex; flex-direction:column; position:relative;">
        <div style="text-align: center;">
          <img src="<%=root%>/logo/hotmap.png" alt="핫플 지도" style="max-width: 70px; height: auto; object-fit: contain; margin-bottom: 0; margin-top: -16px; display: block; margin-left: auto; margin-right: auto;">
          <p class="text-muted-small mb-3" style="display: inline-block; margin-top: -8px;">지금 가장 핫한 장소들을 지도로 한눈에 확인해보세요.</p>
        </div>
        <button onclick="moveToCurrentLocation()" class="btn btn-sm btn-outline-primary mb-3 d-flex align-items-center gap-1 map-location-btn" style="width:110px; min-width:unset; padding: 4px 10px; font-size: 0.85rem; border-radius: 18px; display: block; margin-left: 0; float: left;">
          <i class="bi bi-crosshair"></i>
          내 위치
        </button>
        <div id="map" style="width:100%; height:600px; border-radius:12px; position:relative;">
          <div id="categoryFilterBar" style="position:absolute; top:16px; left:16px; z-index:10; display:flex; gap:8px;">
            <button class="category-filter-btn active" data-category="all">전체</button>
            <button class="category-filter-btn marker-club" data-category="1">C</button>
            <button class="category-filter-btn marker-hunting" data-category="2">H</button>
            <button class="category-filter-btn marker-lounge" data-category="3">L</button>
            <button class="category-filter-btn marker-pocha" data-category="4">P</button>
          </div>
          <!-- 오른쪽 패널 토글 버튼 및 패널 (위치 동적 변경) -->
          <button id="rightPanelToggleBtn" style="position:absolute; top:50%; right:0; transform:translateY(-50%); z-index:20; background:#fff; border-radius:8px 0 0 8px; border:1.5px solid #ddd; border-right:none; width:36px; height:56px; box-shadow:0 2px 8px rgba(0,0,0,0.10); display:flex; align-items:center; justify-content:center; font-size:1.5rem; cursor:pointer; transition:background 0.15s;">&lt;</button>
          <div id="rightPanel" style="position:absolute; top:0; right:0; height:100%; width:360px; max-width:90vw; background:#fff; box-shadow:-2px 0 16px rgba(0,0,0,0.10); z-index:30; border-radius:16px 0 0 16px; transform:translateX(100%); transition:transform 0.35s cubic-bezier(.77,0,.18,1); display:flex; flex-direction:column;">
            <button id="rightPanelCloseBtn" style="position:absolute; left:-36px; top:50%; transform:translateY(-50%); width:36px; height:56px; background:#fff; border-radius:8px 0 0 8px; border:1.5px solid #ddd; border-left:none; box-shadow:0 2px 8px rgba(0,0,0,0.10); display:flex; align-items:center; justify-content:center; font-size:1.5rem; cursor:pointer; display:none;">&gt;</button>
            <!-- 검색창 -->
            <div id="searchBar" style="position:sticky; top:0; background:#fff; z-index:10; padding:24px 20px 12px 20px; box-shadow:0 2px 8px rgba(0,0,0,0.04);">
              <!-- 검색 타입 드롭다운 -->
              <style>
                .search-type-dropdown { position:relative; }
                .search-type-btn { display:flex; align-items:center; gap:4px; background:#f5f6fa; border:1.5px solid #e0e0e0; border-radius:16px; font-size:0.93rem; font-weight:500; color:#222; padding:0 10px; height:32px; min-width:54px; max-width:70px; cursor:pointer; transition:border 0.18s, background 0.18s; outline:none; white-space:nowrap; }
                .search-type-btn:focus, .search-type-btn.active { border:1.5px solid #1275E0; background:#fff; }
                .search-type-arrow { font-size:1em; color:#888; margin-left:2px; }
                .search-type-list { position:absolute; top:110%; left:0; min-width:54px; background:#fff; border:1.5px solid #e0e0e0; border-radius:10px; box-shadow:0 4px 16px rgba(0,0,0,0.08); z-index:10; display:none; flex-direction:column; padding:2px 0; }
                .search-type-list.show { display:flex; }
                .search-type-item { padding:6px 14px; font-size:0.93rem; color:#222; background:none; border:none; text-align:left; cursor:pointer; transition:background 0.13s; white-space:nowrap; }
                .search-type-item:hover, .search-type-item.selected { background:#f0f4fa; color:#1275E0; }
              </style>
              <form style="display:flex; align-items:center; gap:8px; position:relative; min-width:0;" onsubmit="return false;">
                  <div class="search-type-dropdown" id="searchTypeDropdown" style="flex:0 0 60px; min-width:54px; max-width:70px;">
                    <button type="button" class="search-type-btn" id="searchTypeBtn" style="width:100%; min-width:54px; max-width:70px; justify-content:center;">
                      <span id="searchTypeText">지역</span>
                      <span class="search-type-arrow">&#9660;</span>
                    </button>
                    <div class="search-type-list" id="searchTypeList">
                      <button type="button" class="search-type-item selected" data-type="지역">지역</button>
                      <button type="button" class="search-type-item" data-type="가게">가게</button>
                    </div>
                  </div>
                  <div style="position:relative; flex:1; min-width:0;">
                    <input type="text" id="searchInput" placeholder="지역, 장소 검색 가능" style="width:100%; height:44px; border-radius:24px; border:1.5px solid #e0e0e0; background:#fafbfc; font-size:1.08rem; padding:0 44px 0 18px; box-shadow:0 2px 8px rgba(0,0,0,0.03); outline:none; transition:border 0.18s; min-width:0;" autocomplete="off" />
                    <button id="searchBtn" type="submit" style="position:absolute; right:12px; top:50%; transform:translateY(-50%); background:none; border:none; outline:none; cursor:pointer; font-size:1.35rem; color:#1275E0; display:flex; align-items:center; justify-content:center; padding:0; width:28px; height:28px;">
                      <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="currentColor" viewBox="0 0 16 16"><path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z"/></svg>
                    </button>
                    <div id="autocompleteList" style="position:absolute; left:0; top:46px; width:100%; background:rgba(255,255,255,0.97); border-radius:14px; box-shadow:0 4px 16px rgba(0,0,0,0.10); z-index:30; display:none; flex-direction:column; overflow:hidden; border:1.5px solid #e0e0e0;"></div>
                  </div>
                </form>
            </div>
            <div id="categoryCountsBar" style="display:none;"></div>
            <div style="padding:24px 20px 20px 20px; flex:1; overflow-y:auto; display:flex; flex-direction:column; align-items:center; justify-content:center;">
              <div id="searchResultBox" style="width:100%; flex:1; min-height:0; height:100%; background:#f5f5f5; border-radius:12px; display:flex; flex-direction:column; align-items:center; justify-content:flex-start; color:#888; font-size:1.2rem; padding:0; overflow-y:auto;"></div>
            </div>
          </div>
          <!-- 카카오맵이 실제로 렌더링됨 -->
        </div>
        <div class="text-end mt-2">
          <a href="<%=root%>/map/full.jsp" class="text-info">지도 전체 보기 →</a>
        </div>
      </div>
    </div>
    
    <!-- 투표 섹션 -->
    <div class="col-md-3">
      <div class="card-box h-100" style="min-height:600px;">
        <jsp:include page="nowhot.jsp" />
      </div>
    </div>
  </div>
  
  <!-- 헌팅썰 인기글 섹션 - 지도 아래 별도 공간 -->
  <div class="row mt-5">
    <div class="col-12">
      <jsp:include page="hunting_popular.jsp" />
    </div>
  </div>
  </div>
</div>

<jsp:include page="todayHot.jsp" />

<script>
  // JSP 변수들을 JavaScript로 전달
  var hotplaces = [<% for (int i = 0; i < hotplaceList.size(); i++) { HotplaceDto dto = hotplaceList.get(i); 
    // 클럽인 경우 장르 정보 가져오기
    String genres = "";
    if (dto.getCategoryId() == 1) {
      List<ClubGenreDto> genreList = clubGenreDao.getGenresByPlaceId(dto.getId());
      if (genreList != null && !genreList.isEmpty()) {
        genres = genreList.stream()
          .map(genre -> genre.getGenreName())
          .reduce((a, b) -> a + ", " + b)
          .orElse("");
      }
    }
  %>{id:<%=dto.getId()%>, name:'<%=dto.getName()%>', categoryId:<%=dto.getCategoryId()%>, address:'<%=dto.getAddress()%>', lat:<%=dto.getLat()%>, lng:<%=dto.getLng()%>, regionId:<%=dto.getRegionId()%>, genres:'<%=genres%>'}<% if (i < hotplaceList.size() - 1) { %>,<% } %><% } %>];
  var rootPath = '<%=root%>';
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

  // URL 파라미터에서 lat, lng 가져오기
  var urlParams = new URLSearchParams(window.location.search);
  var targetLat = urlParams.get('lat');
  var targetLng = urlParams.get('lng');
  
  // URL 파라미터가 있으면 해당 위치로 이동
  if (targetLat && targetLng) {
    console.log('URL 파라미터 감지: lat=' + targetLat + ', lng=' + targetLng);
    var targetPosition = new kakao.maps.LatLng(parseFloat(targetLat), parseFloat(targetLng));
    map.setCenter(targetPosition);
    map.setLevel(5); // 줌 레벨 조정
  }

  // 마커/오버레이 배열
  var hotplaceMarkers = [], hotplaceLabels = [], hotplaceInfoWindows = [];
  var hotplaceCategoryIds = [];
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
    // 하트 아이콘(위시리스트) 추가: 오른쪽 위 (i 태그, .wish-heart)
    var heartHtml = isLoggedIn ? `<i class="bi bi-heart wish-heart" data-place-id="${place.id}" style="position:absolute;top:12px;right:12px;z-index:10;"></i>` : '';
    var infoContent = ''
      + '<div class="infoWindow" style="position:relative; padding:0; font-size:clamp(12px, 2vw, 16px); line-height:1.4; border-radius:12px; overflow:hidden; box-sizing:border-box;">'
      + '<div class="place-images-container" style="position:relative; width:100%; background:#f8f9fa; display:flex; align-items:center; justify-content:center; color:#6c757d; font-size:clamp(11px, 1.5vw, 13px);" data-place-id="' + place.id + '">이미지 로딩 중...</div>'
      + '<div style="padding:clamp(16px, 3vw, 20px);">'
      + '<div class="place-name-wish-container">'
      + '<strong style="font-size:clamp(14px, 2.5vw, 18px); word-break:break-word;">' + place.name + '</strong>'
      + '<span style="color:#e91e63; font-size:clamp(12px, 2vw, 14px); white-space:nowrap;">💖<span class="wish-count-' + place.id + '" style="color:#e91e63; font-weight:600;">로딩중...</span>명</span>'
      + '</div>'
      + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#888; font-size:clamp(10px, 1.8vw, 12px); word-break:break-word;" id="voteTrends-' + place.id + '">📊 역대 투표: 로딩중...</div>'
      + '<div style="margin-bottom:clamp(10px, 2vw, 14px); color:#666; font-size:clamp(11px, 2vw, 13px); word-break:break-word; line-height:1.3;">' + place.address + '</div>'
      + (place.genres && place.genres !== '' ? '<div style="color:#9c27b0; font-weight:600; margin-bottom:clamp(10px, 2vw, 14px); font-size:clamp(11px, 2vw, 13px); word-break:break-word;">🎵 장르: ' + place.genres + '</div>' : '')
      + '<div class="action-buttons-container"><a href="#" onclick="showVoteSection(' + place.id + ', \'' + place.name + '\', \'' + place.address + '\', ' + place.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-weight:500; font-size:clamp(12px, 2vw, 14px); white-space:nowrap; padding:10px 16px; background:#f0f8ff; border-radius:8px; border:1px solid #e3f2fd;">🔥 투표하기</a>'
      + (isAdmin && place.categoryId === 1 ? '<a href="#" onclick="openGenreEditModal(' + place.id + ', \'' + place.name + '\'); return false;" style="color:#ff6b35; text-decoration:none; font-size:clamp(10px, 1.8vw, 12px); white-space:nowrap; padding:8px 14px; background:#fff3e0; border-radius:6px; border:1px solid #ffe0b2;">✏️ 장르 편집</a>' : '') + '</div>'
      + '</div>'
      + '</div>';
    var infowindow = new kakao.maps.InfoWindow({ content: infoContent });
    kakao.maps.event.addListener(marker, 'click', function() {
      if (openInfoWindow) openInfoWindow.close();
      infowindow.open(map, marker);
      openInfoWindow = infowindow;
      // InfoWindow가 열린 후, 하트 태그와 이미지 로드
      setTimeout(function() {
        var iwEls = document.getElementsByClassName('infoWindow');
        if (iwEls.length > 0) {
          var iw = iwEls[0];
          // 기존 하트가 있으면 제거
          var oldHeart = iw.querySelector('.wish-heart');
          if (oldHeart) oldHeart.remove();
          // 하트 태그 동적으로 생성
          var heart = document.createElement('i');
          heart.className = 'bi bi-heart wish-heart';
          heart.setAttribute('data-place-id', place.id);
          heart.style.position = 'absolute';
          heart.style.top = '12px';
          heart.style.right = '12px';
          heart.style.zIndex = '10';
          iw.appendChild(heart);
          // 로그인 여부에 따라 클릭 이벤트 분기
          if (!isLoggedIn) {
            heart.onclick = function() {
              showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
            };
          } else {
            // 하트 상태 동기화 및 이벤트 연결
            setupWishHeartByClass(place.id);
          }
          
          // 하트 태그와 동일한 방식으로 이미지 컨테이너 찾기
          const imageContainer = iw.querySelector('.place-images-container');
          if (imageContainer) {
            // DOM이 완전히 준비될 때까지 대기
            setTimeout(function() {
              loadPlaceImages(place.id);
            }, 300);
          }
          
          // 위시리스트 개수 로드
          setTimeout(function() {
            loadWishCount(place.id);
          }, 400);
          
          // 투표 현황 로드
          setTimeout(function() {
            loadVoteTrends(place.id);
          }, 500);
          

          
          // 관리자용 버튼들 추가 (하트와 같은 위치에)
          if (isAdmin) {
            // + 버튼 (이미지 추가)
            var addBtn = document.createElement('button');
            addBtn.onclick = function() { openImageUploadModal(place.id); };
            addBtn.style.cssText = 'position:absolute; top:12px; right:50px; background:#1275E0; color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:18px; font-weight:bold; box-shadow:0 2px 8px rgba(0,0,0,0.3); z-index:10;';
            addBtn.innerHTML = '+';
            iw.appendChild(addBtn);
            
            // 수정 버튼 (이미지 관리)
            var editBtn = document.createElement('button');
            editBtn.onclick = function() { openImageManageModal(place.id); };
            editBtn.style.cssText = 'position:absolute; top:12px; right:88px; background:#ff6b35; color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:14px; font-weight:bold; box-shadow:0 2px 8px rgba(0,0,0,0.3); z-index:10;';
            editBtn.innerHTML = '✏️';
            iw.appendChild(editBtn);
          }
        }
      }, 100);
    });
    marker.categoryId = place.categoryId; // 마커에 카테고리 저장
    hotplaceMarkers.push(marker);
    hotplaceLabels.push(labelOverlay);
    hotplaceInfoWindows.push(infowindow);
    hotplaceCategoryIds.push(place.categoryId);
  });

  // === 카테고리 필터 버튼 클릭 이벤트 ===
  document.addEventListener('DOMContentLoaded', function() {
    var filterBtns = document.querySelectorAll('.category-filter-btn');
    filterBtns.forEach(function(btn) {
      btn.onclick = function() {
        // 버튼 active 스타일
        filterBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        var cat = btn.getAttribute('data-category');
        // 마커 show/hide
        hotplaceMarkers.forEach(function(marker, idx) {
          if (cat === 'all' || String(marker.categoryId) === cat) {
            marker.setMap(map);
            if (hotplaceLabels[idx]) hotplaceLabels[idx].setMap(map);
          } else {
            marker.setMap(null);
            if (hotplaceLabels[idx]) hotplaceLabels[idx].setMap(null);
          }
        });
        // 카테고리 버튼 클릭 시 해당 카테고리의 첫 번째 장소로 지도 이동
        // if (cat !== 'all') {
        //   var first = hotplaces.find(function(h) { return String(h.categoryId) === cat; });
        //   if (first) {
        //     var latlng = new kakao.maps.LatLng(first.lat, first.lng);
        //     map.setLevel(5);
        //     map.setCenter(latlng);
        //   }
        // }
      };
    });
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
      content: '<div class="region-label" style="cursor:pointer;" onclick="openRightPanelAndShowDongList(\'' + center.dong + '\')">' + center.dong + '</div>',
      position: new kakao.maps.LatLng(center.lat, center.lng),
      xAnchor: 0.5, yAnchor: 0.5, map: null
    });
    dongOverlays.push(overlay);
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
    /* 지도 위치 버튼 스타일 개선 */
    .map-location-btn {
      width: 110px !important;
      min-width: unset !important;
      padding: 4px 10px !important;
      font-size: 0.85rem !important;
      border-radius: 18px !important;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
      background: #fff;
      color: #1275E0;
      border: 1.5px solid #1275E0;
      transition: background 0.15s, color 0.15s;
      display: block !important;
      margin-left: 0 !important;
      float: left !important;
    }
    .map-location-btn:hover {
      background: #1275E0;
      color: #fff;
    }
    /* 카테고리 필터 버튼 스타일 (마커 스타일과 동일) */
    .category-filter-btn {
      border: none;
      outline: none;
      border-radius: 50px;
      padding: 4px 12px;
      font-size: 0.92rem;
      font-weight: bold;
      color: #fff;
      background: #bbb;
      cursor: pointer;
      transition: background 0.18s, color 0.18s, box-shadow 0.18s;
      box-shadow: 0 2px 8px rgba(0,0,0,0.10);
      opacity: 0.82;
      min-width: 32px;
      min-height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .category-filter-btn.active {
      border: 2.5px solid #222;
      opacity: 1;
      color: #222;
      background: #fff;
    }
    .category-filter-btn.marker-club { background: linear-gradient(135deg, #9c27b0, #ba68c8); color: #fff; }
    .category-filter-btn.marker-hunting { background: linear-gradient(135deg, #f44336, #ef5350); color: #fff; }
    .category-filter-btn.marker-lounge { background: linear-gradient(135deg, #4caf50, #66bb6a); color: #fff; }
    .category-filter-btn.marker-pocha { background: linear-gradient(135deg, #8d6e63, #a1887f); color: #fff; }
    .category-filter-btn:not(.active):hover {
      filter: brightness(1.08);
      opacity: 1;
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

  // 투표 섹션 표시 함수 (nowhot.jsp에서 처리)
  function showVoteSection(hotplaceId, name, address, categoryId) {
    // nowhot.jsp의 함수 호출
    if (typeof showVoteForm === 'function') {
      showVoteForm(hotplaceId, name, address, categoryId);
    }
  }

  // 하트 상태 동기화 및 클릭 이벤트 (class 기반)
  function setupWishHeartByClass(placeId, retryCount = 0) {
    var hearts = document.getElementsByClassName('wish-heart');
    var found = false;
    Array.from(hearts).forEach(function(heart) {
      if (heart.getAttribute('data-place-id') == placeId) {
        found = true;
        // 찜 여부 확인
        fetch(rootPath + '/main/wishAction.jsp?action=check&place_id=' + placeId)
          .then(res => res.json())
          .then(data => {
            if (data.result === true) {
              heart.classList.add('on');
              heart.classList.remove('bi-heart');
              heart.classList.add('bi-heart-fill');
            } else {
              heart.classList.remove('on');
              heart.classList.remove('bi-heart-fill');
              heart.classList.add('bi-heart');
            }
          });
        // 찜/찜 해제 이벤트
        heart.onclick = function() {
          var isWished = heart.classList.contains('on');
          var action = isWished ? 'remove' : 'add';
          fetch(rootPath + '/main/wishAction.jsp?action=' + action + '&place_id=' + placeId)
            .then(res => res.json())
            .then(data => {
              if (data.result === true) {
                if (isWished) {
                  heart.classList.remove('on');
                  heart.classList.remove('bi-heart-fill');
                  heart.classList.add('bi-heart');
                } else {
                  heart.classList.add('on');
                  heart.classList.remove('bi-heart');
                  heart.classList.add('bi-heart-fill');
                }
              }
            });
        };
      }
    });
    if (!found && retryCount < 5) {
      setTimeout(function() {
        setupWishHeartByClass(placeId, retryCount + 1);
      }, 100);
    }
  }

  // 오른쪽 패널 토글 기능 (버튼 위치 동적 변경)
  document.addEventListener('DOMContentLoaded', function() {
    var openBtn = document.getElementById('rightPanelToggleBtn');
    var closeBtn = document.getElementById('rightPanelCloseBtn');
    var panel = document.getElementById('rightPanel');
    // 초기 상태: 패널 닫힘, < 버튼만 지도 오른쪽 끝에 보임
    panel.style.transform = 'translateX(100%)';
    openBtn.style.display = 'flex';
    closeBtn.style.display = 'none';
    openBtn.innerHTML = '&lt;';
    openBtn.onclick = function() {
      panel.style.transform = 'translateX(0)';
      openBtn.style.display = 'none';
      closeBtn.style.display = 'flex';
    };
    closeBtn.onclick = function() {
      panel.style.transform = 'translateX(100%)';
      closeBtn.style.display = 'none';
      setTimeout(function() { openBtn.style.display = 'flex'; }, 350);
    };
    // 검색 타입 드롭다운 동작
    var searchTypeBtn = document.getElementById('searchTypeBtn');
    var searchTypeList = document.getElementById('searchTypeList');
    var searchTypeText = document.getElementById('searchTypeText');
    var searchTypeItems = searchTypeList.querySelectorAll('.search-type-item');
    var dropdownOpen = false;
    searchTypeBtn.onclick = function(e) {
      e.stopPropagation();
      dropdownOpen = !dropdownOpen;
      searchTypeList.classList.toggle('show', dropdownOpen);
      searchTypeBtn.classList.toggle('active', dropdownOpen);
    };
    searchTypeItems.forEach(function(item) {
      item.onclick = function(e) {
        e.stopPropagation();
        searchTypeItems.forEach(i => i.classList.remove('selected'));
        item.classList.add('selected');
        searchTypeText.textContent = item.getAttribute('data-type');
        dropdownOpen = false;
        searchTypeList.classList.remove('show');
        searchTypeBtn.classList.remove('active');
      };
    });
    document.addEventListener('click', function() {
      dropdownOpen = false;
      searchTypeList.classList.remove('show');
      searchTypeBtn.classList.remove('active');
    });
    // 자동완성(오토컴플릿) UI/로직
    var searchInput = document.getElementById('searchInput');
    var autocompleteList = document.getElementById('autocompleteList');
    var searchTypeText = document.getElementById('searchTypeText');
    function showAutocompleteList() {
      var keyword = searchInput.value.trim();
      if (!keyword) { autocompleteList.style.display = 'none'; return; }
      var type = searchTypeText.textContent;
      var list = (type === '지역') ? regionNameList : hotplaceNameList;
      var filtered = list.filter(function(item) {
        return item && item.toLowerCase().indexOf(keyword.toLowerCase()) !== -1;
      }).slice(0, 8); // 최대 8개
      if (filtered.length === 0) { autocompleteList.style.display = 'none'; return; }
      autocompleteList.innerHTML = filtered.map(function(item) {
        return '<div class="autocomplete-item" style="padding:10px 18px; font-size:1.04rem; color:#222 !important; cursor:pointer; transition:background 0.13s; border-bottom:1px solid #f3f3f3; background:transparent;">' + (item && item.length > 0 ? item : '(빈값)') + '</div>';
      }).join('');
      autocompleteList.style.display = 'flex';
      // 항목 클릭 시 입력창에 반영
      Array.from(autocompleteList.children).forEach(function(child) {
        child.onclick = function() {
          searchInput.value = child.textContent;
          autocompleteList.style.display = 'none';
        };
      });
    }
    searchInput.addEventListener('input', showAutocompleteList);
    searchInput.addEventListener('focus', showAutocompleteList);
    searchInput.addEventListener('blur', function() {
      setTimeout(function() { autocompleteList.style.display = 'none'; }, 120);
    });
    // 스타일: hover 효과
    var style = document.createElement('style');
    style.innerHTML = `.autocomplete-item:hover { background: #f0f4fa !important; color: #1275E0 !important; }`;
    document.head.appendChild(style);

    // 검색 결과 렌더링 함수
    var searchResultBox = document.getElementById('searchResultBox');
    function renderSearchResult() {
      var keyword = searchInput.value.trim();
      var type = searchTypeText.textContent;
      var list = (type === '지역') ? regionNameList : hotplaceNameList;
      var filtered = list.filter(function(item) {
        return item && item.toLowerCase().indexOf(keyword.toLowerCase()) !== -1;
      });
      
      // 디버깅: 지역명 매핑 확인
      if (type === '지역') {
        console.log('검색 키워드:', keyword);
        console.log('dongToRegionId 매핑:', dongToRegionId);
        console.log('regionNameList:', regionNameList);
        console.log('필터링된 결과:', filtered);
      }
      
      // === 카테고리 바 표시/숨김 ===
      var catBar = document.getElementById('categoryCountsBar');
      if (type === '가게') {
        catBar.style.display = 'none';
      }
      if (!keyword) {
        searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">검색어를 입력해 주세요.</div>';
        return;
      }
      if (filtered.length === 0) {
        searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">검색 결과가 없습니다.</div>';
        return;
      }
      if (type === '지역') {
        // 지역명 리스트를 네이버 스타일로, 클릭 시 해당 지역의 핫플 리스트 출력
        searchResultBox.innerHTML = filtered.map(function(dong, idx) {
          var regionId = dongToRegionId[dong];
          console.log('지역명:', dong, '매핑된 ID:', regionId);
          var count = regionCategoryCounts.find(function(c) { return String(c.region_id) === String(regionId); });
          var countHtml = '';
          if (count) {
            countHtml = '<span style="margin-left:10px; font-size:0.98rem; color:#888; display:inline-flex; gap:7px; align-items:center;">'
              + '<span style="color:#9c27b0; font-weight:600;">C:' + (typeof count.clubCount === 'number' ? count.clubCount : 0) + '</span>'
              + '<span style="color:#f44336; font-weight:600; margin-left:4px;">H:' + (typeof count.huntingCount === 'number' ? count.huntingCount : 0) + '</span>'
              + '<span style="color:#4caf50; font-weight:600; margin-left:4px;">L:' + (typeof count.loungeCount === 'number' ? count.loungeCount : 0) + '</span>'
              + '<span style="color:#8d6e63; font-weight:600; margin-left:4px;">P:' + (typeof count.pochaCount === 'number' ? count.pochaCount : 0) + '</span>'
              + '</span>';
          }
          var rating = regionRatings[dong] || 0.0;
          var starIcon = '<i class="bi bi-star-fill" style="color:#f9cb3e; font-size:0.9rem; margin:0 2px;"></i>';
          return '<div class="region-search-item" style="width:92%; margin:'
            + (idx === 0 ? '14px' : '0') + ' auto 10px auto; background:#fff; border-radius:8px; box-shadow:0 2px 8px rgba(0,0,0,0.04); padding:16px 18px; color:#222; font-size:1.08rem; display:flex; align-items:center; cursor:pointer; transition:background 0.13s;">'
            + '<span class="region-name" style="color:#1275E0; font-weight:600; font-size:1.13rem; cursor:pointer; display:flex; align-items:center; white-space:nowrap;">' + dong + ' (' + starIcon + ' ' + rating.toFixed(1) + ')</span>'
            + countHtml
            + '</div>';
        }).join('');
        // 지역명 클릭 이벤트 바인딩
        Array.from(document.getElementsByClassName('region-search-item')).forEach(function(item) {
          var dong = item.querySelector('.region-name').textContent;
          // 평점 부분 제거 (예: "홍대입구 (★ 5.0)" -> "홍대입구")
          dong = dong.replace(/\s*\([^)]*\)\s*$/, '');
          item.onclick = function() {
            renderHotplaceListByDong(dong);
          };
        });
      } else {
        // 가게명 리스트를 카드 형태로 출력 (동 리스트와 동일)
        var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
        var matchedHotplaces = window.hotplaces.filter(function(h) {
          return filtered.includes(h.name);
        });
        searchResultBox.innerHTML = matchedHotplaces.map(function(h) {
          var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="'+h.id+'" style="font-size:1.25rem; color:#e74c3c; cursor:pointer;"></i>' : '<i class="bi bi-heart wish-heart" style="font-size:1.25rem; color:#bbb; cursor:pointer;"></i>';
          var voteButtonHtml = '<a href="#" onclick="showVoteSection(' + h.id + ', \'' + h.name + '\', \'' + h.address + '\', ' + h.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-size:0.95rem;">🔥 투표</a>';
          var genreHtml = (h.genres && h.genres !== '') ? '<div style="color:#9c27b0; font-weight:600; margin-top:2px; font-size:0.9rem;">🎵 장르: ' + h.genres + '</div>' : '';
          return '<div class="hotplace-list-card">'
            + '<div style="flex:1; min-width:0;">'
            +   '<div style="display:flex; align-items:center; gap:6px;">'
            +     '<span class="hotplace-name" style="color:#1275E0; font-weight:600; cursor:pointer;">' + h.name + '</span>'
            +     '<span class="hotplace-category" style="color:#888; margin-left:4px;">' + (categoryMap[h.categoryId]||'') + '</span>'
            +   '</div>'
            +   '<div class="hotplace-address" style="color:#666; margin-top:2px;">' + h.address + '</div>'
            + genreHtml
            + '</div>'
            + '<div class="hotplace-card-heart">' + heartHtml + '</div>'
            + '<div class="hotplace-card-actions">' + voteButtonHtml + '</div>'
            + '</div>';
        }).join('');
        setTimeout(function() {
          Array.from(document.getElementsByClassName('hotplace-list-card')).forEach(function(card) {
            var heart = card.querySelector('.wish-heart');
            var placeName = card.querySelector('.hotplace-name').textContent;
            var place = matchedHotplaces.find(function(h) { return h.name === placeName; });
            if (!heart || !place) return;
            if (!isLoggedIn) {
              heart.onclick = function() {
                showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
              };
            } else {
              heart.setAttribute('data-place-id', place.id);
              setupWishHeartByClass(place.id);
            }
            // 가게명/카테고리 클릭 시 지도 이동
            function moveToHotplace(e) {
              e.stopPropagation();
              var latlng = new kakao.maps.LatLng(place.lat, place.lng);
              map.setLevel(5);
              map.setCenter(latlng);
            }
            var placeNameEl = card.querySelector('.hotplace-name');
            var placeCategoryEl = card.querySelector('.hotplace-category');
            placeNameEl.style.cursor = 'pointer';
            placeCategoryEl.style.cursor = 'pointer';
            placeNameEl.onclick = moveToHotplace;
            placeCategoryEl.onclick = moveToHotplace;
          });
        }, 100);
      }
    }

    // 전역에 선언: 동(지역)별 핫플 리스트 네이버 스타일로 출력
    window.renderHotplaceListByDong = function(dong, categoryId) {
      window.selectedDong = dong;
      window.selectedCategory = categoryId || null;
      var regionId = window.dongToRegionId[dong];
      
      var catBar = document.getElementById('categoryCountsBar');
      if (!regionId) {
        catBar.style.display = 'none';
        window.searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
        return;
      }
      var filtered = window.hotplaces.filter(function(h) {
        if (h.regionId !== regionId) return false;
        if (categoryId && String(h.categoryId) !== String(categoryId)) return false;
        return true;
      });
      // 카테고리별 개수는 항상 표시 (0이어도)
      var count = (window.regionCategoryCounts || []).find(function(c) { return String(c.region_id) === String(regionId); }) || {};
      var clubCount = (typeof count.clubCount === 'number') ? count.clubCount : 0;
      var huntingCount = (typeof count.huntingCount === 'number') ? count.huntingCount : 0;
      var loungeCount = (typeof count.loungeCount === 'number') ? count.loungeCount : 0;
      var pochaCount = (typeof count.pochaCount === 'number') ? count.pochaCount : 0;
      var catHtml = '<div class="dong-category-counts-bar">'
        + '<span class="category-ball marker-club' + (categoryId==1?' active':'') + '" data-category="1">C</span> <span class="cat-count-num" style="color:#9c27b0;">' + clubCount + '</span>'
        + '<span class="category-ball marker-hunting' + (categoryId==2?' active':'') + '" data-category="2">H</span> <span class="cat-count-num" style="color:#f44336;">' + huntingCount + '</span>'
        + '<span class="category-ball marker-lounge' + (categoryId==3?' active':'') + '" data-category="3">L</span> <span class="cat-count-num" style="color:#4caf50;">' + loungeCount + '</span>'
        + '<span class="category-ball marker-pocha' + (categoryId==4?' active':'') + '" data-category="4">P</span> <span class="cat-count-num" style="color:#8d6e63;">' + pochaCount + '</span>'
        + '</div>';
      catBar.innerHTML = catHtml;
      catBar.style.display = 'flex';
      // 카테고리 원 클릭 이벤트 바인딩
      Array.from(catBar.getElementsByClassName('category-ball')).forEach(function(ball) {
        ball.onclick = function() {
          var cat = ball.getAttribute('data-category');
          if (window.selectedCategory && String(window.selectedCategory) === String(cat)) {
            window.renderHotplaceListByDong(dong, null); // 전체
          } else {
            window.renderHotplaceListByDong(dong, cat);
          }
        };
      });
      
      var rating = regionRatings[dong] || 0.0;
      var starIcon = '<i class="bi bi-star-fill" style="color:#f9cb3e; font-size:0.9rem; margin:0 2px;"></i>';
      var dongTitle = '<div style="font-size:1.13rem; font-weight:600; color:#1275E0; margin:14px 0 8px 0; display:flex; align-items:center;">지역: ' + dong + ' (' + starIcon + ' ' + rating.toFixed(1) + ')</div>';
      if (filtered.length === 0) {
        window.searchResultBox.innerHTML = dongTitle + '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
        return;
      }
      // 카테고리별 개수
      var count = (window.regionCategoryCounts || []).find(function(c) { return String(c.region_id) === String(regionId); }) || {};
      var clubCount = (typeof count.clubCount === 'number') ? count.clubCount : 0;
      var huntingCount = (typeof count.huntingCount === 'number') ? count.huntingCount : 0;
      var loungeCount = (typeof count.loungeCount === 'number') ? count.loungeCount : 0;
      var pochaCount = (typeof count.pochaCount === 'number') ? count.pochaCount : 0;
      var catHtml = '<div class="dong-category-counts-bar">'
        + '<span class="category-ball marker-club' + (categoryId==1?' active':'') + '" data-category="1">C</span> <span class="cat-count-num" style="color:#9c27b0;">' + clubCount + '</span>'
        + '<span class="category-ball marker-hunting' + (categoryId==2?' active':'') + '" data-category="2">H</span> <span class="cat-count-num" style="color:#f44336;">' + huntingCount + '</span>'
        + '<span class="category-ball marker-lounge' + (categoryId==3?' active':'') + '" data-category="3">L</span> <span class="cat-count-num" style="color:#4caf50;">' + loungeCount + '</span>'
        + '<span class="category-ball marker-pocha' + (categoryId==4?' active':'') + '" data-category="4">P</span> <span class="cat-count-num" style="color:#8d6e63;">' + pochaCount + '</span>'
        + '</div>';
      catBar.innerHTML = catHtml;
      catBar.style.display = 'flex';
      // 카테고리 원 클릭 이벤트 바인딩
      Array.from(catBar.getElementsByClassName('category-ball')).forEach(function(ball) {
        ball.onclick = function() {
          var cat = ball.getAttribute('data-category');
          if (window.selectedCategory && String(window.selectedCategory) === String(cat)) {
            window.renderHotplaceListByDong(dong, null); // 전체
          } else {
            window.renderHotplaceListByDong(dong, cat);
          }
        };
      });
      var rating = regionRatings[dong] || 0.0;
      var starIcon = '<i class="bi bi-star-fill" style="color:#f9cb3e; font-size:0.9rem; margin:0 2px;"></i>';
      var dongTitle = '<div style="font-size:1.13rem; font-weight:600; color:#1275E0; margin:14px 0 8px 0; display:flex; align-items:center;">지역: ' + dong + ' (' + starIcon + ' ' + rating.toFixed(1) + ')</div>';
      var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
      window.searchResultBox.innerHTML = dongTitle + filtered.map(function(h) {
        var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="'+h.id+'" style="font-size:1.25rem; color:#e74c3c; cursor:pointer;"></i>' : '<i class="bi bi-heart wish-heart" style="font-size:1.25rem; color:#bbb; cursor:pointer;"></i>';
        var voteButtonHtml = '<a href="#" onclick="showVoteSection(' + h.id + ', \'' + h.name + '\', \'' + h.address + '\', ' + h.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-size:0.95rem;">🔥 투표</a>';
        var genreHtml = (h.genres && h.genres !== '') ? '<div style="color:#9c27b0; font-weight:600; margin-top:2px; font-size:0.9rem;">장르: ' + h.genres + '</div>' : '';
        return '<div class="hotplace-list-card">'
          + '<div style="flex:1; min-width:0;">'
          +   '<div style="display:flex; align-items:center; gap:6px;">'
          +     '<span class="hotplace-name" style="color:#1275E0; font-weight:600; cursor:pointer;">' + h.name + '</span>'
          +     '<span class="hotplace-category" style="color:#888; margin-left:4px;">' + (categoryMap[h.categoryId]||'') + '</span>'
          +   '</div>'
          +   '<div class="hotplace-address" style="color:#666; margin-top:2px;">' + h.address + '</div>'
          + genreHtml
          + '</div>'
          + '<div class="hotplace-card-heart">' + heartHtml + '</div>'
          + '<div class="hotplace-card-actions">' + voteButtonHtml + '</div>'
          + '</div>';
      }).join('');
      setTimeout(function() {
        Array.from(document.getElementsByClassName('hotplace-list-card')).forEach(function(card) {
          var heart = card.querySelector('.wish-heart');
          var placeName = card.querySelector('.hotplace-name').textContent;
          var place = filtered.find(function(h) { return h.name === placeName; });
          if (!heart || !place) return;
          if (!isLoggedIn) {
            heart.onclick = function() {
              showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
            };
          } else {
            heart.setAttribute('data-place-id', place.id);
            setupWishHeartByClass(place.id);
          }
          // 가게명/카테고리 클릭 시 지도 이동
          function moveToHotplace(e) {
            e.stopPropagation();
            var latlng = new kakao.maps.LatLng(place.lat, place.lng);
            map.setLevel(5);
            map.setCenter(latlng);
          }
          var placeNameEl = card.querySelector('.hotplace-name');
          var placeCategoryEl = card.querySelector('.hotplace-category');
          placeNameEl.style.cursor = 'pointer';
          placeCategoryEl.style.cursor = 'pointer';
          placeNameEl.onclick = moveToHotplace;
          placeCategoryEl.onclick = moveToHotplace;
        });
      }, 100);
    }
    // 검색 버튼/엔터 이벤트
    var searchForm = searchInput.closest('form');
    searchForm.onsubmit = function(e) {
      e.preventDefault();
      renderSearchResult();
    };
    document.getElementById('searchBtn').onclick = function(e) {
      e.preventDefault();
      renderSearchResult();
    };
  });

  window.selectedDong = null;
  window.selectedCategory = null;

  // 상단(지역명+카테고리 바) 렌더링
  window.renderDongHeader = function(dong, categoryId) {
    window.selectedDong = dong;
    window.selectedCategory = categoryId || null;
    var regionId = window.dongToRegionId[dong];
    var catBar = document.getElementById('categoryCountsBar');
    if (!regionId) {
      catBar.style.display = 'none';
      return;
    }
    // 카테고리별 개수
    var count = (window.regionCategoryCounts || []).find(function(c) { return String(c.region_id) === String(regionId); }) || {};
    var clubCount = (typeof count.clubCount === 'number') ? count.clubCount : 0;
    var huntingCount = (typeof count.huntingCount === 'number') ? count.huntingCount : 0;
    var loungeCount = (typeof count.loungeCount === 'number') ? count.loungeCount : 0;
    var pochaCount = (typeof count.pochaCount === 'number') ? count.pochaCount : 0;
    var catHtml = '<div class="dong-category-counts-bar">'
      + '<span class="category-ball marker-club' + (categoryId==1?' active':'') + '" data-category="1">C</span> <span class="cat-count-num" style="color:#9c27b0;">' + clubCount + '</span>'
      + '<span class="category-ball marker-hunting' + (categoryId==2?' active':'') + '" data-category="2">H</span> <span class="cat-count-num" style="color:#f44336;">' + huntingCount + '</span>'
      + '<span class="category-ball marker-lounge' + (categoryId==3?' active':'') + '" data-category="3">L</span> <span class="cat-count-num" style="color:#4caf50;">' + loungeCount + '</span>'
      + '<span class="category-ball marker-pocha' + (categoryId==4?' active':'') + '" data-category="4">P</span> <span class="cat-count-num" style="color:#8d6e63;">' + pochaCount + '</span>'
      + '</div>';
    catBar.innerHTML = catHtml;
    catBar.style.display = 'flex';
    // 카테고리 원 클릭 이벤트 바인딩
    Array.from(catBar.getElementsByClassName('category-ball')).forEach(function(ball) {
      ball.onclick = function() {
        var cat = ball.getAttribute('data-category');
        if (window.selectedCategory && String(window.selectedCategory) === String(cat)) {
          window.selectedCategory = null;
          window.renderDongHeader(dong, null);
          window.renderHotplaceList(dong, null);
        } else {
          window.selectedCategory = cat;
          window.renderDongHeader(dong, cat);
          window.renderHotplaceList(dong, cat);
        }
      };
    });
    // 지역명은 리스트에서만 렌더링
  };

  // 리스트만 렌더링
  window.renderHotplaceList = function(dong, categoryId) {
    console.log('renderHotplaceList 호출 - 지역명:', dong, '카테고리:', categoryId);
    var regionId = window.dongToRegionId[dong];
    console.log('매핑된 regionId:', regionId);
    if (!regionId) {
      console.log('regionId가 없음 - 해당 지역의 핫플레이스가 없습니다.');
      window.searchResultBox.innerHTML = '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
      return;
    }
    var filtered = window.hotplaces.filter(function(h) {
      if (h.regionId !== regionId) return false;
      if (categoryId && String(h.categoryId) !== String(categoryId)) return false;
      return true;
    });
    var rating = regionRatings[dong] || 0.0;
    var starIcon = '<i class="bi bi-star-fill" style="color:#f9cb3e; font-size:0.9rem; margin:0 2px;"></i>';
    var dongTitle = '<div style="font-size:1.13rem; font-weight:600; color:#1275E0; margin:14px 0 8px 0; display:flex; align-items:center;">지역: ' + dong + ' (' + starIcon + ' ' + rating.toFixed(1) + ')</div>';
    if (filtered.length === 0) {
      window.searchResultBox.innerHTML = dongTitle + '<div style="color:#bbb; text-align:center; padding:40px 0;">해당 지역의 핫플레이스가 없습니다.</div>';
      return;
    }
    var categoryMap = {1:'클럽',2:'헌팅',3:'라운지',4:'포차'};
    window.searchResultBox.innerHTML = dongTitle + filtered.map(function(h) {
      var heartHtml = isLoggedIn ? '<i class="bi bi-heart wish-heart" data-place-id="'+h.id+'" style="font-size:1.25rem; color:#e74c3c; cursor:pointer;"></i>' : '<i class="bi bi-heart wish-heart" style="font-size:1.25rem; color:#bbb; cursor:pointer;"></i>';
      var voteButtonHtml = '<a href="#" onclick="showVoteSection(' + h.id + ', \'' + h.name + '\', \'' + h.address + '\', ' + h.categoryId + '); return false;" style="color:#1275E0; text-decoration:none; font-size:0.95rem;">🔥 투표</a>';
      var genreHtml = (h.genres && h.genres !== '') ? '<div style="color:#9c27b0; font-weight:600; margin-top:2px; font-size:0.9rem;">장르: ' + h.genres + '</div>' : '';
      return '<div class="hotplace-list-card">'
        + '<div style="flex:1; min-width:0;">'
        +   '<div style="display:flex; align-items:center; gap:6px;">'
        +     '<span class="hotplace-name" style="color:#1275E0; font-weight:600; cursor:pointer;">' + h.name + '</span>'
        +     '<span class="hotplace-category" style="color:#888; margin-left:4px;">' + (categoryMap[h.categoryId]||'') + '</span>'
        +   '</div>'
        +   '<div class="hotplace-address" style="color:#666; margin-top:2px;">' + h.address + '</div>'
        + genreHtml
        + '</div>'
        + '<div class="hotplace-card-actions">'
        + heartHtml
        + voteButtonHtml
        + '</div>'
        + '</div>';
    }).join('');
    setTimeout(function() {
      Array.from(document.getElementsByClassName('hotplace-list-card')).forEach(function(card) {
        var heart = card.querySelector('.wish-heart');
        var placeName = card.querySelector('.hotplace-name').textContent;
        var place = filtered.find(function(h) { return h.name === placeName; });
        if (!heart || !place) return;
        if (!isLoggedIn) {
          heart.onclick = function() {
            showToast('위시리스트는 로그인 후 사용할 수 있어요. 간편하게 로그인하고 저장해보세요!', 'error');
          };
        } else {
          heart.setAttribute('data-place-id', place.id);
          setupWishHeartByClass(place.id);
        }
      });
    }, 100);
  };

  // 기존 함수는 dong 바뀔 때만 둘 다 호출
  window.renderHotplaceListByDong = function(dong, categoryId) {
    window.renderDongHeader(dong, categoryId);
    window.renderHotplaceList(dong, categoryId);
  };

  // 오른쪽 패널 열고 해당 동 리스트 보여주는 함수
  window.openRightPanelAndShowDongList = function(dong) {
    var panel = document.getElementById('rightPanel');
    var openBtn = document.getElementById('rightPanelToggleBtn');
    var closeBtn = document.getElementById('rightPanelCloseBtn');
    panel.style.transform = 'translateX(0)';
    if (openBtn) openBtn.style.display = 'none';
    if (closeBtn) closeBtn.style.display = 'flex';
    window.renderHotplaceListByDong(dong, null);
  }

  /* 추가 스타일 */
  var panelStyle = document.createElement('style');
  panelStyle.innerHTML = `
    #rightPanel::-webkit-scrollbar { width: 8px; background: #f5f5f5; }
    #rightPanel::-webkit-scrollbar-thumb { background: #ddd; border-radius: 4px; }
    #searchBar input:focus { border:1.5px solid #1275E0; background:#fff; }
    #searchBar input::placeholder { color:#bbb; font-weight:400; }
    #searchBar { box-shadow:0 2px 8px rgba(0,0,0,0.04); border-radius:16px 16px 0 0; }
  `;
  document.head.appendChild(panelStyle);
</script>

<style>
  #rightPanel { display: flex; flex-direction: column; height: 100%; }
  #searchBar { flex-shrink: 0; z-index: 10 !important; }
  #autocompleteList { z-index: 30 !important; }
  #searchResultBox { flex: 1; min-height:0; height:100%; }
  .hotplace-list-card {
    width: 94%;
    margin: 18px auto 0 auto;
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    padding: 14px 14px 10px 14px;
    display: flex;
    align-items: flex-start;
    position: relative;
    gap: 10px;
  }
  .hotplace-card-heart {
    position: absolute;
    right: 14px;
    top: 12px;
    z-index: 2;
  }
  .hotplace-card-actions {
    position: absolute;
    right: 14px;
    bottom: 10px;
    display: flex;
    align-items: center;
    gap: 8px;
    z-index: 2;
  }
  .hotplace-list-card .hotplace-name {
    font-size: 1.08rem;
  }
  .hotplace-list-card .hotplace-category {
    font-size: 0.97rem;
  }
  .hotplace-list-card .hotplace-address {
    font-size: 0.98rem;
  }
  .category-ball {
    display:inline-flex;
    align-items:center;
    justify-content:center;
    width:24px;
    height:24px;
    border-radius:50%;
    font-size:1.02rem;
    font-weight:700;
    color:#fff;
    margin-right:4px;
    box-shadow:0 1px 4px rgba(0,0,0,0.08);
    border:2px solid #fff;
  }
  .category-ball.marker-club { background:linear-gradient(135deg,#9c27b0,#ba68c8); }
  .category-ball.marker-hunting { background:linear-gradient(135deg,#f44336,#ef5350); }
  .category-ball.marker-lounge { background:linear-gradient(135deg,#4caf50,#66bb6a); }
  .category-ball.marker-pocha { background:linear-gradient(135deg,#8d6e63,#a1887f); }
  .category-ball.active {
    border: 2.5px solid #1275E0;
    box-shadow: 0 0 0 3px #e3f0ff;
    filter: brightness(1.08);
  }
  #categoryCountsBar {
    position: sticky;
    top: 72px;
    z-index: 1 !important;
    background: #fff;
    padding: 12px 20px 4px 20px;
    min-height: 36px;
    display: flex;
    align-items: center;
    gap: 18px;
    border-radius: 0 0 16px 16px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  }
  .dong-category-counts-bar {
    display: flex;
    gap: 18px;
    align-items: center;
    width: 100%;
  }
  .cat-count-num {
    font-weight: 600;
    font-size: 1.08rem;
    margin-right: 8px;
  }
  
  /* 장르 편집 모달 스타일 */
  .genre-edit-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 1000;
    align-items: center;
    justify-content: center;
  }
  
  .genre-edit-content {
    background: white;
    border-radius: 16px;
    padding: 24px;
    width: 90%;
    max-width: 500px;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 8px 32px rgba(0,0,0,0.2);
  }
  
  .genre-edit-title {
    font-size: 1.3rem;
    font-weight: 600;
    margin-bottom: 20px;
    color: #333;
  }
  
  .genre-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 20px;
  }
  
  .genre-item {
    padding: 8px 16px;
    border: 2px solid #e0e0e0;
    border-radius: 20px;
    background: white;
    cursor: pointer;
    transition: all 0.2s;
    font-size: 0.9rem;
  }
  
  .genre-item:hover {
    border-color: #1275E0;
    background: #f0f4fa;
  }
  
  .genre-item.selected {
    border-color: #1275E0;
    background: #1275E0;
    color: white;
  }
  
  .genre-edit-buttons {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    margin-top: 20px;
  }
  
  .genre-edit-btn {
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.2s;
  }
  
  .genre-edit-btn.cancel {
    background: #f5f5f5;
    color: #666;
  }
  
  .genre-edit-btn.cancel:hover {
    background: #e0e0e0;
  }
  
  .genre-edit-btn.save {
    background: #1275E0;
    color: white;
  }
  
  .genre-edit-btn.save:hover {
    background: #0d5bb8;
  }
</style>

<!-- 장르 편집 모달 -->
<div id="genreEditModal" class="genre-edit-modal">
  <div class="genre-edit-content">
    <div class="genre-edit-title">장르 편집</div>
    <div id="genreEditPlaceName" style="margin-bottom: 16px; color: #666; font-size: 0.95rem;"></div>
    <div class="genre-list" id="genreList">
      <!-- 장르 목록이 여기에 동적으로 추가됩니다 -->
    </div>
    <div class="genre-edit-buttons">
      <button class="genre-edit-btn cancel" onclick="closeGenreEditModal()">취소</button>
      <button class="genre-edit-btn save" onclick="saveGenreChanges()">저장</button>
    </div>
  </div>
</div>

<script>
// 장르 편집 관련 변수
var currentEditingPlaceId = null;
var currentEditingPlaceName = null;
var genreChanges = {
  added: [],
  removed: []
};

// 장르 편집 모달 열기
function openGenreEditModal(placeId, placeName) {
  currentEditingPlaceId = placeId;
  currentEditingPlaceName = placeName;
  document.getElementById('genreEditPlaceName').textContent = placeName;
  
  // 장르 목록 가져오기
  fetch('<%=root%>/main/genreEditAction.jsp', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'action=getGenres&placeId=' + placeId
  })
  .then(response => response.json())
  .then(data => {
    if(data.success) {
      renderGenreList(data.genres);
      document.getElementById('genreEditModal').style.display = 'flex';
    } else {
      showToast('장르 목록을 불러오는데 실패했습니다.', 'error');
    }
  })
  .catch(error => {
    console.error('Error:', error);
    showToast('장르 목록을 불러오는데 실패했습니다.', 'error');
  });
}

// 장르 목록 렌더링
function renderGenreList(genres) {
  const genreList = document.getElementById('genreList');
  genreList.innerHTML = '';
  
  genres.forEach(genre => {
    const genreItem = document.createElement('div');
    genreItem.className = 'genre-item' + (genre.isSelected ? ' selected' : '');
    genreItem.textContent = genre.genreName;
    genreItem.onclick = function() {
      toggleGenreSelection(genre.genreId, genre.genreName, this);
    };
    genreList.appendChild(genreItem);
  });
}

// 장르 선택 토글
function toggleGenreSelection(genreId, genreName, element) {
  const isSelected = element.classList.contains('selected');
  
  if(isSelected) {
    // 선택 해제
    element.classList.remove('selected');
    genreChanges.removed.push(genreId);
    // 추가 목록에서 제거
    const addIndex = genreChanges.added.indexOf(genreId);
    if(addIndex > -1) {
      genreChanges.added.splice(addIndex, 1);
    }
  } else {
    // 선택
    element.classList.add('selected');
    genreChanges.added.push(genreId);
    // 제거 목록에서 제거
    const removeIndex = genreChanges.removed.indexOf(genreId);
    if(removeIndex > -1) {
      genreChanges.removed.splice(removeIndex, 1);
    }
  }
}

// 장르 편집 모달 닫기
function closeGenreEditModal() {
  document.getElementById('genreEditModal').style.display = 'none';
  currentEditingPlaceId = null;
  currentEditingPlaceName = null;
  genreChanges = { added: [], removed: [] };
}

// 장르 변경사항 저장
function saveGenreChanges() {
  if(genreChanges.added.length === 0 && genreChanges.removed.length === 0) {
    closeGenreEditModal();
    return;
  }
  
  // 추가할 장르들
  const addPromises = genreChanges.added.map(genreId => 
    fetch('<%=root%>/main/genreEditAction.jsp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'action=add&placeId=' + currentEditingPlaceId + '&genreId=' + genreId
    }).then(response => response.json())
  );
  
  // 제거할 장르들
  const removePromises = genreChanges.removed.map(genreId => 
    fetch('<%=root%>/main/genreEditAction.jsp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'action=remove&placeId=' + currentEditingPlaceId + '&genreId=' + genreId
    }).then(response => response.json())
  );
  
  Promise.all([...addPromises, ...removePromises])
    .then(results => {
      const success = results.every(result => result.success);
      if(success) {
        showToast('장르가 성공적으로 업데이트되었습니다.', 'success');
        
        // 마지막 결과에서 업데이트된 장르 목록 가져오기
        const lastResult = results[results.length - 1];
        if(lastResult.genres !== undefined) {
          // 지도에서 해당 장소의 장르 정보 업데이트
          updatePlaceGenresOnMap(currentEditingPlaceId, lastResult.genres);
        }
        
        closeGenreEditModal();
      } else {
        showToast('장르 업데이트 중 오류가 발생했습니다.', 'error');
      }
    })
    .catch(error => {
      console.error('Error:', error);
      showToast('장르 업데이트 중 오류가 발생했습니다.', 'error');
    });
}

// 지도에서 장소의 장르 정보 업데이트
function updatePlaceGenresOnMap(placeId, newGenres) {
  // hotplaces 배열에서 해당 장소 찾기
  const place = hotplaces.find(p => p.id === placeId);
  if(place) {
    place.genres = newGenres;
  }
  
  // InfoWindow가 열려있다면 업데이트
  if(openInfoWindow) {
    // InfoWindow 내용 업데이트 (간단한 방법으로 새로고침)
    openInfoWindow.close();
  }
}

// 모달 외부 클릭 시 닫기
document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('genreEditModal').addEventListener('click', function(e) {
    if(e.target === this) {
      closeGenreEditModal();
    }
  });
});

// showToast 함수 정의
function showToast(message, type) {
  // 기존 토스트 제거
  const existingToast = document.querySelector('.toast-message');
  if (existingToast) {
    existingToast.remove();
  }
  
  // 새 토스트 생성
  const toast = document.createElement('div');
  toast.className = 'toast-message';
  toast.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 12px 20px;
    border-radius: 8px;
    color: white;
    font-weight: 500;
    z-index: 10000;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    transform: translateX(100%);
    transition: transform 0.3s ease;
  `;
  
  // 타입에 따른 스타일 설정
  if (type === 'success') {
    toast.style.backgroundColor = '#4caf50';
  } else if (type === 'error') {
    toast.style.backgroundColor = '#f44336';
  } else {
    toast.style.backgroundColor = '#2196f3';
  }
  
  toast.textContent = message;
  document.body.appendChild(toast);
  
  // 애니메이션
  setTimeout(() => {
    toast.style.transform = 'translateX(0)';
  }, 100);
  
  // 자동 제거
  setTimeout(() => {
    toast.style.transform = 'translateX(100%)';
    setTimeout(() => {
      if (toast.parentNode) {
        toast.remove();
      }
    }, 300);
  }, 3000);
}

// ================================
// 이미지 관련 함수들
// ================================

// InfoWindow가 열린 후 이미지 로드
function loadPlaceImages(placeId, retryCount = 0) {
  // InfoWindow 내부에서 이미지 컨테이너 찾기
  const infoWindows = document.querySelectorAll('.infoWindow');
  let container = null;
  
  for (let iw of infoWindows) {
    const foundContainer = iw.querySelector('.place-images-container');
    if (foundContainer && foundContainer.getAttribute('data-place-id') == placeId) {
      container = foundContainer;
      break;
    }
  }
  
  if (!container) {
    // 재시도 로직 (최대 3번)
    if (retryCount < 3) {
      setTimeout(() => {
        loadPlaceImages(placeId, retryCount + 1);
      }, 200);
      return;
    }
    return;
  }
  
  // AJAX로 이미지 데이터 가져오기
  const requestUrl = '<%=root%>/main/getPlaceImages.jsp?placeId=' + placeId;
  fetch(requestUrl)
    .then(response => {
      return response.json();
    })
    .then(data => {
      if (data.success && data.images && data.images.length > 0) {
        // 이미지가 있는 경우 - 대표 이미지 + 좌우 화살표 + + 버튼
        
        const currentImageIndex = 0; // 현재 표시할 이미지 인덱스
        const currentImage = data.images[currentImageIndex];
        const timestamp = Date.now();
        
        let imageHtml = '<div class="place-image-slider" style="position:relative; width:100%; height:100%;">' +
          '<!-- 대표 이미지 -->' +
          '<img src="http://localhost:8083' + root + currentImage.imagePath + '?t=' + timestamp + '" alt="장소 이미지" ' +
               'style="width:100%; height:100%; object-fit:cover; cursor:pointer;" ' +
               'onclick="openImageModal(\'http://localhost:8083' + root + currentImage.imagePath + '\', ' + placeId + ', 0)">' +
          
          '<!-- 좌우 화살표 (이미지가 2개 이상일 때만 표시) -->' +
          (data.images.length > 1 ? 
            '<button class="image-nav-btn prev-btn" onclick="changeImage(' + placeId + ', ' + data.images.length + ', ' + currentImageIndex + ', -1)" ' +
                    'style="position:absolute; left:10px; top:50%; transform:translateY(-50%); background:rgba(0,0,0,0.6); color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:16px; display:flex; align-items:center; justify-content:center;">‹</button>' +
            '<button class="image-nav-btn next-btn" onclick="changeImage(' + placeId + ', ' + data.images.length + ', ' + currentImageIndex + ', 1)" ' +
                    'style="position:absolute; right:10px; top:50%; transform:translateY(-50%); background:rgba(0,0,0,0.6); color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:16px; display:flex:align-items:center; justify-content:center;">›</button>'
          : '') +
          
          '<!-- 이미지 개수 표시 -->' +
          '<div style="position:absolute; bottom:10px; right:10px; background:rgba(0,0,0,0.7); color:white; padding:4px 8px; border-radius:12px; font-size:11px;">' +
            (currentImageIndex + 1) + ' / ' + data.images.length +
          '</div>' +
        '</div>';
        
        container.innerHTML = imageHtml;
      } else {
        // 이미지가 없는 경우
        let noImageHtml = '<div class="no-images" style="position:relative; width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#f8f9fa; color:#6c757d; font-size:13px;">' +
          '<div style="text-align:center;">' +
            '<div style="font-size:48px; margin-bottom:8px;">📷</div>' +
            '<div>사진이 없습니다</div>' +
          '</div>' +
        '</div>';
        
        container.innerHTML = noImageHtml;
      }
    })
    .catch(error => {
      console.error('이미지 로드 오류:', error);
      container.innerHTML = '<div class="no-images" style="padding:20px; text-align:center; background:#f8f9fa; border-radius:8px; color:#6c757d; font-size:13px;">사진이 없습니다</div>';
    });
}

// 이미지 모달 열기
function openImageModal(imagePath, placeId, currentIndex) {
  // HTML에 정의된 모달 사용
  const modal = document.getElementById('imageModal');
  const modalImg = document.getElementById('modalImage');
  
  if (!modal || !modalImg) {
    return;
  }
  
  // 캐시 방지를 위한 타임스탬프 추가
  const timestamp = Date.now();
  
  // 이미지 경로 설정
  modalImg.src = imagePath + '?t=' + timestamp;
  
  // 모달에 placeId와 currentIndex 정보 저장
  modal.setAttribute('data-place-id', placeId);
  modal.setAttribute('data-current-index', currentIndex);
  
  // 이미지 개수 표시 초기화
  const counter = document.getElementById('modalImageCounter');
  if (counter) {
    // InfoWindow에서 총 이미지 개수 가져오기
    const infoWindow = document.querySelector('.infoWindow');
    if (infoWindow) {
      const imageContainer = infoWindow.querySelector('.place-images-container');
      if (imageContainer) {
        const counterText = imageContainer.querySelector('div[style*="position:absolute; bottom:10px; right:10px"]');
        if (counterText) {
          const match = counterText.textContent.match(/(\d+) \/ (\d+)/);
          if (match) {
            const totalImages = parseInt(match[2]);
            counter.textContent = (currentIndex + 1) + ' / ' + totalImages;
          }
        }
      }
    }
  }
  
  // 모달 표시
  modal.classList.add('show');
}

// 이미지 모달 닫기
function closeImageModal() {
  const modal = document.getElementById('imageModal');
  if (modal) {
    modal.classList.remove('show');
  }
}

// 이미지 업로드 모달 열기 (관리자용)
function openImageUploadModal(placeId) {
  const modal = document.createElement('div');
  modal.id = 'imageUploadModal';
  modal.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.8);
    z-index: 10000;
    display: flex;
    align-items: center;
    justify-content: center;
  `;
  
  modal.innerHTML = '<div style="background:white; padding:24px; border-radius:12px; max-width:500px; width:90%; max-height:90%; overflow-y:auto;">' +
    '<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">' +
      '<h3 style="margin:0; color:#333;">이미지 추가</h3>' +
      '<button onclick="closeImageUploadModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:#666;">&times;</button>' +
    '</div>' +
    
          '<form id="imageUploadForm" action="<%=root%>/main/uploadImages.jsp" method="post" enctype="multipart/form-data">' +
        '<input type="hidden" name="place_id" value="' + placeId + '">' +
      '<div style="margin-bottom:16px;">' +
        '<label style="display:block; margin-bottom:8px; font-weight:500; color:#333;">이미지 파일 선택 (여러장 가능)</label>' +
        '<input type="file" name="images" multiple accept="image/*" style="width:100%; padding:8px; border:1px solid #ddd; border-radius:6px;" required>' +
      '</div>' +
      
      '<div style="display:flex; gap:8px; justify-content:flex-end;">' +
        '<button type="button" onclick="closeImageUploadModal()" style="background:#6c757d; color:white; border:none; padding:10px 20px; border-radius:6px; cursor:pointer;">취소</button>' +
        '<button type="submit" style="background:#1275E0; color:white; border:none; padding:10px 20px; border-radius:6px; cursor:pointer;">업로드</button>' +
      '</div>' +
    '</form>' +
  '</div>';
  
  document.body.appendChild(modal);
  
  // 폼 제출 이벤트 추가 - 디버깅용
  document.getElementById('imageUploadForm').onsubmit = function(e) {
    console.log('폼 제출 시작 - placeId:', placeId);
    
    // 폼 데이터 확인
    const formData = new FormData(this);
    console.log('FormData place_id 값:', formData.get('place_id'));
    console.log('FormData images 값:', formData.get('images'));
    
    // 일반 폼 제출 허용
  };
}

// 이미지 업로드 모달 닫기
function closeImageUploadModal() {
  const modal = document.getElementById('imageUploadModal');
  if (modal) modal.remove();
}

// 이미지 관리 모달 열기 (관리자용)
function openImageManageModal(placeId) {
  const modal = document.createElement('div');
  modal.id = 'imageManageModal';
  modal.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.8);
    z-index: 10000;
    display: flex;
    align-items: center;
    justify-content: center;
  `;
  
  modal.innerHTML = '<div style="background:white; padding:24px; border-radius:12px; max-width:800px; width:90%; max-height:90%; overflow-y:auto;">' +
    '<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">' +
      '<h3 style="margin:0; color:#333;">이미지 관리</h3>' +
      '<button onclick="closeImageManageModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:#666;">&times;</button>' +
    '</div>' +
    
    '<div id="imageManageContent" style="min-height:200px; display:flex; align-items:center; justify-content:center; color:#666;">' +
      '<div>이미지 로딩 중...</div>' +
    '</div>' +
  '</div>';
  
  document.body.appendChild(modal);
  
  // 이미지 목록 로드
  loadImagesForManagement(placeId);
}

// 이미지 관리 모달 닫기
function closeImageManageModal() {
  const modal = document.getElementById('imageManageModal');
  if (modal) modal.remove();
}

// 이미지 관리용 이미지 목록 로드
function loadImagesForManagement(placeId) {
  const contentDiv = document.getElementById('imageManageContent');
  if (!contentDiv) return;
  
  const requestUrl = '<%=root%>/main/getPlaceImages.jsp?placeId=' + placeId;
  
  fetch(requestUrl)
    .then(response => response.json())
    .then(data => {
      if (data.success && data.images && data.images.length > 0) {
        // 이미지가 있는 경우 - 그리드 형태로 표시
        let imagesHtml = '<div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(200px, 1fr)); gap:16px; margin-bottom:20px;">';
        
        data.images.forEach((image, index) => {
          console.log('이미지 데이터:', image); // 디버깅 로그 추가
          const timestamp = Date.now();
          
          // 대표사진 변경 버튼 (1번이 아닌 이미지에만 표시)
          const mainImageButton = image.imageOrder !== 1 ? 
            '<button onclick="setAsMainImage(' + image.id + ', ' + placeId + ')" ' +
            'style="background:#28a745; color:white; border:none; padding:6px 12px; border-radius:4px; cursor:pointer; font-size:12px; margin-left:4px;">대표사진</button>' : '';
          
          imagesHtml += '<div style="position:relative; border:1px solid #ddd; border-radius:8px; overflow:hidden; background:#f8f9fa;">' +
            '<img src="http://localhost:8083<%=root%>' + image.imagePath + '?t=' + timestamp + '" ' +
                 'style="width:100%; height:150px; object-fit:cover;" alt="이미지 ' + (index + 1) + '">' +
            '<div style="padding:12px; text-align:center;">' +
              '<div style="font-size:12px; color:#666; margin-bottom:8px;">순서: ' + image.imageOrder + '</div>' +
              '<div style="display:flex; gap:4px; justify-content:center;">' +
                '<button onclick="deleteImage(' + image.id + ', ' + placeId + ')" ' +
                        'style="background:#dc3545; color:white; border:none; padding:6px 12px; border-radius:4px; cursor:pointer; font-size:12px;">삭제</button>' +
                mainImageButton +
              '</div>' +
            '</div>' +
          '</div>';
        });
        
        imagesHtml += '</div>';
        contentDiv.innerHTML = imagesHtml;
      } else {
        // 이미지가 없는 경우
        contentDiv.innerHTML = '<div style="text-align:center; color:#666;">' +
          '<div style="font-size:48px; margin-bottom:16px;">📷</div>' +
          '<div>등록된 이미지가 없습니다</div>' +
        '</div>';
      }
    })
    .catch(error => {
      console.error('이미지 로드 오류:', error);
      contentDiv.innerHTML = '<div style="text-align:center; color:#dc3545;">이미지 로드에 실패했습니다</div>';
    });
}

// 이미지 삭제 함수
function deleteImage(imageId, placeId) {
  console.log('deleteImage 호출됨 - imageId:', imageId, 'placeId:', placeId);
  
  if (!imageId || imageId === 'undefined' || imageId === 'null') {
    console.error('유효하지 않은 imageId:', imageId);
    showToast('이미지 ID가 유효하지 않습니다.', 'error');
    return;
  }
  
  if (!confirm('정말로 이 이미지를 삭제하시겠습니까?')) {
    return;
  }
  
  const requestUrl = '<%=root%>/main/deleteImage.jsp';
  
  // URLSearchParams를 사용하여 일반적인 POST 요청으로 전송
  const params = new URLSearchParams();
  params.append('imageId', imageId);
  
  console.log('전송할 파라미터:', params.toString());
  
  fetch(requestUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: params
  })
  .then(response => response.json())
  .then(data => {
    console.log('삭제 응답:', data);
    if (data.success) {
      // 성공 시 이미지 목록 새로고침
      loadImagesForManagement(placeId);
      
      // InfoWindow의 이미지도 새로고침
      refreshInfoWindowImages(placeId);
      
      // 토스트 메시지 표시
      showToast('이미지가 성공적으로 삭제되었습니다.', 'success');
    } else {
      showToast(data.message || '이미지 삭제에 실패했습니다.', 'error');
    }
  })
  .catch(error => {
    console.error('이미지 삭제 오류:', error);
    showToast('이미지 삭제 중 오류가 발생했습니다.', 'error');
  });
}

// InfoWindow 이미지 새로고침
function refreshInfoWindowImages(placeId) {
  // InfoWindow가 열려있다면 이미지 새로고침
  const infoWindows = document.querySelectorAll('.infoWindow');
  for (let iw of infoWindows) {
    const imageContainer = iw.querySelector('.place-images-container');
    if (imageContainer && imageContainer.getAttribute('data-place-id') == placeId) {
      loadPlaceImages(placeId);
      break;
    }
  }
}

// 대표사진 변경 함수
function setAsMainImage(imageId, placeId) {
  console.log('setAsMainImage 호출됨 - imageId:', imageId, 'placeId:', placeId);
  
  if (!imageId || imageId === 'undefined' || imageId === 'null') {
    console.error('유효하지 않은 imageId:', imageId);
    showToast('이미지 ID가 유효하지 않습니다.', 'error');
    return;
  }
  
  const requestUrl = '<%=root%>/main/setMainImage.jsp';
  
  // URLSearchParams를 사용하여 POST 요청으로 전송
  const params = new URLSearchParams();
  params.append('imageId', imageId);
  params.append('placeId', placeId);
  
  console.log('전송할 파라미터:', params.toString());
  
  fetch(requestUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: params
  })
  .then(response => response.json())
  .then(data => {
    console.log('대표사진 변경 응답:', data);
    if (data.success) {
      // 성공 시 이미지 목록 새로고침
      loadImagesForManagement(placeId);
      
      // InfoWindow의 이미지도 새로고침
      refreshInfoWindowImages(placeId);
      
      // 토스트 메시지 표시
      showToast('대표사진이 성공적으로 변경되었습니다.', 'success');
    } else {
      showToast(data.message || '대표사진 변경에 실패했습니다.', 'error');
    }
  })
  .catch(error => {
    console.error('대표사진 변경 오류:', error);
    showToast('대표사진 변경 중 오류가 발생했습니다.', 'error');
  });
}



// 위시리스트 개수 로드 함수
function loadWishCount(placeId) {
  const wishCountElement = document.querySelector('.wish-count-' + placeId);
  if (!wishCountElement) return;
  
  const requestUrl = '<%=root%>/main/getWishCount.jsp';
  const params = new URLSearchParams();
  params.append('placeId', placeId);
  
  fetch(requestUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: params
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      wishCountElement.textContent = data.count;
    } else {
      wishCountElement.textContent = '0';
    }
  })
  .catch(error => {
    console.error('위시리스트 개수 로드 오류:', error);
    wishCountElement.textContent = '0';
  });
}

// 투표 현황 로드 함수
function loadVoteTrends(placeId) {
  const trendsElement = document.getElementById('voteTrends-' + placeId);
  if (!trendsElement) {
    return;
  }
  
  const requestUrl = '<%=root%>/main/getVoteTrends.jsp';
  const params = new URLSearchParams();
  params.append('placeId', placeId);
  
  fetch(requestUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: params
  })
  .then(response => response.json())
  .then(data => {
    if (data.success && data.trends) {
      const trends = data.trends;
      
      const congestionText = getCongestionText(trends.congestion);
      const genderRatioText = getGenderRatioText(trends.genderRatio);
      const waitTimeText = getWaitTimeText(trends.waitTime);
      
      trendsElement.innerHTML = '📊 역대 투표:<br>' +
        '<span style="color:#888; font-size:11px;">' +
        '#혼잡도:' + congestionText + ' ' +
        '#성비:' + genderRatioText + ' ' +
        '#대기시간:' + waitTimeText +
        '</span>';
    } else {
      trendsElement.innerHTML = '📊 역대 투표: 투표 데이터 없음';
    }
  })
  .catch(error => {
    console.error('투표 현황 로드 오류:', error);
    trendsElement.innerHTML = '📊 역대 투표: 로드 실패';
  });
}

// 혼잡도 텍스트 변환 함수
function getCongestionText(congestion) {
  if (!congestion || congestion === '') return '데이터없음';
  // 한글 문자열을 그대로 반환
  return congestion;
}

// 성비 텍스트 변환 함수
function getGenderRatioText(genderRatio) {
  if (!genderRatio || genderRatio === '') return '데이터없음';
  // 한글 문자열을 그대로 반환
  return genderRatio;
}

// 대기시간 텍스트 변환 함수
function getWaitTimeText(waitTime) {
  if (!waitTime || waitTime === '') return '데이터없음';
  // 한글 문자열을 그대로 반환
  return waitTime;
}

// 이미지 업로드 처리 - 간단한 방식으로 변경
// 이제 일반 폼 제출로 처리되므로 AJAX 불필요

// 이미지 변경 함수 (좌우 화살표 클릭 시)
function changeImage(placeId, totalImages, currentIndex, direction) {
  let newIndex = currentIndex + direction;
  
  // 인덱스 범위 조정
  if (newIndex < 0) newIndex = totalImages - 1;
  if (newIndex >= totalImages) newIndex = 0;
  
  // AJAX로 이미지 데이터 다시 가져와서 특정 인덱스 이미지 표시
  const requestUrl = root + '/main/getPlaceImages.jsp?placeId=' + placeId;
  
  fetch(requestUrl)
    .then(response => {
      return response.json();
    })
    .then(data => {
      if (data.success && data.images && data.images.length > 0) {
        const image = data.images[newIndex];
        const timestamp = Date.now();
        
        let imageHtml = '<div class="place-image-slider" style="position:relative; width:100%; height:100%;">' +
          '<!-- 현재 이미지 -->' +
          '<img src="http://localhost:8083' + root + image.imagePath + '?t=' + timestamp + '" alt="장소 이미지" ' +
               'style="width:100%; height:100%; object-fit:cover; cursor:pointer;" ' +
               'onclick="openImageModal(\'http://localhost:8083' + root + image.imagePath + '\', ' + placeId + ', ' + newIndex + ')">' +
          
          '<!-- 좌우 화살표 (이미지가 2개 이상일 때만 표시) -->' +
          (totalImages > 1 ? 
            '<button class="image-nav-btn prev-btn" onclick="changeImage(' + placeId + ', ' + totalImages + ', ' + newIndex + ', -1)" ' +
                    'style="position:absolute; left:10px; top:50%; transform:translateY(-50%); background:rgba(0,0,0,0.6); color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:16px; display:flex; align-items:center; justify-content:center;">‹</button>' +
            '<button class="image-nav-btn next-btn" onclick="changeImage(' + placeId + ', ' + totalImages + ', ' + newIndex + ', 1)" ' +
                    'style="position:absolute; right:10px; top:50%; transform:translateY(-50%); background:rgba(0,0,0,0.6); color:white; border:none; border-radius:50%; width:32px; height:32px; cursor:pointer; font-size:16px; display:flex:align-items:center; justify-content:center;">›</button>'
          : '') +
          
          '<!-- 이미지 개수 표시 -->' +
          '<div style="position:absolute; bottom:10px; right:10px; background:rgba(0,0,0,0.7); color:white; padding:4px 8px; border-radius:12px; font-size:11px;">' +
            (newIndex + 1) + ' / ' + totalImages +
          '</div>' +
          

        '</div>';
        
        const container = document.querySelector(`.place-images-container[data-place-id="${placeId}"]`);
        if (container) {
          container.innerHTML = imageHtml;
        } else {
          // InfoWindow 내부에서 찾기 시도
          const infoWindows = document.querySelectorAll('.infoWindow');
          let foundContainer = null;
          
          for (let iw of infoWindows) {
            const found = iw.querySelector('.place-images-container');
            if (found && found.getAttribute('data-place-id') == placeId) {
              foundContainer = found;
              break;
            }
          }
          
          if (foundContainer) {
            foundContainer.innerHTML = imageHtml;
          }
        }
      }
    })
    .catch(error => {
      console.error('이미지 변경 오류:', error);
    });
}

// 모달에서 이미지 변경 (좌우 화살표 클릭 시)
function changeModalImage(direction) {
  const modal = document.getElementById('imageModal');
  if (!modal) return;
  
  const placeId = modal.getAttribute('data-place-id');
  const currentIndex = parseInt(modal.getAttribute('data-current-index'));
  
  if (!placeId || isNaN(currentIndex)) {
    return;
  }
  
  // InfoWindow에서 총 이미지 개수 가져오기
  const infoWindow = document.querySelector('.infoWindow');
  if (!infoWindow) return;
  
  const imageContainer = infoWindow.querySelector('.place-images-container');
  if (!imageContainer) return;
  
  // 현재 표시된 이미지 개수 표시에서 총 개수 추출
  const counterText = imageContainer.querySelector('div[style*="position:absolute; bottom:10px; right:10px"]');
  if (counterText) {
    const match = counterText.textContent.match(/(\d+) \/ (\d+)/);
    if (match) {
      const totalImages = parseInt(match[2]);
      
      // changeImage 함수 호출 (InfoWindow 이미지 변경)
      changeImage(placeId, totalImages, currentIndex, direction);
      
      // 모달 이미지도 업데이트
      setTimeout(() => {
        updateModalImage(placeId, currentIndex + direction, totalImages);
      }, 100);
    }
  }
}

// 모달 이미지 업데이트
function updateModalImage(placeId, newIndex, totalImages) {
  // 인덱스 범위 조정
  if (newIndex < 0) newIndex = totalImages - 1;
  if (newIndex >= totalImages) newIndex = 0;
  
  // AJAX로 이미지 데이터 가져와서 모달 이미지 업데이트
  const requestUrl = root + '/main/getPlaceImages.jsp?placeId=' + placeId;
  
  fetch(requestUrl)
    .then(response => response.json())
    .then(data => {
      if (data.success && data.images && data.images.length > 0) {
        const image = data.images[newIndex];
        const timestamp = Date.now();
        
        // 모달 이미지 업데이트
        const modalImg = document.getElementById('modalImage');
        const modal = document.getElementById('imageModal');
        
        if (modalImg && modal) {
          modalImg.src = 'http://localhost:8083' + root + image.imagePath + '?t=' + timestamp;
          modal.setAttribute('data-current-index', newIndex);
          
          // 이미지 개수 표시 업데이트
          const counter = document.getElementById('modalImageCounter');
          if (counter) {
            counter.textContent = (newIndex + 1) + ' / ' + totalImages;
          }
        }
      }
    })
    .catch(error => {
      // 에러 처리 (콘솔 출력 없음)
    });
}
</script>

<!-- 이미지 모달 -->
<div id="imageModal" class="main-image-modal-overlay" onclick="closeImageModal()">
    <div class="main-image-modal-content" onclick="event.stopPropagation()">
        <button class="main-image-modal-close" onclick="closeImageModal()">&times;</button>
        <img id="modalImage" class="main-image-modal-img" src="" alt="확대된 이미지">
        
        <!-- 좌우 화살표 버튼 -->
        <button class="modal-nav-btn modal-prev-btn" onclick="changeModalImage(-1)">‹</button>
        <button class="modal-nav-btn modal-next-btn" onclick="changeModalImage(1)">›</button>
        
        <!-- 이미지 개수 표시 -->
        <div class="modal-image-counter" id="modalImageCounter"></div>
    </div>
</div>
