<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="hottalk_report.Hottalk_ReportDao" %>
<%@ page import="hottalk_report.Hottalk_ReportDto" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String provider = (String)session.getAttribute("provider");
    
    // 관리자 권한 확인
    if(loginId == null || !"admin".equals(provider)) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
    
    // 신고된 게시물 목록 가져오기
    Hottalk_ReportDao reportDao = new Hottalk_ReportDao();
    HpostDao postDao = new HpostDao();
    
    // 신고된 게시물 ID 목록 (중복 제거)
    List<Integer> reportedPostIds = reportDao.getReportedPostIds();
    List<HpostDto> reportedPosts = new ArrayList<>();
    
    for(Integer postId : reportedPostIds) {
        HpostDto post = postDao.getPostById(postId);
        if(post != null) {
            reportedPosts.add(post);
        }
    }
%>

<!-- 관리자 페이지 스타일시트 추가 -->
<link href="<%= root %>/css/admin.css" rel="stylesheet">

<div class="admin-container">
    <div class="admin-header">
        <h1><i class="fas fa-flag"></i> 신고된 게시물 관리</h1>
    </div>
    
    <% if(reportedPosts.isEmpty()) { %>
        <div class="empty-state">
            <i class="fas fa-inbox"></i>
            <h3>신고된 게시물이 없습니다</h3>
            <p>현재 신고된 게시물이 없습니다.</p>
        </div>
    <% } else { %>
        <% for(int i = 0; i < reportedPosts.size(); i++) { 
            HpostDto post = reportedPosts.get(i);
            int reportCount = reportDao.getReportCountByPostId(post.getId());
            List<Hottalk_ReportDto> reports = reportDao.getReportsByPostId(post.getId());
        %>
            <div class="post-card">
                <div class="post-header">
                    <div class="post-info">
                        <div class="post-title"><%= post.getTitle() %></div>
                        <div class="post-meta">
                            <span><i class="fas fa-user"></i> <%= post.getUserid() %></span>
                            <span><i class="fas fa-calendar"></i> <%= post.getCreated_at() %></span>
                            <span><i class="fas fa-eye"></i> <%= post.getViews() %></span>
                        </div>
                        <div class="post-stats">
                            <span><i class="fas fa-thumbs-up"></i> <%= post.getLikes() %></span>
                            <span><i class="fas fa-thumbs-down"></i> <%= post.getDislikes() %></span>
                            <span class="report-count"><i class="fas fa-flag"></i> <%= reportCount %>건 신고</span>
                            <button class="btn-delete-inline" onclick="deletePost(<%= post.getId() %>)" title="게시글 삭제">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                    <button class="toggle-btn" onclick="toggleReports(<%= i %>)">
                        <i class="fas fa-chevron-down" id="icon-<%= i %>"></i>
                    </button>
                </div>
                
                <div class="report-details" id="reports-<%= i %>">
                    <h6 style="margin-bottom: 12px; color: #666;">신고 내역</h6>
                    <% for(Hottalk_ReportDto report : reports) { %>
                        <div class="report-item">
                            <div class="report-header">
                                <span class="report-reason"><%= report.getReason() %></span>
                                <span class="report-time"><%= report.getReport_time() %></span>
                            </div>
                            <div class="report-content">
                                <%= report.getContent() != null ? report.getContent() : "내용 없음" %>
                            </div>
                            <div style="font-size: 12px; color: #999; margin-top: 8px;">
                                신고자: <%= report.getUser_id() %>
                            </div>
                        </div>
                    <% } %>
                    
                    <div class="action-buttons">
                        <a href="<%= root %>/index.jsp?main=community/hpost_detail.jsp?id=<%= post.getId() %>" 
                           class="btn-view" target="_blank">
                            <i class="fas fa-external-link-alt"></i> 게시글 보기
                        </a>
                    </div>
                </div>
            </div>
        <% } %>
    <% } %>
</div>

<script>
    function toggleReports(index) {
        const details = document.getElementById('reports-' + index);
        const icon = document.getElementById('icon-' + index);
        
        if (details.style.display === 'none' || details.style.display === '') {
            details.style.display = 'block';
            icon.className = 'fas fa-chevron-up';
        } else {
            details.style.display = 'none';
            icon.className = 'fas fa-chevron-down';
        }
    }
    
    function deletePost(postId) {
        if (confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
            fetch('<%= root %>/adminpage/deletePostAction.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'postId=' + postId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert(data.message);
                    location.reload();
                } else {
                    alert(data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('게시글 삭제 중 오류가 발생했습니다.');
            });
        }
    }
</script>