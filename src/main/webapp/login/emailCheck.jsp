<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Member.MemberDAO" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    String email = request.getParameter("email");
    
    if (email == null || email.trim().isEmpty()) {
        out.print("error");
        return;
    }
    
    MemberDAO dao = new MemberDAO();
    boolean isDuplicate = dao.isDuplicateEmail(email.trim());
    
    if (isDuplicate) {
        out.print("duplicate");
    } else {
        out.print("ok");
    }
%> 