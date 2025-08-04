<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="Member.MemberDAO" %>
<%@ page import="Member.MemberDTO" %>

<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String loginId = (String)session.getAttribute("loginid");
String nickname = request.getParameter("nickname");
String currentPassword = request.getParameter("currentPassword");
String newPassword = request.getParameter("newPassword");

// 디버깅을 위한 로그 출력
System.out.println("=== Profile Update Debug ===");
System.out.println("loginId: " + loginId);
System.out.println("nickname: " + nickname);
System.out.println("currentPassword: " + (currentPassword != null ? "입력됨" : "null"));
System.out.println("newPassword: " + (newPassword != null ? "입력됨" : "null"));
System.out.println("==========================");

// 로그인하지 않은 경우
if(loginId == null) {
    out.print("{\"result\":false,\"message\":\"로그인이 필요합니다.\"}");
    return;
}

// 닉네임이 입력되지 않은 경우
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
    
    if(member == null) {
        out.print("{\"result\":false,\"message\":\"회원 정보를 찾을 수 없습니다.\"}");
        return;
    }
    
         // 네이버 로그인 사용자인지 확인
     boolean isNaverUser = "naver".equals(member.getProvider());
     
            // 일반 사용자만 현재 비밀번호 확인 필요
       if (!isNaverUser && (currentPassword == null || currentPassword.trim().isEmpty())) {
           out.print("{\"result\":false,\"message\":\"현재 비밀번호를 입력해주세요.\"}");
           return;
       }
       
       // 일반 사용자의 경우 현재 비밀번호 검증
       if (!isNaverUser && !currentPassword.equals(member.getPasswd())) {
           out.print("{\"result\":false,\"message\":\"현재 비밀번호가 일치하지 않습니다.\"}");
           return;
       }
     
     // 일반 사용자의 경우 새 비밀번호가 입력된 경우 유효성 검사
     if (!isNaverUser && newPassword != null && !newPassword.trim().isEmpty()) {
         String passwordRegex = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\[\\]{};':\"\\\\|,.<>\\/?]).{10,}$";
         if (!newPassword.matches(passwordRegex)) {
             out.print("{\"result\":false,\"message\":\"새 비밀번호는 10자 이상, 영문+숫자+특수문자 포함이어야 합니다.\"}");
             return;
         }
     }
    
    // 닉네임 중복 확인 (현재 닉네임과 다른 경우에만)
    if (!nickname.equals(member.getNickname())) {
        if (memberDao.isDuplicateNickname(nickname)) {
            out.print("{\"result\":false,\"message\":\"이미 사용 중인 닉네임입니다.\"}");
            return;
        }
    }
    
    // 프로필 업데이트
    boolean updateResult = false;
    if (isNaverUser) {
        // 네이버 사용자는 닉네임만 업데이트
        updateResult = memberDao.updateNickname(loginId, nickname);
    } else {
        // 일반 사용자는 닉네임과 비밀번호 업데이트
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            updateResult = memberDao.updateProfile(loginId, nickname, newPassword);
        } else {
            updateResult = memberDao.updateNickname(loginId, nickname);
        }
    }
    
    if (updateResult) {
        // 세션의 닉네임 업데이트
        session.setAttribute("nickname", nickname);
        out.print("{\"result\":true,\"message\":\"정보가 성공적으로 수정되었습니다.\"}");
    } else {
        out.print("{\"result\":false,\"message\":\"정보 수정에 실패했습니다.\"}");
    }
    
} catch (Exception e) {
    System.out.println("프로필 업데이트 중 오류: " + e.getMessage());
    e.printStackTrace();
    out.print("{\"result\":false,\"message\":\"정보 수정 중 오류가 발생했습니다.\"}");
}
%> 