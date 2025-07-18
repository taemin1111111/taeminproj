<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Map.MapDao, java.util.*" %>

<%
    String root = request.getContextPath();
    MapDao mapDao = new MapDao();
    Map<String, Map<String, List<String>>> regionMap = mapDao.getDeepRegionMap();
%>

<div class="main-container text-white">
    <div class="section-title mb-4">
        <img src="<%=root%>/logo/fire.png"> 지역별 평점 보기
    </div>

    <div class="search-box input-group mb-4">
        <input type="text" class="form-control" placeholder="지역명을 검색하세요" id="searchInput">
        <button class="btn btn-outline-light" type="button"><i class="bi bi-search"></i></button>
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
</script>
