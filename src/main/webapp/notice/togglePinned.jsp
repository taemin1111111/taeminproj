<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Notice.*" %>
<%
  request.setCharacterEncoding("UTF-8");
  String root = request.getContextPath();
  String provider = (String)session.getAttribute("provider");

  if (!"admin".equals(provider)) {
    out.println("<script>location.href='" + root + "/index.jsp?main=notice/noticemain.jsp';</script>");
    return;
  }

  try {
    int id = Integer.parseInt(request.getParameter("id"));
    NoticeDao dao = new NoticeDao();
    dao.togglePinned(id);
    out.println("<script>alert('고정 상태가 변경되었습니다.'); location.href='" + root + "/index.jsp?main=notice/noticemain.jsp';</script>");
  } catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('오류가 발생했습니다.'); location.href='" + root + "/index.jsp?main=notice/noticemain.jsp';</script>");
  }
%>
