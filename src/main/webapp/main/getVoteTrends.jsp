<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, VoteNowHot.*, java.sql.*" %>
<%
response.setContentType("application/json; charset=UTF-8");

try {
    // 파라미터 받기
    String placeIdStr = request.getParameter("placeId");
    
    if (placeIdStr == null || placeIdStr.trim().isEmpty()) {
        response.getWriter().write("{\"success\":false,\"message\":\"장소 ID가 필요합니다.\"}");
        return;
    }
    
    int placeId = Integer.parseInt(placeIdStr);
    
    // DAO 생성
    VoteNowHotDao voteDao = new VoteNowHotDao();
    
    // 각 컬럼별로 가장 많이 투표된 값 조회
    Map<String, String> trends = voteDao.getVoteTrends(placeId);
    
    // JSON 응답 생성
    StringBuilder json = new StringBuilder();
    json.append("{\"success\":true,\"trends\":{");
    json.append("\"congestion\":\"").append(trends.get("congestion")).append("\",");
    json.append("\"genderRatio\":\"").append(trends.get("genderRatio")).append("\",");
    json.append("\"waitTime\":\"").append(trends.get("waitTime")).append("\"");
    json.append("}}");
    
    response.getWriter().write(json.toString());
    
} catch (NumberFormatException e) {
    response.getWriter().write("{\"success\":false,\"message\":\"잘못된 장소 ID입니다.\"}");
} catch (Exception e) {
    e.printStackTrace();
    response.getWriter().write("{\"success\":false,\"message\":\"서버 오류가 발생했습니다.\"}");
}
%>
