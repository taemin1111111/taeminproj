<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="review.ReviewDao, review.ReviewDto" %>
<%@ page import="java.util.List" %>

<%
    // 1) 파라미터 받기
    request.setCharacterEncoding("UTF-8");
    String region       = request.getParameter("region");
    boolean isSigungu   = Boolean.parseBoolean(request.getParameter("isSigungu"));
    String categoryStr  = request.getParameter("category");
    
    // 'all' 이거나 null 이면 -1, 아니면 실제 카테고리 ID
    int categoryFilter = -1;
    if (categoryStr != null && !"all".equals(categoryStr)) {
        try {
            categoryFilter = Integer.parseInt(categoryStr);
        } catch (NumberFormatException e) { /* 무시 */ }
    }

    // 2) DAO 호출
    ReviewDao dao = new ReviewDao();
    double avg = isSigungu
        ? dao.getAverageStarsBySigungu(region)
        : dao.getAverageStars(region);
    int count = isSigungu
        ? dao.getReviewCountBySigungu(region)
        : dao.getReviewCount(region);

    List<ReviewDto> list;
    if (categoryFilter == -1) {
        // 전체 리뷰
        list = dao.getReviews(region, isSigungu);
    } else {
        // 특정 카테고리 리뷰
        list = dao.getReviews(region, isSigungu, categoryFilter);
    }
%>

<!-- 1️⃣ 평점 요약 박스 -->
<div class="card-box mb-3">
  <div class="d-flex justify-content-between align-items-center mb-2">
    <h4 class="fw-bold">
      <%= region %> <%= isSigungu ? "전체 평점" : "평점" %>
    </h4>
    <% if (!isSigungu) { %>
      <button class="btn btn-sm btn-outline-primary"
              data-bs-toggle="modal"
              data-bs-target="#reviewModal">
        후기 작성
      </button>
    <% } %>
  </div>
  <div class="d-flex align-items-center mb-1">
    <% for (int i = 1; i <= 5; i++) { %>
      <i class="bi <%= (avg >= i)
           ? "bi-star-fill"
           : (avg >= i - 0.5 ? "bi-star-half" : "bi-star") %>"
         style="color: #f9cb3e;"></i>
    <% } %>
    <span class="ms-2 small">(<%= String.format("%.1f", avg) %>)</span>
  </div>
  <div class="mt-2">
    <p class="text-muted small mb-0">
      후기 수: <%= count %>건
    </p>
  </div>
</div>

<!-- 2️⃣ 카테고리 필터 버튼 -->
<div class="mb-3 d-flex gap-2">
  <button
    class="filter-btn"
    data-category="all"
    data-active="<%= categoryFilter==-1 ? "true" : "false" %>"
    onclick="filterReviews('all')">
    전체 보기
  </button>
  <button
    class="filter-btn"
    data-category="1"
    data-active="<%= categoryFilter==1 ? "true" : "false" %>"
    onclick="filterReviews('1')">
    클럽
  </button>
  <button
    class="filter-btn"
    data-category="2"
    data-active="<%= categoryFilter==2 ? "true" : "false" %>"
    onclick="filterReviews('2')">
    헌팅포차
  </button>
  <button
    class="filter-btn"
    data-category="3"
    data-active="<%= categoryFilter==3 ? "true" : "false" %>"
    onclick="filterReviews('3')">
    라운지
  </button>
</div>


<!-- 3️⃣ 리뷰 리스트 -->
<% if (list.isEmpty()) { %>
  <p class="text-muted">아직 등록된 후기가 없습니다.</p>
<% } else { %>
  <div class="review-list">
    <% for (ReviewDto dto : list) { %>
      <div class="card-box mb-3">
        <div class="d-flex justify-content-between align-items-center mb-1">
          <strong><%= dto.getNickname() %></strong>
          <div class="text-muted small">
            <%= dto.getWriteday().toString().substring(0, 10) %>
            <span class="ms-2">추천: <%= dto.getGood() %></span>
            <% 
              String categoryName = "기타";
              switch (dto.getCategory_id()) {
                  case 1: categoryName="클럽"; break;
                  case 2: categoryName="헌팅포차"; break;
                  case 3: categoryName="라운지"; break;
              }
            %>
            <span class="ms-2">· <%= categoryName %></span>
          </div>
        </div>
        <div class="mb-1">
          <% for (int i = 1; i <= 5; i++) { %>
            <i class="bi <%= (dto.getStars() >= i)
                 ? "bi-star-fill"
                 : (dto.getStars() >= i - 0.5 ? "bi-star-half" : "bi-star") %>"
               style="color: #f9cb3e;"></i>
          <% } %>
        </div>
        <p class="mb-0"><%= dto.getContent() %></p>
      </div>
    <% } %>
  </div>
<% } %>
