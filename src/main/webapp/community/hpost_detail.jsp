<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>

<%
    String root = request.getContextPath();
    int postId = Integer.parseInt(request.getParameter("id"));
    HpostDao dao = new HpostDao();
    HpostDto post = dao.getPostById(postId);
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    
    if(post == null) {
        response.sendRedirect(root + "/community/cumain.jsp");
        return;
    }
%>

<div class="post-detail-container" data-post-id="<%= post.getId() %>">
    <div class="post-header">
        <div class="post-header-top">
            <button class="delete-btn-small" onclick="window.deletePost(<%= post.getId() %>)">
                삭제
            </button>
        </div>
        <h1 class="post-title"><%= post.getTitle() %></h1>
        <div class="post-meta">
            <div class="post-info">
                <span class="post-author">작성자: 
                    <% if(post.getUserid() != null && !post.getUserid().isEmpty() && !post.getUserid().equals("null")) { %>
                        ⭐ <%= post.getNickname() != null ? post.getNickname() : post.getUserid() %>
                    <% } else { %>
                        <%= post.getNickname() != null ? post.getNickname() : "" %>
                    <% } %>
                </span>
                <span class="post-date">작성일: <%= post.getCreated_at() != null ? sdf.format(post.getCreated_at()) : "" %></span>
                <span class="post-views">👁️ 조회수: <%= post.getViews() %></span>
            </div>
            <button class="report-btn-small" onclick="window.reportPost(<%= post.getId() %>)">
                🚨 신고
            </button>
        </div>
    </div>
    
    <div class="post-content">
        <div class="content-text">
            <%= post.getContent().replace("\n", "<br>") %>
        </div>
        
        <% if(post.getPhoto1() != null && !post.getPhoto1().isEmpty()) { %>
            <div class="post-photos">
                <img src="<%= root %>/hpostsave/<%= post.getPhoto1() %>" alt="첨부사진1" class="post-photo" loading="lazy" onclick="openImageModal('<%= root %>/hpostsave/<%= post.getPhoto1() %>', 1)">
                <% if(post.getPhoto2() != null && !post.getPhoto2().isEmpty()) { %>
                    <img src="<%= root %>/hpostsave/<%= post.getPhoto2() %>" alt="첨부사진2" class="post-photo" loading="lazy" onclick="openImageModal('<%= root %>/hpostsave/<%= post.getPhoto2() %>', 2)">
                <% } %>
                <% if(post.getPhoto3() != null && !post.getPhoto3().isEmpty()) { %>
                    <img src="<%= root %>/hpostsave/<%= post.getPhoto3() %>" alt="첨부사진3" class="post-photo" loading="lazy" onclick="openImageModal('<%= root %>/hpostsave/<%= post.getPhoto3() %>', 3)">
                <% } %>
            </div>
        <% } %>
    </div>
    
    <div class="post-actions">
        <div class="reaction-buttons">
            <button class="like-btn" onclick="likePost(<%= post.getId() %>)">
                👍 좋아요 (<span id="likes-count"><%= post.getLikes() %></span>)
            </button>
            <button class="dislike-btn" onclick="dislikePost(<%= post.getId() %>)">
                👎 싫어요 (<span id="dislikes-count"><%= post.getDislikes() %></span>)
            </button>
        </div>
    </div>

    <!-- 댓글 입력 폼 -->
    <div class="comment-section">
        <form id="commentForm" class="comment-form" onsubmit="return false;">
            <%
            String loginid = (String)session.getAttribute("loginid");
            String nickname = (String)session.getAttribute("nickname");
            if(loginid != null && !loginid.trim().isEmpty()) {
                // 로그인된 경우: 닉네임 고정, 비밀번호만 입력
            %>
                <input type="text" id="commentNickname" class="comment-nickname" value="<%= nickname != null ? nickname : loginid %>" readonly style="background-color: #f5f5f5;">
                <input type="password" id="commentPasswd" class="comment-passwd" placeholder="비밀번호" maxlength="20" autocomplete="off">
            <%
            } else {
                // 로그인되지 않은 경우: 닉네임과 비밀번호 모두 입력
            %>
                <input type="text" id="commentNickname" class="comment-nickname" placeholder="닉네임" maxlength="20" autocomplete="off">
                <input type="password" id="commentPasswd" class="comment-passwd" placeholder="비밀번호" maxlength="20" autocomplete="off">
            <%
            }
            %>
            <textarea id="commentContent" class="comment-input" placeholder="댓글을 입력하세요" rows="2"></textarea>
            <button type="button" class="comment-submit" onclick="submitComment(<%= post.getId() %>)">댓글 등록</button>
        </form>
        <div class="comment-space" id="commentSpace"></div>
    </div>
    
    <div class="post-navigation">
        <a href="javascript:void(0)" onclick="loadCategoryPosts(1, '헌팅썰')" class="back-btn">← 목록으로 돌아가기</a>
    </div>
</div>

<!-- 이미지 모달 -->
<div id="imageModal" class="image-modal-overlay" onclick="closeImageModal()">
    <div class="image-modal-content" onclick="event.stopPropagation()">
        <button class="image-modal-close" onclick="closeImageModal()">&times;</button>
        <button class="image-modal-nav image-modal-prev" onclick="prevImage()" id="prevBtn" style="display: none;">&lt;</button>
        <button class="image-modal-nav image-modal-next" onclick="nextImage()" id="nextBtn" style="display: none;">&gt;</button>
        <img id="modalImage" class="image-modal-img" src="" alt="확대된 이미지">
        <div class="image-modal-counter" id="imageCounter" style="display: none;"></div>
    </div>
</div>

 