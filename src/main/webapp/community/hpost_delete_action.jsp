<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.simple.JSONObject" %>
<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

HpostDao dao = new HpostDao();

String action = request.getParameter("action");
if ("delete".equals(action)) {
    int postId = Integer.parseInt(request.getParameter("id"));
    String passwd = request.getParameter("passwd");
    
    // 글 정보 가져오기
    HpostDto post = dao.getPostById(postId);
    if (post == null) {
        JSONObject obj = new JSONObject();
        obj.put("success", false);
        obj.put("error", "글을 찾을 수 없습니다.");
        out.print(obj.toString());
        return;
    }
    
    // 비밀번호 확인
    if (!post.getPasswd().equals(passwd)) {
        JSONObject obj = new JSONObject();
        obj.put("success", false);
        obj.put("error", "비밀번호가 일치하지 않습니다.");
        out.print(obj.toString());
        return;
    }
    
    // 글 삭제
    boolean success = dao.deletePost(postId);
    JSONObject obj = new JSONObject();
    obj.put("success", success);
    if (success) {
        obj.put("message", "글이 삭제되었습니다.");
    } else {
        obj.put("error", "글 삭제에 실패했습니다.");
    }
    out.print(obj.toString());
}
%> 