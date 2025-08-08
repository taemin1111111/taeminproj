<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Notice.*" %>
<%
  request.setCharacterEncoding("UTF-8");
  String root = request.getContextPath();
  String loginProvider = (String)session.getAttribute("provider");
  
  int noticeId = 0;
  try {
    noticeId = Integer.parseInt(request.getParameter("id"));
  } catch (Exception e) {
    response.sendRedirect(root + "/index.jsp?main=notice/noticemain.jsp");
    return;
  }
  
  NoticeDao dao = new NoticeDao();
  NoticeDto notice = dao.getNoticeById(noticeId);
  
  if (notice == null) {
    response.sendRedirect(root + "/index.jsp?main=notice/noticemain.jsp");
    return;
  }
%>

<div class="notice-detail-container">
  <div class="notice-detail-header">
    <div class="card-header">
      <div class="d-flex justify-content-between align-items-center">
        <h5 class="notice-detail-title">
          <% if (notice.isPinned()) { %>
            <span class="pinned-badge me-2">고정</span>
          <% } %>
          <%= notice.getTitle() %>
        </h5>
        <small>
          📅 <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(notice.getCreatedAt()) %>
        </small>
      </div>
      <div class="notice-detail-meta">
        <span>👤 작성자: <%= notice.getWriter() %></span>
        <span>👁️ 조회수: <%= notice.getViewCount() %></span>
      </div>
    </div>
    
    <div class="notice-detail-body">
      <% if (notice.getPhoto() != null && notice.getPhoto().trim().length() > 0) { %>
        <div class="notice-detail-image">
          <img src="<%=root%>/noticephoto/<%= notice.getPhoto() %>" 
               alt="첨부 이미지" class="img-fluid">
        </div>
      <% } %>
      
      <div class="notice-detail-content">
        <%= notice.getContent() %>
      </div>
      
      <div class="notice-detail-actions">
        <a href="<%=root%>/index.jsp?main=notice/noticemain.jsp" class="btn btn-outline-secondary">📋 목록으로</a>
        <% if ("admin".equals(loginProvider)) { %>
          <a href="<%=root%>/notice/delete.jsp?id=<%=notice.getNoticeId()%>&return=noticemain.jsp" 
             class="btn btn-outline-danger" onclick="return confirm('삭제하시겠습니까?');">🗑️ 삭제</a>
        <% } %>
      </div>
    </div>
  </div>
</div>
