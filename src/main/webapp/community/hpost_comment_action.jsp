<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="hottalk_comment.Hottalk_CommentDao" %>
<%@ page import="hottalk_comment.Hottalk_CommentDto" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.simple.JSONArray" %>
<%@ page import="org.json.simple.JSONObject" %>
<%
request.setCharacterEncoding("UTF-8");
String action = request.getParameter("action");
Hottalk_CommentDao dao = new Hottalk_CommentDao();

if ("insert".equals(action)) {
    int post_id = Integer.parseInt(request.getParameter("post_id"));
    String nickname = request.getParameter("nickname");
    String passwd = request.getParameter("passwd");
    String content = request.getParameter("content");
    String ip = request.getRemoteAddr();
    
    // 로그인 상태 확인
    String loginid = (String)session.getAttribute("loginid");
    
    Hottalk_CommentDto dto = new Hottalk_CommentDto();
    dto.setPost_id(post_id);
    dto.setNickname(nickname);
    dto.setPasswd(passwd);
    dto.setContent(content);
    
    if (loginid != null && !loginid.trim().isEmpty()) {
        // 로그인된 경우: id_address에 user_id 저장, ip_address는 null
        dto.setId_address(loginid);
        dto.setIp_address(null);
    } else {
        // 로그인되지 않은 경우: ip_address에 IP 저장, id_address는 null
        dto.setId_address(null);
        dto.setIp_address(ip);
    }
    
    boolean success = dao.insertComment(dto);
    JSONObject obj = new JSONObject();
    obj.put("success", success);
    out.print(obj.toString());
} else if ("list".equals(action)) {
    try {
        int post_id = Integer.parseInt(request.getParameter("post_id"));
        String sortType = request.getParameter("sort");
        
        List<Hottalk_CommentDto> list;
        if ("popular".equals(sortType)) {
            // 인기순 (좋아요 순)
            list = dao.getCommentsByPostIdOrderByLikes(post_id);
        } else {
            // 최신순 (기본)
            list = dao.getCommentsByPostId(post_id);
        }
        
        // 댓글 투표 DAO 추가
        hottalk_comment_vote.HottalkCommentVoteDao voteDao = new hottalk_comment_vote.HottalkCommentVoteDao();
        
        JSONArray arr = new JSONArray();
        for (Hottalk_CommentDto c : list) {
            JSONObject o = new JSONObject();
            o.put("id", c.getId());
            o.put("nickname", c.getNickname());
            o.put("content", c.getContent());
            o.put("created_at", c.getCreated_at() != null ? c.getCreated_at().toString() : "");
            o.put("id_address", c.getId_address()); // 로그인 여부 확인용
            // 댓글 테이블에서 직접 가져오기
            o.put("likes", c.getLikes());
            o.put("dislikes", c.getDislikes());
            arr.add(o);
        }
        out.print(arr.toString());
    } catch (Exception e) {
        e.printStackTrace();
        out.print("[]");
    }
} else if ("delete".equals(action)) {
    int comment_id = Integer.parseInt(request.getParameter("comment_id"));
    String passwd = request.getParameter("passwd");
    
    // 댓글 정보 조회
    Hottalk_CommentDto comment = dao.getCommentById(comment_id);
    if (comment == null) {
        JSONObject obj = new JSONObject();
        obj.put("success", false);
        obj.put("error", "댓글을 찾을 수 없습니다.");
        out.print(obj.toString());
        return;
    }
    
    // 비밀번호 확인
    if (!comment.getPasswd().equals(passwd)) {
        JSONObject obj = new JSONObject();
        obj.put("success", false);
        obj.put("error", "비밀번호가 일치하지 않습니다.");
        out.print(obj.toString());
        return;
    }
    
    // 댓글 삭제
    boolean success = dao.deleteComment(comment_id);
    JSONObject obj = new JSONObject();
    obj.put("success", success);
    if (success) {
        obj.put("message", "댓글이 삭제되었습니다.");
    } else {
        obj.put("error", "댓글 삭제에 실패했습니다.");
    }
    out.print(obj.toString());
} else {
    JSONObject obj = new JSONObject();
    obj.put("success", false);
    obj.put("error", "잘못된 요청");
    out.print(obj.toString());
}
%> 