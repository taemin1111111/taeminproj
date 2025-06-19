<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Map.MapDao" %>
<%@ page import="java.util.*" %>

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
            <%=sido %> ▼
        </button>

        <div id="<%=collapseId%>" class="collapse <%=sido.equals("서울") ? "show" : ""%> mb-4">
            <div class="card-box">
                <div class="row">
                    <%
                        Map<String, List<String>> sigunguMap = regionMap.get(sido);
                        for (String sigungu : sigunguMap.keySet()) {
                    %>
                        <div class="col-md-3 mb-3">
                            <div class="fw-bold mb-2">
                                <a href="#" class="text-dark text-decoration-none" onclick="loadRegionData('<%=sigungu%>', true)">
                                    <%= sigungu %>
                                </a>
                            </div>
                            <ul class="list-unstyled">
                                <% for (String dong : sigunguMap.get(sigungu)) { %>
                                    <li>
                                        <a href="#" class="text-dark text-decoration-none" onclick="loadRegionData('<%=dong%>', false)">
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

<div id="toast" style="position:fixed; top:20px; left:50%; transform:translateX(-50%); z-index:9999; display:none; padding:10px 20px; color:white; border-radius:5px;"></div>

<script>
function loadRegionData(region, isSigungu) {
    const url = '<%=root%>/review/getRegionData.jsp?region=' + encodeURIComponent(region) + '&isSigungu=' + isSigungu;
    fetch(url)
        .then(res => res.text())
        .then(html => {
            document.getElementById("result-box").innerHTML = html;
            document.getElementById("regionInput").value = region;
            document.getElementById("isSigunguInput").value = isSigungu;
            document.getElementById("hgIdInput").value = region;
        })
        .catch(err => {
            console.error("데이터 불러오기 실패:", err);
        });
}

function showToast(msg, type) {
    const toast = document.getElementById("toast");
    toast.innerText = msg;
    toast.style.backgroundColor = type === "success" ? "#28a745" : "#dc3545";
    toast.style.display = "block";
    setTimeout(() => toast.style.display = "none", 2000);
}
</script>
