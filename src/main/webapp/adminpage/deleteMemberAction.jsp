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
        
    if(userid == null || userid.trim().isEmpty()) {
        out.print("{\"success\": false, \"message\": \"회원 ID가 필요합니다.\"}");
        return;
    }
    
    // admin 계정 삭제 방지
    if("admin".equals(userid)) {
        out.print("{\"success\": false, \"message\": \"관리자 계정은 삭제할 수 없습니다.\"}");
        return;
    }
    
    try {
        MemberDAO memberDAO = new MemberDAO();
        
        // 삭제 전에 해당 회원이 존재하는지 확인
        boolean memberExists = memberDAO.isDuplicateId(userid);
        
        if (!memberExists) {
            out.print("{\"success\": false, \"message\": \"해당 회원이 존재하지 않습니다.\"}");
            return;
        }
        
        boolean success = memberDAO.deleteMember(userid);
            
        if(success) {
            out.print("{\"success\": true, \"message\": \"회원이 성공적으로 삭제되었습니다.\"}");
        } else {
            out.print("{\"success\": false, \"message\": \"회원 삭제에 실패했습니다.\"}");
        }
        
    } catch(Exception e) {
        e.printStackTrace();
        out.print("{\"success\": false, \"message\": \"서버 오류가 발생했습니다: " + e.getMessage() + "\"}");
    }
%>
