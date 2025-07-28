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
                <img src="<%= root %>/uploads/<%= post.getPhoto1() %>" alt="첨부사진1" class="post-photo">
                <% if(post.getPhoto2() != null && !post.getPhoto2().isEmpty()) { %>
                    <img src="<%= root %>/uploads/<%= post.getPhoto2() %>" alt="첨부사진2" class="post-photo">
                <% } %>
                <% if(post.getPhoto3() != null && !post.getPhoto3().isEmpty()) { %>
                    <img src="<%= root %>/uploads/<%= post.getPhoto3() %>" alt="첨부사진3" class="post-photo">
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
        });
}

function dislikePost(postId) {
    fetch('<%= root %>/community/hpost_action.jsp?action=dislike&id=' + postId)
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                document.getElementById('dislikes-count').textContent = data.dislikes;
            }
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
            });
    }
}
</script>

<style>
.post-detail-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    background: white;
    border-radius: 15px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.post-header {
    border-bottom: 2px solid #f0f0f0;
    padding-bottom: 15px;
    margin-bottom: 20px;
}

.post-title {
    font-size: 1.8rem;
    color: #333;
    margin-bottom: 10px;
}

.post-meta {
    display: flex;
    gap: 20px;
    color: #666;
    font-size: 0.9rem;
}

.post-content {
    margin-bottom: 30px;
}

.content-text {
    line-height: 1.6;
    font-size: 1.1rem;
    color: #333;
    margin-bottom: 20px;
}

.post-photos {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.post-photo {
    max-width: 100%;
    height: auto;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.post-actions {
    border-top: 1px solid #f0f0f0;
    padding-top: 20px;
    margin-bottom: 20px;
}

.reaction-buttons {
    display: flex;
    gap: 10px;
}

.like-btn, .dislike-btn, .report-btn {
    padding: 8px 16px;
    border: none;
    border-radius: 20px;
    cursor: pointer;
    font-size: 0.9rem;
    transition: all 0.3s ease;
}

.like-btn {
    background: #4CAF50;
    color: white;
}

.dislike-btn {
    background: #f44336;
    color: white;
}

.report-btn {
    background: #ff9800;
    color: white;
}

.like-btn:hover, .dislike-btn:hover, .report-btn:hover {
    opacity: 0.8;
    transform: translateY(-2px);
}

.post-navigation {
    text-align: center;
    margin-top: 30px;
}

.back-btn {
    background: #667eea;
    color: white;
    padding: 10px 20px;
    border-radius: 25px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
}

.back-btn:hover {
    background: #5a6fd8;
    transform: translateY(-2px);
    text-decoration: none;
    color: white;
}
</style> 