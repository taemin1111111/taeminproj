<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>
<%@ page import="hottalk_comment.Hottalk_CommentDao" %>


<%
    String root = request.getContextPath();
    HpostDao dao = new HpostDao();
    Hottalk_CommentDao commentDao = new Hottalk_CommentDao();
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
    
    // 카테고리 ID 처리
    int categoryId = 1; // 기본값
    if(request.getParameter("category") != null) {
        try {
            categoryId = Integer.parseInt(request.getParameter("category"));
        } catch(NumberFormatException e) {
            categoryId = 1;
        }
    }
    
    // 정렬 타입 처리
    String sortType = request.getParameter("sort");
    List<HpostDto> posts;
    int totalCount;
    
    if("popular".equals(sortType)) {
        // 인기글 정렬
        posts = dao.getPopularPostsByCategory(categoryId, start, perPage);
        totalCount = dao.getTotalCountByCategory(categoryId);
    } else {
        // 최신순 정렬 (기본)
        posts = dao.getPostsByCategory(categoryId, start, perPage);
        totalCount = dao.getTotalCountByCategory(categoryId);
    }
    
    int totalPages = (int) Math.ceil((double) totalCount / perPage);
%>

<div class="category-posts">
    <h3 class="posts-category-title"><%= "popular".equals(sortType) ? "🔥 헌팅썰 인기글" : "❤️ 헌팅썰" %></h3>
    <div class="posts-controls">
        <div class="sort-buttons">
            <button type="button" class="sort-btn <%= "popular".equals(sortType) ? "" : "active" %>" onclick="changeSort('latest')">최신순</button>
            <button type="button" class="sort-btn <%= "popular".equals(sortType) ? "active" : "" %>" onclick="changeSort('popular')">인기글</button>
        </div>
        <button type="button" onclick="loadWriteForm()" class="write-btn-small">글쓰기</button>
    </div>
    <div class="posts-table-header">
        <% if("popular".equals(sortType)) { %>
            <div class="col-rank">순위</div>
        <% } %>
        <div class="col-nickname">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;닉네임</div>
        <div class="col-title">제목</div>
        <div class="col-likes">좋아요</div>
        <div class="col-dislikes">싫어요</div>
        <div class="col-comments">댓글수</div>
        <div class="col-views">조회수</div>
        <div class="col-date">글쓴 날짜</div>
    </div>
    <div class="posts-list">
        <% if(totalCount > 0 && posts != null && !posts.isEmpty()) {
            for(int i = 0; i < posts.size(); i++) {
                HpostDto post = posts.get(i);
                int rank = start + i + 1; %>
                <div class="posts-table-row" id="post<%= post.getId() %>">
                    <% if("popular".equals(sortType)) { %>
                        <div class="col-rank" style="color: #ff6b6b; font-weight: bold;"><%= rank %>위</div>
                    <% } %>
                    <div class="col-nickname">
                        <% if(post.getUserid() != null && !post.getUserid().isEmpty() && !post.getUserid().equals("null")) { %>
                            ⭐ <%= post.getNickname() != null ? post.getNickname() : post.getUserid() %>
                        <% } else { %>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%= post.getNickname() != null ? post.getNickname() : "" %>
                        <% } %>
                    </div>
                    <div class="col-title">
                        <a href="javascript:void(0)" onclick="loadPostDetail(<%= post.getId() %>)"><%= post.getTitle() %></a>
                    </div>
                    <div class="col-likes">👍 <%= post.getLikes() %></div>
                    <div class="col-dislikes">👎 <%= post.getDislikes() %></div>
                    <div class="col-comments">💬 <%= commentDao.getCommentCountByPostId(post.getId()) %></div>
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
    // 현재 정렬 상태 확인
    const activeSortBtn = document.querySelector('.sort-btn.active');
    const sortType = activeSortBtn && activeSortBtn.textContent.includes('인기글') ? 'popular' : 'latest';
    
    // AJAX로 페이지 로드
    const url = '<%=root%>/community/hpost_list.jsp?page=' + page + 
                (sortType === 'popular' ? '&sort=popular' : '') +
                (categoryId !== 1 ? '&category=' + categoryId : '');
    
    fetch(url)
        .then(response => response.text())
        .then(html => {
            document.getElementById('posts-container').innerHTML = html;
        })
        .catch(() => {
            // 에러 처리
        });
}

function changeSort(sortType) {
    // 버튼 active 상태 변경
    document.querySelectorAll('.sort-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    // 정렬된 목록 로드
    const url = '<%=root%>/community/hpost_list.jsp?sort=' + sortType +
                (categoryId !== 1 ? '&category=' + categoryId : '');
    
    fetch(url)
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

// 페이지 로드 시 해시(#postID)가 있으면 해당 글로 스크롤
window.addEventListener('DOMContentLoaded', function() {
    if (location.hash && location.hash.startsWith('#post')) {
        var el = document.querySelector(location.hash);
        if (el) {
            el.scrollIntoView({behavior: 'smooth', block: 'center'});
            el.style.background = '#f3f6ff';
            setTimeout(function() { el.style.background = ''; }, 1500);
        }
    }
});
</script> 