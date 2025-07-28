<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="community.CommunityDao" %>
<%@ page import="community.CommunityDto" %>

<%
    // 같이갈래 카테고리 ID (3번)
    int categoryId = 3;
    
    // 커뮤니티 글 목록을 가져오기 위한 DAO
    CommunityDao communityDao = new CommunityDao();
    
    // 날짜 포맷팅을 위한 SimpleDateFormat
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
    
    // 페이징 파라미터
    String pageStr = request.getParameter("page");
    int currentPage = 1;
    if (pageStr != null && !pageStr.trim().isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageStr);
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    int perPage = 10;
    int start = (currentPage - 1) * perPage;
    
    // 같이갈래 카테고리의 글 목록 가져오기
    List<CommunityDto> posts = communityDao.getPostsByCategory(categoryId, start, perPage);
    int totalCount = communityDao.getTotalCountByCategory(categoryId);
    int totalPages = (int) Math.ceil((double) totalCount / perPage);
%>

<div class="community-container">
    <!-- 헤더 -->
    <div class="community-header">
        <h1 class="community-title">👥 같이갈래?</h1>
        <p class="community-subtitle">함께 갈 사람을 찾아보세요</p>
    </div>

    <!-- 글 작성 버튼 -->
    <div class="write-section">
        <a href="<%=request.getContextPath()%>/community/write.jsp?category=<%= categoryId %>" class="write-btn">
            ✏️ 글 작성하기
        </a>
    </div>

    <!-- 글 목록 -->
    <div class="posts-section">
        <div class="category-posts">
            <div class="posts-list">
                <% 
                if(posts != null && !posts.isEmpty()) {
                    for(CommunityDto post : posts) { %>
                        <div class="post-item">
                            <div class="post-title">
                                <a href="<%=request.getContextPath()%>/community/view.jsp?id=<%= post.getId() %>">
                                    <%= post.getTitle() %>
                                </a>
                            </div>
                            <div class="post-meta">
                                <span class="post-author"><%= post.getUserid() %></span>
                                <span class="post-date"><%= post.getCreatedAt() != null ? sdf.format(post.getCreatedAt()) : "" %></span>
                                <span class="post-views">👁️ <%= post.getViews() %></span>
                                <span class="post-likes">👍 <%= post.getLikes() %></span>
                            </div>
                        </div>
                    <% }
                } else { %>
                    <div class="no-posts">
                        <p>아직 글이 없습니다. 첫 번째 글을 작성해보세요!</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- 페이징 -->
    <% if(totalPages > 1) { %>
        <div class="pagination">
            <% if(currentPage > 1) { %>
                <a href="?page=<%= currentPage - 1 %>" class="page-btn">← 이전</a>
            <% } %>
            
            <% for(int i = 1; i <= totalPages; i++) { %>
                <% if(i == currentPage) { %>
                    <span class="page-btn active"><%= i %></span>
                <% } else { %>
                    <a href="?page=<%= i %>" class="page-btn"><%= i %></a>
                <% } %>
            <% } %>
            
            <% if(currentPage < totalPages) { %>
                <a href="?page=<%= currentPage + 1 %>" class="page-btn">다음 →</a>
            <% } %>
        </div>
    <% } %>

    <!-- 뒤로가기 버튼 -->
    <div class="back-section">
        <a href="<%=request.getContextPath()%>/community/cumain.jsp" class="back-btn">
            ← 커뮤니티 메인으로
        </a>
    </div>
</div>