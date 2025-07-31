<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="EmailVerification.*" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.util.Random" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    
    String email = request.getParameter("email");
    String ipAddress = request.getRemoteAddr();
    
    EmailVerificationDAO dao = new EmailVerificationDAO();
    
    // 입력값 검증
    if (email == null || email.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"이메일을 입력해주세요.\"}");
        return;
    }
    
    // 이메일 형식 검증
    if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
        out.print("{\"success\":false,\"message\":\"올바른 이메일 형식이 아닙니다.\"}");
        return;
    }
    
    // 중복 요청 방지 (1분 내 재요청 차단)
    if (dao.hasRecentVerification(email)) {
        out.print("{\"success\":false,\"message\":\"1분 후에 다시 시도해주세요.\"}");
        return;
    }
    
    try {
        // 6자리 랜덤 인증번호 생성
        Random random = new Random();
        String verificationCode = String.format("%06d", random.nextInt(1000000));
        
        // 만료 시간 설정 (10분 후)
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(10);
        
        // DTO 생성
        EmailVerificationDTO dto = new EmailVerificationDTO();
        dto.setEmail(email);
        dto.setVerificationCode(verificationCode);
        dto.setExpiresAt(expiresAt);
        dto.setIpAddress(ipAddress);
        
        // DB에 저장
        boolean saved = dao.insertVerification(dto);
        if (!saved) {
            out.print("{\"success\":false,\"message\":\"인증번호 저장에 실패했습니다.\"}");
            return;
        }
        
        // 이메일 발송 (실제 발송)
        boolean sent = EmailSender.sendVerificationEmail(email, verificationCode);
        if (sent) {
            out.print("{\"success\":true,\"message\":\"인증번호가 발송되었습니다.\"}");
        } else {
            out.print("{\"success\":false,\"message\":\"이메일 발송에 실패했습니다.\"}");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\":false,\"message\":\"오류가 발생했습니다: " + e.getMessage() + "\"}");
    }
%> 