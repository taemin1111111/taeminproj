<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hottalk_report.Hottalk_ReportDao" %>
<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String loginId = (String)session.getAttribute("loginid");
String provider = (String)session.getAttribute("provider");

// 관리자 권한 확인
if(loginId == null || !"admin".equals(provider)) {
    out.print("{\"success\":false,\"message\":\"관리자 권한이 필요합니다.\"}");
    return;
}

String postIdStr = request.getParameter("postId");
if(postIdStr == null || postIdStr.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"게시글 ID가 필요합니다.\"}");
    return;
}

try {
    int postId = Integer.parseInt(postIdStr);
    
    HpostDao postDao = new HpostDao();
    Hottalk_ReportDao reportDao = new Hottalk_ReportDao();
    
    // 게시글 삭제
    boolean deleteSuccess = postDao.deletePost(postId);
    
    if(deleteSuccess) {
        // 해당 게시글의 신고 기록도 삭제
        // (선택사항: 신고 기록을 보관하고 싶다면 이 부분을 주석 처리)
        // reportDao.deleteReportsByPostId(postId);
        
        out.print("{\"success\":true,\"message\":\"게시글이 성공적으로 삭제되었습니다.\"}");
    } else {
        out.print("{\"success\":false,\"message\":\"게시글 삭제에 실패했습니다.\"}");
    }
    
} catch (NumberFormatException e) {
    out.print("{\"success\":false,\"message\":\"잘못된 게시글 ID입니다.\"}");
} catch (Exception e) {
    e.printStackTrace();
    out.print("{\"success\":false,\"message\":\"게시글 삭제 중 오류가 발생했습니다.\"}");
}
%> 