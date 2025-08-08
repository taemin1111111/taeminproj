<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Notice.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%
  request.setCharacterEncoding("UTF-8");
  String root = request.getContextPath();
  String loginProvider = (String)session.getAttribute("provider");
  if (!"admin".equals(loginProvider)) {
    response.sendRedirect(root + "/index.jsp?main=notice/noticemain.jsp");
    return;
  }


%>

<div class="notice-form-container">
  <div class="notice-form-card">
    <h3 class="notice-form-title">📝 공지사항 등록</h3>

    <form method="post" action="<%=root%>/notice/noticeAction.jsp" enctype="multipart/form-data" class="notice-form">
      <div class="mb-4">
        <label class="form-label">📌 제목</label>
        <input type="text" name="title" class="form-control" placeholder="공지사항 제목을 입력하세요" required>
      </div>

      <div class="mb-4">
        <label class="form-label">📄 내용</label>
        <textarea name="content" class="form-control" rows="12" placeholder="공지사항 내용을 입력하세요" required></textarea>
      </div>

      <div class="mb-4">
        <label class="form-label">🖼️ 첨부 사진</label>
        <input type="file" name="photo" class="form-control" accept="image/*">
        <small class="text-muted">이미지 파일만 업로드 가능합니다. (최대 10MB)</small>
      </div>

      <div class="form-check mb-4">
        <input class="form-check-input" type="checkbox" id="pinned" name="pinned">
        <label class="form-check-label" for="pinned">📌 상단 고정</label>
      </div>

      <div class="d-flex gap-3">
        <button type="submit" class="btn btn-primary">✅ 등록하기</button>
        <a href="<%=root%>/index.jsp?main=notice/noticemain.jsp" class="btn btn-outline-secondary">📋 목록으로</a>
      </div>
    </form>
  </div>
</div>
