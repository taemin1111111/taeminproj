<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="EmailVerification.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    
    String email = request.getParameter("email");
    String code = request.getParameter("code");
    
    EmailVerificationDAO dao = new EmailVerificationDAO();
    
    // 입력값 검증
    if (email == null || email.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"이메일을 입력해주세요.\"}");
        return;
    }
    
    if (code == null || code.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"인증번호를 입력해주세요.\"}");
        return;
    }
    
    // 인증번호 형식 검증 (6자리 숫자)
    if (!code.matches("^\\d{6}$")) {
        out.print("{\"success\":false,\"message\":\"6자리 숫자를 입력해주세요.\"}");
        return;
    }
    
    try {
        // 인증번호 확인
        boolean verified = dao.verifyCode(email, code);
        
        if (verified) {
            out.print("{\"success\":true,\"message\":\"이메일 인증이 완료되었습니다.\"}");
        } else {
            // 실패 원인 확인
            EmailVerificationDTO latestVerification = dao.getLatestVerificationByEmail(email);
            
            if (latestVerification == null) {
                out.print("{\"success\":false,\"message\":\"인증번호를 먼저 발송해주세요.\"}");
            } else if (latestVerification.isVerified()) {
                out.print("{\"success\":false,\"message\":\"이미 인증이 완료된 이메일입니다.\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"인증번호가 올바르지 않거나 만료되었습니다.\"}");
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\":false,\"message\":\"오류가 발생했습니다: " + e.getMessage() + "\"}");
    }
%> 