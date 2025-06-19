<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="review.ReviewDao, review.ReviewDto" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%
    request.setCharacterEncoding("UTF-8");

    String region = request.getParameter("region");
    boolean isSigungu = Boolean.parseBoolean(request.getParameter("isSigungu"));

    ReviewDao dao = new ReviewDao();

    // ✅ 평점 및 리뷰 수
    double avg = isSigungu ? dao.getAverageStarsBySigungu(region) : dao.getAverageStars(region);
    int count = isSigungu ? dao.getReviewCountBySigungu(region) : dao.getReviewCount(region);

    // ✅ 후기 리스트
    List<ReviewDto> reviewList = dao.getReviews(region, isSigungu);
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!-- ✅ 평점 박스 -->
<div class="card-box mb-4 position-relative">
    <div class="d-flex align-items-center mb-2">
        <h4 class="mb-0" style="font-weight:700; font-size:1.25rem; color:var(--text-main);">
            <%= region %> <%= isSigungu ? "전체 평점" : "평점" %>
        </h4>
    </div>

    <p class="mb-1" style="color:var(--text-sub);">
        평균 평점:
        <% for(int i=1; i<=5; i++){ %>
            <i class="bi <%= (avg >= i) ? "bi-star-fill" : (avg >= i-0.5 ? "bi-star-half" : "bi-star") %>" style="color: var(--star-active);"></i>
        <% } %> (<%= String.format("%.1f", avg) %>)
    </p>

    <p class="mb-2" style="color:var(--text-sub);">후기 수: <%= count %>건</p>

    <% if (!isSigungu) { %>
        <button class="btn btn-sm btn-outline-primary position-absolute" style="bottom:1rem; right:1rem;" data-bs-toggle="modal" data-bs-target="#reviewModal">
            후기 작성
        </button>
    <% } %>
</div>

<!-- ✅ 후기 리스트 -->
<% if (reviewList.isEmpty()) { %>
    <div class="text-muted text-center mt-3">등록된 리뷰가 없습니다.</div>
<% } else { %>
    <div class="mt-3">
        <% for (ReviewDto dto : reviewList) { %>
            <div class="border rounded p-3 mb-3 bg-light">
                <div class="d-flex justify-content-between mb-1">
                    <strong><%= dto.getNickname() %></strong>
                    <small class="text-muted"><%= sdf.format(dto.getWriteday()) %></small>
                </div>
                <div class="mb-2">
                    <% for (int i = 1; i <= 5; i++) { %>
                        <i class="bi <%= (dto.getStars() >= i) ? "bi-star-fill" : (dto.getStars() >= i - 0.5 ? "bi-star-half" : "bi-star") %>" style="color: var(--star-active);"></i>
                    <% } %>
                    (<%= dto.getStars() %>)
                </div>
                <div><%= dto.getContent() %></div>
            </div>
        <% } %>
    </div>
<% } %>
