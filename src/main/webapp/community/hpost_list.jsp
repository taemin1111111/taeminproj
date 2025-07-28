<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>

<%
    HpostDao dao = new HpostDao();
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
    
    // 페이징 처리
    int perPage = 30; // 페이지당 30개 글
    int currentPage = 1;
    if(request.getParameter("page") != null) {
        currentPage = Integer.parseInt(request.getParameter("page"));
    }
    int start = (currentPage - 1) * perPage;
    
    List<HpostDto> posts = dao.getPostsByCategory(1, start, perPage);
    int totalCount = dao.getTotalCountByCategory(1);
    int totalPages = (int) Math.ceil((double) totalCount / perPage);
%>

<div class="category-posts">
    <div class="posts-header-flex">
        <h3 class="posts-category-title">❤️ 헌팅썰</h3>
        <a href="<%=request.getContextPath()%>/index.jsp?main=community/hpost_insert.jsp" class="write-btn-small">글쓰기</a>
    </div>
    <hr class="posts-header-divider" />
    <div class="posts-table-header">
        <div class="col-nickname">닉네임</div>
        <div class="col-title">제목</div>
        <div class="col-likes">좋아요</div>
        <div class="col-dislikes">싫어요</div>
        <div class="col-views">조회수</div>
        <div class="col-date">글쓴 날짜</div>
    </div>
    <div class="posts-list">
        <% if(totalCount > 0 && posts != null && !posts.isEmpty()) {
            for(HpostDto post : posts) { %>
                <div class="posts-table-row">
                    <div class="col-nickname"><%= post.getNickname() != null ? post.getNickname() : post.getUserid() %></div>
                    <div class="col-title">
                        <a href="<%=request.getContextPath()%>/community/hpost_detail.jsp?id=<%= post.getId() %>"><%= post.getTitle() %></a>
                    </div>
                    <div class="col-likes">👍 <%= post.getLikes() %></div>
                    <div class="col-dislikes">👎 <%= post.getDislikes() %></div>
                    <div class="col-views">👁️ <%= post.getViews() %></div>
                    <div class="col-date"><%= post.getCreated_at() != null ? sdf.format(post.getCreated_at()) : "" %></div>
                </div>
        <%  }
        } else { %>
            <div class="posts-table-row no-posts-row">
                <div class="col-nickname"></div>
                <div class="col-title" style="text-align:center; color:#aaa;" colspan="5">아직 글이 없습니다.</div>
                <div class="col-likes"></div>
                <div class="col-dislikes"></div>
                <div class="col-views"></div>
                <div class="col-date"></div>
            </div>
        <% } %>
    </div>
    
    <!-- 페이징 처리 -->
    <% if(totalPages > 1) { %>
        <div class="pagination">
            <% if(currentPage > 1) { %>
                <a href="javascript:void(0)" onclick="loadPage(<%= currentPage - 1 %>)" class="page-btn">← 이전</a>
            <% } %>
            
            <% for(int i = 1; i <= totalPages; i++) { %>
                <% if(i == currentPage) { %>
                    <span class="page-btn active"><%= i %></span>
                <% } else { %>
                    <a href="javascript:void(0)" onclick="loadPage(<%= i %>)" class="page-btn"><%= i %></a>
                <% } %>
            <% } %>
            
            <% if(currentPage < totalPages) { %>
                <a href="javascript:void(0)" onclick="loadPage(<%= currentPage + 1 %>)" class="page-btn">다음 →</a>
            <% } %>
        </div>
    <% } %>
</div>

<script>
function loadPage(page) {
    // AJAX로 페이지 로드
    fetch('<%=request.getContextPath()%>/community/hpost_list.jsp?page=' + page)
        .then(response => response.text())
        .then(html => {
            document.getElementById('posts-container').innerHTML = html;
        })
        .catch(error => {
            console.error('페이지 로드 실패:', error);
        });
}
</script> 