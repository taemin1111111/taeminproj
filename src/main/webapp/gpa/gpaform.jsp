<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Map.MapDao" %>
<%@ page import="java.util.*" %>

<%
    String root = request.getContextPath();
    MapDao mapDao = new MapDao();
    Map<String, Map<String, List<String>>> regionMap = mapDao.getDeepRegionMap(); // sido → sigungu → dong
%>

<div class="main-container text-white">
    <!-- 타이틀 -->
    <div class="section-title mb-4">
        <img src="<%=root%>/logo/fire.png">
        지역별 평점 보기
    </div>

    <!-- 검색창 -->
    <div class="search-box input-group mb-4">
        <input type="text" class="form-control" placeholder="지역명을 검색하세요 (예: 홍대, 강남)" id="searchInput">
        <button class="btn btn-outline-light" type="button"><i class="bi bi-search"></i></button>
    </div>

    <!-- 지역 리스트 출력 -->
    <%
        for (String sido : regionMap.keySet()) {
            String collapseId = "collapse_" + sido;
    %>
        <!-- 시도명 -->
        <button class="btn btn-light mb-2" type="button" data-bs-toggle="collapse" data-bs-target="#<%=collapseId%>">
            <%=sido %> ▼
        </button>

        <!-- 시도 박스 -->
        <div id="<%=collapseId%>" class="collapse <%=sido.equals("서울") ? "show" : ""%> mb-4">
            <div class="card-box">
                <div class="row">
                    <%
                        Map<String, List<String>> sigunguMap = regionMap.get(sido);
                        for (String sigungu : sigunguMap.keySet()) {
                    %>
                        <div class="col-md-3 mb-3">
                            <!--  시군구 클릭 시 전체 -->
                            <div class="fw-bold mb-2">
                                <a href="#" class="text-dark text-decoration-none"
                                   onclick="loadRegionData('<%=sigungu%>', true)">
                                    <%= sigungu %>
                                </a>
                            </div>
                            <ul class="list-unstyled">
                                <% for (String dong : sigunguMap.get(sigungu)) { %>
                                    <li>
                                        <!-- ✅ 동 클릭 시 단일 지역 -->
                                        <a href="#" class="text-dark text-decoration-none"
                                           onclick="loadRegionData('<%=dong%>', false)">
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

    <!--  선택된 지역 정보 박스 -->
    <div id="result-box" class="mt-5"></div>
</div>

<!--  AJAX 스크립트 -->
<script>
function loadRegionData(region, isSigungu) {
    const url = '<%=root%>/gpa/getRegionData.jsp?region=' + encodeURIComponent(region) + '&isSigungu=' + isSigungu;
    
    fetch(url)
        .then(res => res.text())
        .then(html => {
            document.getElementById("result-box").innerHTML = html;
        })
        .catch(err => {
            console.error("데이터 불러오기 실패:", err);
            document.getElementById("result-box").innerHTML = "<p class='text-danger'>데이터를 불러오는 중 오류가 발생했습니다.</p>";
        });
}
</script>
