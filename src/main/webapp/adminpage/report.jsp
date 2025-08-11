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
    
%>

<%!
    // 신고 사유를 한글로 변환하는 함수
    public String getReasonInKorean(String reason) {
        if (reason == null || reason.trim().isEmpty()) return "기타";
        
        String lowerReason = reason.toLowerCase().trim();
        
        switch (lowerReason) {
            case "spam":
                return "스팸/광고성 글";
            case "inappropriate":
                return "부적절한 내용";
            case "abuse":
                return "욕설/비방";
            case "copyright":
                return "저작권 침해";
            case "other":
                return "기타";
            default:
                // 영어가 아닌 경우 원본 반환, 영어인 경우 "기타"로 표시
                boolean hasEnglish = false;
                for (char c : lowerReason.toCharArray()) {
                    if (Character.isLetter(c) && c <= 122) {
                        hasEnglish = true;
                        break;
                    }
                }
                return hasEnglish ? "기타" : reason;
        }
    }
%>

<%
    
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

<div class="taemin-container">
    <div class="taemin-header">
        <h1><i class="fas fa-flag"></i> 신고된 게시물 관리</h1>
    </div>
    
    <% if(reportedPosts.isEmpty()) { %>
        <div class="taemin-empty-state">
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
            <div class="taemin-post-card">
                <div class="taemin-post-info">
                    <div class="taemin-user-info">
                        <% if(post.getUserid().equals("admin")) { %>
                            WW <%= post.getUserid() %>
                        <% } else if(post.getUserid().length() > 20) { %>
                            WWW <%= post.getUserid() %>
                        <% } else { %>
                            WW <%= post.getUserid() %>
                        <% } %>
                    </div>
                    <div class="taemin-timestamp">
                        <%= post.getCreated_at() %>
                    </div>
                    <div class="taemin-stats">
                        <span class="taemin-stat-item" title="조회수">👁️ <%= post.getViews() %></span>
                        <span class="taemin-stat-item" title="좋아요">👍 <%= post.getLikes() %></span>
                        <span class="taemin-stat-item" title="싫어요">👎 <%= post.getDislikes() %></span>
                    </div>
                    <div class="taemin-report-badge">
                        <%= reportCount %>건 신고
                    </div>
                </div>
                <div class="taemin-actions">
                    <button class="taemin-toggle-btn" onclick="toggleReportDetails(<%= post.getId() %>)" title="신고 상세 보기">
                        <span id="icon-<%= post.getId() %>">▼</span>
                    </button>
                    <button class="taemin-delete-btn" onclick="deletePost(<%= post.getId() %>)" title="게시글 삭제">
                        🗑️ 삭제
                    </button>
                </div>
            </div>
            
            <!-- 신고 상세 정보 드롭다운 -->
            <div class="taemin-details" id="details-<%= post.getId() %>" style="display: none;">
                <% for(Hottalk_ReportDto report : reports) { %>
                    <div class="taemin-report-item">
                        <div class="taemin-report-header">
                            <span class="taemin-report-reason"><%= getReasonInKorean(report.getReason()) %></span>
                            <span class="taemin-report-time"><%= report.getReport_time() %></span>
                        </div>
                        <div class="taemin-report-content">
                            <% if(report.getContent() != null) { %>
                                <%= report.getContent() %>
                            <% } else { %>
                                신고 내용 없음
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    <% } %>
</div>

<script>
    function toggleReportDetails(postId) {
        const detailsDiv = document.getElementById('details-' + postId);
        const icon = document.getElementById('icon-' + postId);
        
        if (detailsDiv.style.display === 'none') {
            detailsDiv.style.display = 'block';
            icon.textContent = '▲';
        } else {
            detailsDiv.style.display = 'none';
            icon.textContent = '▼';
        }
    }
    
    function deletePost(postId) {
        if (confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
            const url = '<%=root%>/adminpage/deletePostAction.jsp';
            fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
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