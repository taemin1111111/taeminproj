<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="Member.MemberDAO" %>
<%@ page import="Member.MemberDTO" %>

<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String loginId = (String)session.getAttribute("loginid");
String currentPassword = request.getParameter("currentPassword");

// 로그인하지 않은 경우
if(loginId == null) {
    out.print("{\"result\":false,\"message\":\"로그인이 필요합니다.\"}");
    return;
}

// 현재 비밀번호가 입력되지 않은 경우
if(currentPassword == null || currentPassword.trim().isEmpty()) {
    out.print("{\"result\":false,\"message\":\"현재 비밀번호를 입력해주세요.\"}");
    return;
}

try {
    MemberDAO memberDao = new MemberDAO();
    MemberDTO member = memberDao.getMember(loginId);
    
    if(member == null) {
        out.print("{\"result\":false,\"message\":\"회원 정보를 찾을 수 없습니다.\"}");
        return;
    }
    
    // 현재 비밀번호 확인 (평문 비교)
    if(currentPassword.equals(member.getPasswd())) {
        out.print("{\"result\":true,\"message\":\"현재 비밀번호가 확인되었습니다.\"}");
    } else {
        out.print("{\"result\":false,\"message\":\"현재 비밀번호가 일치하지 않습니다.\"}");
    }
    
} catch (Exception e) {
    System.out.println("현재 비밀번호 확인 중 오류: " + e.getMessage());
    e.printStackTrace();
    out.print("{\"result\":false,\"message\":\"비밀번호 확인 중 오류가 발생했습니다.\"}");
}
%> 