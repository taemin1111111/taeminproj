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

  try {
    // 파일 업로드 설정
    String uploadPath = application.getRealPath("/noticephoto");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
      uploadDir.mkdirs();
    }
    
    int maxSize = 10 * 1024 * 1024; // 10MB
    MultipartRequest multi = new MultipartRequest(request, uploadPath, maxSize, "UTF-8", new DefaultFileRenamePolicy());
    
    String title = multi.getParameter("title");
    String content = multi.getParameter("content");
    String writer = (String)session.getAttribute("nickname");
    if (writer == null || writer.trim().isEmpty()) {
      writer = (String)session.getAttribute("loginid");
    }
    boolean pinned = "on".equals(multi.getParameter("pinned"));
    
    // 파일 처리
    String photo = null;
    File file = multi.getFile("photo");
    if (file != null && file.exists()) {
      photo = file.getName();
    }

    NoticeDto dto = new NoticeDto();
    dto.setTitle(title);
    dto.setContent(content);
    dto.setWriter(writer == null ? "admin" : writer);
    dto.setPinned(pinned);
    dto.setPhoto(photo);
    dto.setViewCount(0);
    dto.setActive(true);

    new NoticeDao().insertNotice(dto);
    
    // 성공 시 리다이렉트
    response.sendRedirect(root + "/index.jsp?main=notice/noticemain.jsp");
    
  } catch (Exception e) {
    // 오류 발생 시에도 리다이렉트
    e.printStackTrace();
    response.sendRedirect(root + "/index.jsp?main=notice/noticemain.jsp");
  }
%>
