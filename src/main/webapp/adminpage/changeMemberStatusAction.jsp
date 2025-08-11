<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="Member.MemberDAO" %>
<%
    // 관리자 권한 확인
    String provider = (String)session.getAttribute("provider");
        
    if(provider == null || !"admin".equals(provider)) {
        out.print("{\"success\": false, \"message\": \"권한이 없습니다.\"}");
        return;
    }
    
    // POST 요청 확인
    String method = request.getMethod();
        
    if(!"POST".equals(method)) {
        out.print("{\"success\": false, \"message\": \"잘못된 요청 방식입니다.\"}");
        return;
    }
    
    // 요청 파라미터 받기
    String userid = request.getParameter("userid");
    String status = request.getParameter("status");
        
    if(userid == null || userid.trim().isEmpty() || status == null || status.trim().isEmpty()) {
        out.print("{\"success\": false, \"message\": \"회원 ID와 상태가 필요합니다.\"}");
        return;
    }
    
    // admin 계정 상태 변경 방지
    if("admin".equals(userid)) {
        out.print("{\"success\": false, \"message\": \"관리자 계정의 상태는 변경할 수 없습니다.\"}");
        return;
    }
    
    // 상태 값 유효성 검사
    if(!status.equals("A") && !status.equals("B") && !status.equals("C")) {
        out.print("{\"success\": false, \"message\": \"잘못된 상태 값입니다.\"}");
        return;
    }
    
    try {
        MemberDAO memberDAO = new MemberDAO();
        
        // 상태 변경 실행
        boolean success = memberDAO.updateMemberStatus(userid, status);
            
        if(success) {
            String statusText = "";
            switch(status) {
                case "A": statusText = "활성"; break;
                case "B": statusText = "경고"; break;
                case "C": statusText = "정지"; break;
            }
            out.print("{\"success\": true, \"message\": \"회원 상태가 '" + statusText + "'으로 성공적으로 변경되었습니다.\"}");
        } else {
            out.print("{\"success\": false, \"message\": \"회원 상태 변경에 실패했습니다.\"}");
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        out.print("{\"success\": false, \"message\": \"서버 오류가 발생했습니다: " + e.getMessage() + "\"}");
    }
%>
