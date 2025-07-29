<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>

<%
    String root = request.getContextPath();
    HpostDao dao = new HpostDao();
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
    
    // 페이징 처리
    int perPage = 30; // 페이지당 30개 글
    int currentPage = 1;
    if(request.getParameter("page") != null) {
        try {
            currentPage = Integer.parseInt(request.getParameter("page"));
        } catch(NumberFormatException e) {
            currentPage = 1;
        }
    }
    int start = (currentPage - 1) * perPage;
    
    List<HpostDto> posts = dao.getPostsByCategory(1, start, perPage);
    int totalCount = dao.getTotalCountByCategory(1);
    int totalPages = (int) Math.ceil((double) totalCount / perPage);
%>

<div class="category-posts">
    <div class="posts-header-flex">
        <h3 class="posts-category-title">❤️ 헌팅썰</h3>
        <button type="button" onclick="loadWriteForm()" class="write-btn-small">글쓰기</button>
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
                        <a href="javascript:void(0)" onclick="loadPostDetail(<%= post.getId() %>)"><%= post.getTitle() %></a>
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
            
            <% 
            // 페이징 범위 계산 (최대 10개 페이지만 표시)
            int startPage = Math.max(1, currentPage - 4);
            int endPage = Math.min(totalPages, startPage + 9);
            if(endPage - startPage < 9) {
                startPage = Math.max(1, endPage - 9);
            }
            
            for(int i = startPage; i <= endPage; i++) { %>
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
    fetch('<%=root%>/community/hpost_list.jsp?page=' + page)
        .then(response => response.text())
        .then(html => {
            document.getElementById('posts-container').innerHTML = html;
        })
        .catch(() => {
            // 에러 처리
        });
}

function loadWriteForm() {
    // AJAX로 글쓰기 폼 로드
    fetch('<%=root%>/community/hpost_insert.jsp')
        .then(response => response.text())
        .then(html => {
            document.getElementById('posts-container').innerHTML = html;
        })
        .catch(() => {
            // 에러 처리
        });
}

function loadPostDetail(postId) {
    // AJAX로 글 상세보기 로드
    fetch('<%=root%>/community/hpost_detail.jsp?id=' + postId)
        .then(response => response.text())
        .then(html => {
            document.getElementById('posts-container').innerHTML = html;
        })
        .catch(() => {
            // 에러 처리
        });
}
</script> 