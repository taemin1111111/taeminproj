<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="hottalk_comment_vote.HottalkCommentVoteDao" %>
<%@ page import="hottalk_comment_vote.HottalkCommentVoteDto" %>
<%@ page import="hottalk_comment.Hottalk_CommentDao" %>
<%@ page import="hottalk_comment.Hottalk_CommentDto" %>
<%@ page import="java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");

String action = request.getParameter("action");
String commentIdStr = request.getParameter("comment_id");

int comment_id = 0;
if (commentIdStr != null && !commentIdStr.isEmpty()) {
    comment_id = Integer.parseInt(commentIdStr);
}

HottalkCommentVoteDao voteDao = new HottalkCommentVoteDao();
Hottalk_CommentDao commentDao = new Hottalk_CommentDao();
response.setContentType("application/json; charset=UTF-8");

if ("like".equals(action)) {
    // 사용자 ID 가져오기 (로그인된 경우 loginid, 비로그인 경우 IP)
    String userid = (String)session.getAttribute("loginid");
    String ip_address = null;
    
    if (userid == null || userid.trim().isEmpty()) {
        // 비로그인 사용자
        ip_address = request.getRemoteAddr();
        userid = null;
        
        // 기존 투표 확인 (IP 기반)
        HottalkCommentVoteDto existingVote = voteDao.getVoteByIpAndComment(comment_id, ip_address);
        
        if (existingVote == null) {
            // 처음 투표하는 경우
            HottalkCommentVoteDto newVote = HottalkCommentVoteDto.createForIp(comment_id, ip_address, "like");
            boolean success = voteDao.insertVote(newVote);
            if (success) {
                // 댓글 테이블 likes +1
                commentDao.increaseLikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"added\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"좋아요 추가 실패\"}");
            }
        } else if ("like".equals(existingVote.getVote_type())) {
            // 이미 좋아요를 누른 경우 - 취소
            boolean success = voteDao.deleteVoteByIp(comment_id, ip_address);
            if (success) {
                // 댓글 테이블 likes -1
                commentDao.decreaseLikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"removed\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"좋아요 취소 실패\"}");
            }
        } else {
            // 싫어요를 누른 경우 - 좋아요로 변경
            boolean success = voteDao.updateVoteByIp(comment_id, ip_address, "like");
            if (success) {
                // 댓글 테이블 likes +1, dislikes -1
                commentDao.increaseLikes(comment_id);
                commentDao.decreaseDislikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"changed\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"투표 변경 실패\"}");
            }
        }
    } else {
        // 로그인 사용자
        // 기존 투표 확인 (사용자 ID 기반)
        HottalkCommentVoteDto existingVote = voteDao.getVoteByUserAndComment(comment_id, userid);
        
        if (existingVote == null) {
            // 처음 투표하는 경우
            HottalkCommentVoteDto newVote = new HottalkCommentVoteDto(comment_id, userid, "like");
            boolean success = voteDao.insertVote(newVote);
            if (success) {
                // 댓글 테이블 likes +1
                commentDao.increaseLikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"added\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"좋아요 추가 실패\"}");
            }
        } else if ("like".equals(existingVote.getVote_type())) {
            // 이미 좋아요를 누른 경우 - 취소
            boolean success = voteDao.deleteVoteByUser(comment_id, userid);
            if (success) {
                // 댓글 테이블 likes -1
                commentDao.decreaseLikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"removed\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"좋아요 취소 실패\"}");
            }
        } else {
            // 싫어요를 누른 경우 - 좋아요로 변경
            boolean success = voteDao.updateVoteByUser(comment_id, userid, "like");
            if (success) {
                // 댓글 테이블 likes +1, dislikes -1
                commentDao.increaseLikes(comment_id);
                commentDao.decreaseDislikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"changed\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"투표 변경 실패\"}");
            }
        }
    }
} else if ("dislike".equals(action)) {
    // 사용자 ID 가져오기 (로그인된 경우 loginid, 비로그인 경우 IP)
    String userid = (String)session.getAttribute("loginid");
    String ip_address = null;
    
    if (userid == null || userid.trim().isEmpty()) {
        // 비로그인 사용자
        ip_address = request.getRemoteAddr();
        userid = null;
        
        // 기존 투표 확인 (IP 기반)
        HottalkCommentVoteDto existingVote = voteDao.getVoteByIpAndComment(comment_id, ip_address);
        
        if (existingVote == null) {
            // 처음 투표하는 경우
            HottalkCommentVoteDto newVote = HottalkCommentVoteDto.createForIp(comment_id, ip_address, "dislike");
            boolean success = voteDao.insertVote(newVote);
            if (success) {
                // 댓글 테이블 dislikes +1
                commentDao.increaseDislikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"added\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"싫어요 추가 실패\"}");
            }
        } else if ("dislike".equals(existingVote.getVote_type())) {
            // 이미 싫어요를 누른 경우 - 취소
            boolean success = voteDao.deleteVoteByIp(comment_id, ip_address);
            if (success) {
                // 댓글 테이블 dislikes -1
                commentDao.decreaseDislikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"removed\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"싫어요 취소 실패\"}");
            }
        } else {
            // 좋아요를 누른 경우 - 싫어요로 변경
            boolean success = voteDao.updateVoteByIp(comment_id, ip_address, "dislike");
            if (success) {
                // 댓글 테이블 dislikes +1, likes -1
                commentDao.increaseDislikes(comment_id);
                commentDao.decreaseLikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"changed\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"투표 변경 실패\"}");
            }
        }
    } else {
        // 로그인 사용자
        // 기존 투표 확인 (사용자 ID 기반)
        HottalkCommentVoteDto existingVote = voteDao.getVoteByUserAndComment(comment_id, userid);
        
        if (existingVote == null) {
            // 처음 투표하는 경우
            HottalkCommentVoteDto newVote = new HottalkCommentVoteDto(comment_id, userid, "dislike");
            boolean success = voteDao.insertVote(newVote);
            if (success) {
                // 댓글 테이블 dislikes +1
                commentDao.increaseDislikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"added\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"싫어요 추가 실패\"}");
            }
        } else if ("dislike".equals(existingVote.getVote_type())) {
            // 이미 싫어요를 누른 경우 - 취소
            boolean success = voteDao.deleteVoteByUser(comment_id, userid);
            if (success) {
                // 댓글 테이블 dislikes -1
                commentDao.decreaseDislikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"removed\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"싫어요 취소 실패\"}");
            }
        } else {
            // 좋아요를 누른 경우 - 싫어요로 변경
            boolean success = voteDao.updateVoteByUser(comment_id, userid, "dislike");
            if (success) {
                // 댓글 테이블 dislikes +1, likes -1
                commentDao.increaseDislikes(comment_id);
                commentDao.decreaseLikes(comment_id);
                // 댓글 테이블에서 업데이트된 수 가져오기
                Hottalk_CommentDto updatedComment = commentDao.getCommentById(comment_id);
                out.print("{\"success\":true,\"likes\":" + updatedComment.getLikes() + ",\"dislikes\":" + updatedComment.getDislikes() + ",\"action\":\"changed\"}");
            } else {
                out.print("{\"success\":false,\"error\":\"투표 변경 실패\"}");
            }
        }
    }
} else {
    out.print("{\"success\":false,\"error\":\"잘못된 요청\"}");
}
%> 