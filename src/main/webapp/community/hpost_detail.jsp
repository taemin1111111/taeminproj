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

<div class="post-detail-container">
    <div class="post-header">
        <h1 class="post-title"><%= post.getTitle() %></h1>
        <div class="post-meta">
            <span class="post-author">작성자: <%= post.getNickname() != null ? post.getNickname() : post.getUserid() %></span>
            <span class="post-date">작성일: <%= post.getCreated_at() != null ? sdf.format(post.getCreated_at()) : "" %></span>
        </div>
    </div>
    
    <div class="post-content">
        <div class="content-text">
            <%= post.getContent().replace("\n", "<br>") %>
        </div>
        
        <% if(post.getPhoto1() != null && !post.getPhoto1().isEmpty()) { %>
            <div class="post-photos">
                <img src="<%= root %>/hpostsave/<%= post.getPhoto1() %>" alt="첨부사진1" class="post-photo" loading="lazy">
                <% if(post.getPhoto2() != null && !post.getPhoto2().isEmpty()) { %>
                    <img src="<%= root %>/hpostsave/<%= post.getPhoto2() %>" alt="첨부사진2" class="post-photo" loading="lazy">
                <% } %>
                <% if(post.getPhoto3() != null && !post.getPhoto3().isEmpty()) { %>
                    <img src="<%= root %>/hpostsave/<%= post.getPhoto3() %>" alt="첨부사진3" class="post-photo" loading="lazy">
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
            <button class="report-btn" onclick="reportPost(<%= post.getId() %>)">
                🚨 신고
            </button>
        </div>
    </div>
    
    <div class="post-navigation">
        <a href="<%= root %>/community/cumain.jsp" class="back-btn">← 목록으로 돌아가기</a>
    </div>
</div>

<script>
function likePost(postId) {
    fetch('<%= root %>/community/hpost_action.jsp?action=like&id=' + postId)
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                document.getElementById('likes-count').textContent = data.likes;
            }
        })
        .catch(() => {
            // 에러 처리
        });
}

function dislikePost(postId) {
    fetch('<%= root %>/community/hpost_action.jsp?action=dislike&id=' + postId)
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                document.getElementById('dislikes-count').textContent = data.dislikes;
            }
        })
        .catch(() => {
            // 에러 처리
        });
}

function reportPost(postId) {
    if(confirm('이 글을 신고하시겠습니까?')) {
        fetch('<%= root %>/community/hpost_action.jsp?action=report&id=' + postId)
            .then(response => response.json())
            .then(data => {
                if(data.success) {
                    alert('신고가 접수되었습니다.');
                }
            })
            .catch(() => {
                // 에러 처리
            });
    }
}
</script> 