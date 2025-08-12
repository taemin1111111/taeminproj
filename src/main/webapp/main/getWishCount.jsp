<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, wishList.*, java.sql.*" %>
<%
response.setContentType("application/json; charset=UTF-8");

try {
    // 파라미터 받기
    String placeIdStr = request.getParameter("placeId");
    
    if (placeIdStr == null || placeIdStr.trim().isEmpty()) {
        response.getWriter().write("{\"success\":false,\"message\":\"장소 ID가 필요합니다.\",\"count\":0}");
        return;
    }
    
    int placeId = Integer.parseInt(placeIdStr);
    
    // DAO 생성
    WishListDao dao = new WishListDao();
    
    // 위시리스트 개수 조회
    int wishCount = dao.getWishCount(placeId);
    
    // 성공 응답
    response.getWriter().write("{\"success\":true,\"count\":" + wishCount + "}");
    
} catch (NumberFormatException e) {
    response.getWriter().write("{\"success\":false,\"message\":\"잘못된 파라미터입니다.\",\"count\":0}");
} catch (Exception e) {
    e.printStackTrace();
    response.getWriter().write("{\"success\":false,\"message\":\"서버 오류가 발생했습니다.\",\"count\":0}");
}
%>
