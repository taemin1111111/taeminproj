<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Notice.*" %>
<%
  request.setCharacterEncoding("UTF-8");
  String root = request.getContextPath();
  String provider = (String)session.getAttribute("provider");
  String returnPage = request.getParameter("return");
  if (returnPage == null || returnPage.trim().isEmpty()) returnPage = "notice/noticemain.jsp";

  if (!"admin".equals(provider)) {
    response.sendRedirect(root + "/index.jsp?main=" + returnPage);
    return;
  }

  try {
    int id = Integer.parseInt(request.getParameter("id"));
    new NoticeDao().deleteNotice(id);
  } catch (Exception ignore) { }

  response.sendRedirect(root + "/index.jsp?main=" + returnPage);
%>
