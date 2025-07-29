<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hottalk_report.Hottalk_ReportDao" %>
<%@ page import="hottalk_report.Hottalk_ReportDto" %>
<%@ page import="java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");

// 모든 파라미터 로그 출력

String action = request.getParameter("action");
String idStr = request.getParameter("id");

int id = 0;
if (idStr != null && !idStr.isEmpty()) {
    id = Integer.parseInt(idStr);
}

HpostDao dao = new HpostDao();
Hottalk_ReportDao reportDao = new Hottalk_ReportDao();
response.setContentType("application/json; charset=UTF-8");

if ("view".equals(action)) {
    boolean success = dao.increaseViews(id);
    if (success) {
        out.print("{\"success\":true}");
    } else {
        out.print("{\"success\":false,\"error\":\"조회수 증가 실패\"}");
    }
} else if ("like".equals(action)) {
    boolean success = dao.increaseLikes(id);
    if (success) {
        HpostDao dao2 = new HpostDao();
        int likes = dao2.getPostById(id).getLikes();
        out.print("{\"success\":true,\"likes\":" + likes + "}");
    } else {
        out.print("{\"success\":false,\"error\":\"좋아요 증가 실패\"}");
    }
} else if ("dislike".equals(action)) {
    boolean success = dao.increaseDislikes(id);
    if (success) {
        HpostDao dao2 = new HpostDao();
        int dislikes = dao2.getPostById(id).getDislikes();
        out.print("{\"success\":true,\"dislikes\":" + dislikes + "}");
    } else {
        out.print("{\"success\":false,\"error\":\"싫어요 증가 실패\"}");
    }
} else if ("report".equals(action)) {
    // 신고 정보 받기
    String reason = request.getParameter("reason");
    String detail = request.getParameter("detail");
    String user_id = (String)session.getAttribute("loginid");
    if (user_id == null || user_id.trim().isEmpty()) {
        out.print("{\"success\":false,\"error\":\"로그인 후 이용해 주세요.\"}");
        return;
    }
    if (reason == null || reason.trim().isEmpty()) {
        out.print("{\"success\":false,\"error\":\"신고 사유가 필요합니다.\"}");
        return;
    }
    // 중복 신고 체크
    if (reportDao.hasUserReported(id, user_id)) {
        out.print("{\"success\":false,\"error\":\"이미 신고하셨습니다.\"}");
        return;
    }
    try {
        // 신고 정보를 hottalk_report 테이블에 저장
        Hottalk_ReportDto reportDto = new Hottalk_ReportDto(id, user_id, reason, detail != null ? detail : "");
        boolean reportSuccess = reportDao.insertReport(reportDto);
        if (reportSuccess) {
            // hottalk_post 테이블의 reports 컬럼도 증가
            boolean postUpdateSuccess = dao.increaseReports(id);
            if (postUpdateSuccess) {
                out.print("{\"success\":true,\"message\":\"신고가 성공적으로 접수되었습니다.\"}");
            } else {
                out.print("{\"success\":true,\"message\":\"신고가 접수되었으나 게시글 업데이트에 실패했습니다.\"}");
            }
        } else {
            out.print("{\"success\":false,\"error\":\"신고 처리 실패\"}");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"success\":false,\"error\":\"신고 처리 중 오류가 발생했습니다.\"}");
    }
} else {
    out.print("{\"success\":false,\"error\":\"잘못된 액션\"}");
}
%> 