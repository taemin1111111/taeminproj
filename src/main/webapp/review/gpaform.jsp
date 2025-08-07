<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Map.MapDao, java.util.*" %>

<%
    String root = request.getContextPath();
    MapDao mapDao = new MapDao();
    Map<String, Map<String, List<String>>> regionMap = mapDao.getDeepRegionMap();
    
    // 지역명 목록 로드 (자동완성용)
    List<String> regionNameList = mapDao.getAllRegionNames();
%>

<div class="main-container text-white">
    <div class="section-title mb-4">
        <img src="<%=root%>/logo/fire.png"> <span style="color: white;">지역별 평점 보기</span>
    </div>

    <div class="search-box input-group mb-4" style="position: relative;">
        <input type="text" class="form-control" placeholder="지역명을 검색하세요" id="searchInput">
        <button class="btn btn-outline-light" type="button" onclick="searchRegion()"><i class="bi bi-search"></i></button>
        <!-- 자동완성 드롭다운 -->
        <div id="autocompleteList" style="position: absolute; top: 100%; left: 0; right: 0; background: white; border: 1px solid #ddd; border-radius: 0 0 8px 8px; max-height: 200px; overflow-y: auto; z-index: 1000; display: none; box-shadow: 0 4px 8px rgba(0,0,0,0.1);"></div>
    </div>

    <%
        for (String sido : regionMap.keySet()) {
            String collapseId = "collapse_" + sido;
    %>
        <button class="btn btn-light mb-2" type="button" data-bs-toggle="collapse" data-bs-target="#<%=collapseId%>">
            <%= sido %> ▼
        </button>

        <div id="<%=collapseId%>" class="collapse <%= sido.equals("서울") ? "show" : "" %> mb-4">
            <div class="card-box">
                <div class="row">
                    <%
                        Map<String, List<String>> sigunguMap = regionMap.get(sido);
                        for (String sigungu : sigunguMap.keySet()) {
                    %>
                        <div class="col-md-3 mb-3">
                            <div class="fw-bold mb-2">
                                <a href="#" class="text-dark text-decoration-none"
                                   onclick="loadRegionData('<%=sigungu%>', true, event)">
                                    <%= sigungu %>
                                </a>
                            </div>
                            <ul class="list-unstyled">
                                <% for (String dong : sigunguMap.get(sigungu)) { %>
                                    <li>
                                        <a href="#" class="text-dark text-decoration-none"
                                           onclick="loadRegionData('<%=dong%>', false, event)">
                                            <%= dong %>
                                        </a>
                                    </li>
                                <% } %>
                            </ul>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    <% } %>

    <div id="result-box" class="mt-5"></div>
</div>

<jsp:include page="reviewModal.jsp" />

<div id="toast"
     style="position:fixed; top:20px; left:50%; transform:translateX(-50%);
            z-index:9999; display:none; padding:10px 20px; color:white;
            border-radius:5px;"></div>

<script>
  const root = "<%=root%>";
  let currentRegion = "";
  let currentIsSigungu = false;
  
  // 지역명 목록 (자동완성용) - 동적으로 로드
  var regionNameList = [];
  
  // 페이지 로드 시 지역명 데이터 가져오기
  function loadRegionNames() {
    fetch(root + '/review/getRegionNames.jsp')
      .then(response => response.json())
      .then(data => {
        regionNameList = data;
      })
      .catch(error => {
        console.error('지역명 로드 실패:', error);
      });
  }

  function loadRegionData(region, isSigungu, event) {
    if (event) event.preventDefault();
    currentRegion = region;
    currentIsSigungu = isSigungu;

    const url = root + "/review/getRegionData.jsp?region=" + encodeURIComponent(region) + "&isSigungu=" + isSigungu;
    fetch(url)
      .then(function(res) { return res.text(); })
      .then(function(html) {
        document.getElementById("result-box").innerHTML = html;
        // 스크롤 이동 추가
        document.getElementById("result-box").scrollIntoView({ behavior: "smooth" });
      })
      .catch(function(err) {
        console.error("데이터 불러오기 실패:", err);
      });
  }

  function filterReviews(categoryId) {
    // 버튼 active 토글
    document.querySelectorAll(".custom-filter")
            .forEach(function(btn) { btn.classList.remove("active"); });
    const btn = document.querySelector('.filter-btn[data-category="' + categoryId + '"]');
    if (btn) btn.classList.add("active");

    const url = root + "/review/getRegionData.jsp"
              + "?region=" + encodeURIComponent(currentRegion)
              + "&isSigungu=" + currentIsSigungu
              + "&category=" + categoryId;

    fetch(url)
      .then(function(res) { return res.text(); })
      .then(function(html) {
        document.getElementById("result-box").innerHTML = html;
      })
      .catch(function(err) {
        console.error("필터링 데이터 불러오기 실패:", err);
      });
  }

  function showToast(msg, type) {
    const toast = document.getElementById("toast");
    toast.innerText = msg;
    toast.style.backgroundColor = type === "success" ? "#28a745" : "#dc3545";
    toast.style.display = "block";
    setTimeout(function() {
      toast.style.display = "none";
    }, 2000);
  }

  function recommendReview(reviewNum) {
    fetch(root + "/review/recommendAction.jsp?reviewNum=" + reviewNum, {
      method: "GET",
      credentials: "same-origin"
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        document.getElementById("good-count-" + reviewNum).innerText = data.good;
        showToast("추천 완료!", "success");
      } else {
        showToast(data.message, "error");
      }
    })
    .catch(err => {
      showToast("서버 오류", "error");
    });
  }

  function openReviewModal(region, isSigungu) {
    document.getElementById("hgIdInput").value = region;
    document.getElementById("regionInput").value = region;
    document.getElementById("isSigunguInput").value = isSigungu;
    var modal = new bootstrap.Modal(document.getElementById('reviewModal'));
    modal.show();
  }

  // 자동완성 기능
  function showAutocompleteList() {
    var keyword = document.getElementById('searchInput').value.trim();
    var autocompleteList = document.getElementById('autocompleteList');
    
    if (!keyword) { 
      autocompleteList.style.display = 'none'; 
      return; 
    }
    
    // 지역명에서 키워드와 일치하는 항목 필터링
    var filtered = regionNameList.filter(function(item) {
      return item && item.toLowerCase().indexOf(keyword.toLowerCase()) !== -1;
    }).slice(0, 8); // 최대 8개
    
    if (filtered.length === 0) { 
      autocompleteList.style.display = 'none'; 
      return; 
    }
    
    // 자동완성 리스트 생성
    autocompleteList.innerHTML = filtered.map(function(item) {
      return '<div class="autocomplete-item" style="padding:10px 18px; font-size:1.04rem; color:#222 !important; cursor:pointer; transition:background 0.13s; border-bottom:1px solid #f3f3f3; background:transparent;">' + item + '</div>';
    }).join('');
    
    autocompleteList.style.display = 'flex';
    
         // 항목 클릭 시 입력창에 반영
     Array.from(autocompleteList.children).forEach(function(child) {
       child.onclick = function() {
         document.getElementById('searchInput').value = child.textContent;
         autocompleteList.style.display = 'none';
         searchRegion(); // 자동으로 검색 실행
       };
     });
  }

  // 검색 기능
  function searchRegion() {
    var keyword = document.getElementById('searchInput').value.trim();
    if (!keyword) {
      showToast("지역명을 입력해주세요.", "error");
      return;
    }
    
    // 지역명에서 정확히 일치하는 항목 찾기
    var foundRegion = regionNameList.find(function(item) {
      return item && item.toLowerCase() === keyword.toLowerCase();
    });
    
    if (foundRegion) {
      // 지역 데이터 로드 (동으로 처리 - getAllRegionNames는 dong만 반환하므로)
      loadRegionData(foundRegion, false);
      document.getElementById('autocompleteList').style.display = 'none';
    } else {
      showToast("해당 지역을 찾을 수 없습니다.", "error");
    }
  }

  // 이벤트 리스너 등록
  document.addEventListener('DOMContentLoaded', function() {
    // 지역명 데이터 로드
    loadRegionNames();
    
    var searchInput = document.getElementById('searchInput');
    var autocompleteList = document.getElementById('autocompleteList');
    
    // 입력 시 자동완성 표시
    searchInput.addEventListener('input', showAutocompleteList);
    searchInput.addEventListener('focus', showAutocompleteList);
    
    // 포커스 아웃 시 자동완성 숨김
    searchInput.addEventListener('blur', function() {
      setTimeout(function() { 
        autocompleteList.style.display = 'none'; 
      }, 120);
    });
    
    // Enter 키로 검색
    searchInput.addEventListener('keypress', function(e) {
      if (e.key === 'Enter') {
        searchRegion();
      }
    });
  });

  // 자동완성 아이템 호버 효과
  var style = document.createElement('style');
  style.innerHTML = `.autocomplete-item:hover { background: #f0f4fa !important; color: #1275E0 !important; }`;
  document.head.appendChild(style);
</script>
