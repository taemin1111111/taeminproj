<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%
    // 세션 초기화 (로그아웃)
    session.invalidate();

    // 메인페이지로 이동
    response.sendRedirect(request.getContextPath() + "/index.jsp");
%>
