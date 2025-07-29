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
    Hottalk_CommentDto dto = new Hottalk_CommentDto();
    dto.setPost_id(post_id);
    dto.setNickname(nickname);
    dto.setPasswd(passwd);
    dto.setContent(content);
    dto.setIp_address(ip);
    boolean success = dao.insertComment(dto);
    JSONObject obj = new JSONObject();
    obj.put("success", success);
    out.print(obj.toString());
} else if ("list".equals(action)) {
    int post_id = Integer.parseInt(request.getParameter("post_id"));
    List<Hottalk_CommentDto> list = dao.getCommentsByPostId(post_id);
    JSONArray arr = new JSONArray();
    for (Hottalk_CommentDto c : list) {
        JSONObject o = new JSONObject();
        o.put("id", c.getId());
        o.put("nickname", c.getNickname());
        o.put("content", c.getContent());
        o.put("created_at", c.getCreated_at() != null ? c.getCreated_at().toString() : "");
        arr.add(o);
    }
    out.print(arr.toString());
} else if ("count".equals(action)) {
    int post_id = Integer.parseInt(request.getParameter("post_id"));
    int count = dao.getCommentCountByPostId(post_id);
    JSONObject obj = new JSONObject();
    obj.put("count", count);
    out.print(obj.toString());
} else {
    JSONObject obj = new JSONObject();
    obj.put("success", false);
    obj.put("error", "잘못된 요청");
    out.print(obj.toString());
}
%> 