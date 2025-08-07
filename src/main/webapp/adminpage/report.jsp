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

<div class="report-admin-container">
    <div class="report-admin-header">
        <h1><i class="fas fa-flag"></i> 신고된 게시물 관리</h1>
    </div>
    
    <% if(reportedPosts.isEmpty()) { %>
        <div class="report-admin-empty-state">
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
            <div class="report-admin-post-card">
                <div class="report-admin-post-info">
                    <div class="report-admin-user-info">
                        <% if(post.getUserid().equals("admin")) { %>
                            WW <%= post.getUserid() %>
                        <% } else if(post.getUserid().length() > 20) { %>
                            WWW <%= post.getUserid() %>
                        <% } else { %>
                            WW <%= post.getUserid() %>
                        <% } %>
                    </div>
                    <div class="report-admin-timestamp">
                        <%= post.getCreated_at() %>
                    </div>
                    <div class="report-admin-stats">
                        <span><%= post.getViews() %></span>
                        <span><%= post.getLikes() %></span>
                        <span><%= post.getDislikes() %></span>
                    </div>
                    <div class="report-admin-report-count">
                        <%= reportCount %>건 신고
                    </div>
                    <div class="report-admin-red-bar"></div>
                </div>
                <button class="report-admin-btn-delete-inline" onclick="deletePost(<%= post.getId() %>)" title="게시글 삭제">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        <% } %>
    <% } %>
</div>

<script>
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