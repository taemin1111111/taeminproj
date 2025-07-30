<%@page import="hpost.HpostDto"%>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hottalk_report.Hottalk_ReportDao" %>
<%@ page import="hottalk_report.Hottalk_ReportDto" %>
<%@ page import="hottalk_vote.HottalkVoteDao" %>

<%@ page import="hottalk_vote.HottalkVoteDto" %>

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
HottalkVoteDao voteDao = new HottalkVoteDao();
response.setContentType("application/json; charset=UTF-8");

if ("view".equals(action)) {
    boolean success = dao.increaseViews(id);
    if (success) {
        out.print("{\"success\":true}");
    } else {
        out.print("{\"success\":false,\"error\":\"조회수 증가 실패\"}");
    }
} else if ("like".equals(action)) {
    // 사용자 ID 가져오기 (로그인된 경우 loginid, 비로그인 경우 IP)
    String userid = (String)session.getAttribute("loginid");
    if (userid == null || userid.trim().isEmpty()) {
        userid = request.getRemoteAddr();
    }
    
    // 기존 투표 확인
    HottalkVoteDto existingVote = voteDao.getVoteByUserAndPost(id, userid);
    
    if (existingVote == null) {
        // 처음 투표하는 경우
        HottalkVoteDto newVote = new HottalkVoteDto(id, userid, "like");
        boolean success = voteDao.insertVote(newVote);
        if (success) {
            // 게시글 테이블 likes +1
            dao.increaseLikes(id);
            // 게시글 테이블에서 업데이트된 수 가져오기
            HpostDto updatedPost = dao.getPostById(id);
            out.print("{\"success\":true,\"likes\":" + updatedPost.getLikes() + ",\"dislikes\":" + updatedPost.getDislikes() + ",\"action\":\"added\"}");
        } else {
            out.print("{\"success\":false,\"error\":\"좋아요 추가 실패\"}");
        }
    } else if ("like".equals(existingVote.getVote_type())) {
        // 이미 좋아요를 누른 경우 - 취소
        boolean success = voteDao.deleteVote(id, userid);
        if (success) {
            // 게시글 테이블 likes -1
            dao.decreaseLikes(id);
            // 게시글 테이블에서 업데이트된 수 가져오기
            HpostDto updatedPost = dao.getPostById(id);
            out.print("{\"success\":true,\"likes\":" + updatedPost.getLikes() + ",\"dislikes\":" + updatedPost.getDislikes() + ",\"action\":\"removed\"}");
        } else {
            out.print("{\"success\":false,\"error\":\"좋아요 취소 실패\"}");
        }
    } else {
        // 싫어요를 누른 경우 - 좋아요로 변경
        boolean success = voteDao.updateVote(id, userid, "like");
        if (success) {
            // 게시글 테이블 likes +1, dislikes -1
            dao.increaseLikes(id);
            dao.decreaseDislikes(id);
            // 게시글 테이블에서 업데이트된 수 가져오기
            HpostDto updatedPost = dao.getPostById(id);
            out.print("{\"success\":true,\"likes\":" + updatedPost.getLikes() + ",\"dislikes\":" + updatedPost.getDislikes() + ",\"action\":\"changed\"}");
        } else {
            out.print("{\"success\":false,\"error\":\"투표 변경 실패\"}");
        }
    }
} else if ("dislike".equals(action)) {
    // 사용자 ID 가져오기 (로그인된 경우 loginid, 비로그인 경우 IP)
    String userid = (String)session.getAttribute("loginid");
    if (userid == null || userid.trim().isEmpty()) {
        userid = request.getRemoteAddr();
    }
    
    // 기존 투표 확인
    HottalkVoteDto existingVote = voteDao.getVoteByUserAndPost(id, userid);
    
    if (existingVote == null) {
        // 처음 투표하는 경우
        HottalkVoteDto newVote = new HottalkVoteDto(id, userid, "dislike");
        boolean success = voteDao.insertVote(newVote);
        if (success) {
            // 게시글 테이블 dislikes +1
            dao.increaseDislikes(id);
            // 게시글 테이블에서 업데이트된 수 가져오기
            HpostDto updatedPost = dao.getPostById(id);
            out.print("{\"success\":true,\"likes\":" + updatedPost.getLikes() + ",\"dislikes\":" + updatedPost.getDislikes() + ",\"action\":\"added\"}");
        } else {
            out.print("{\"success\":false,\"error\":\"싫어요 추가 실패\"}");
        }
    } else if ("dislike".equals(existingVote.getVote_type())) {
        // 이미 싫어요를 누른 경우 - 취소
        boolean success = voteDao.deleteVote(id, userid);
        if (success) {
            // 게시글 테이블 dislikes -1
            dao.decreaseDislikes(id);
            // 게시글 테이블에서 업데이트된 수 가져오기
            HpostDto updatedPost = dao.getPostById(id);
            out.print("{\"success\":true,\"likes\":" + updatedPost.getLikes() + ",\"dislikes\":" + updatedPost.getDislikes() + ",\"action\":\"removed\"}");
        } else {
            out.print("{\"success\":false,\"error\":\"싫어요 취소 실패\"}");
        }
    } else {
        // 좋아요를 누른 경우 - 싫어요로 변경
        boolean success = voteDao.updateVote(id, userid, "dislike");
        if (success) {
            // 게시글 테이블 dislikes +1, likes -1
            dao.increaseDislikes(id);
            dao.decreaseLikes(id);
            // 게시글 테이블에서 업데이트된 수 가져오기
            HpostDto updatedPost = dao.getPostById(id);
            out.print("{\"success\":true,\"likes\":" + updatedPost.getLikes() + ",\"dislikes\":" + updatedPost.getDislikes() + ",\"action\":\"changed\"}");
        } else {
            out.print("{\"success\":false,\"error\":\"투표 변경 실패\"}");
        }
    }
} else if ("checkReport".equals(action)) {
    // 신고 상태 확인
    String user_id = (String)session.getAttribute("loginid");
    if (user_id == null || user_id.trim().isEmpty()) {
        out.print("{\"alreadyReported\":false,\"error\":\"로그인 후 이용해 주세요.\"}");
        return;
    }
    boolean alreadyReported = reportDao.hasUserReported(id, user_id);
    out.print("{\"alreadyReported\":" + alreadyReported + "}");
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