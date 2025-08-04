<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="Member.MemberDAO" %>
<%@ page import="Member.MemberDTO" %>

<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String loginId = (String)session.getAttribute("loginid");
String nickname = request.getParameter("nickname");

if(loginId == null) {
    out.print("{\"result\":false,\"message\":\"로그인이 필요합니다.\"}");
    return;
}

if(nickname == null || nickname.trim().isEmpty()) {
    out.print("{\"result\":false,\"message\":\"닉네임을 입력해주세요.\"}");
    return;
}

// 관리자 닉네임 제한
if(nickname.trim().toLowerCase().contains("관리자")) {
    out.print("{\"result\":false,\"message\":\"'관리자'가 포함된 닉네임은 사용할 수 없습니다.\"}");
    return;
}

try {
    MemberDAO memberDao = new MemberDAO();
    MemberDTO member = memberDao.getMember(loginId);
    
    if (member == null) {
        out.print("{\"result\":false,\"message\":\"회원 정보를 찾을 수 없습니다.\"}");
        return;
    }
    
    // 현재 닉네임과 같은 경우 중복이 아님
    if (nickname.equals(member.getNickname())) {
        out.print("{\"result\":true,\"message\":\"사용 가능한 닉네임입니다.\"}");
        return;
    }
    
    // 닉네임 중복 확인
    if (memberDao.isDuplicateNickname(nickname)) {
        out.print("{\"result\":false,\"message\":\"이미 사용 중인 닉네임입니다.\"}");
    } else {
        out.print("{\"result\":true,\"message\":\"사용 가능한 닉네임입니다.\"}");
    }
    
} catch (Exception e) {
    e.printStackTrace();
    out.print("{\"result\":false,\"message\":\"닉네임 확인 중 오류가 발생했습니다.\"}");
}
%> 