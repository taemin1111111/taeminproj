<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, content_images.*, java.sql.*" %>
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
    
    // DAO 생성 및 이미지 조회
    ContentImagesDao dao = new ContentImagesDao();
    List<ContentImagesDto> images = dao.getImagesByHotplaceId(placeId);
    
    // JSON 응답 생성
    StringBuilder json = new StringBuilder();
    json.append("{\"success\":true,\"images\":[");
    
    if (images != null && !images.isEmpty()) {
        for (int i = 0; i < images.size(); i++) {
            ContentImagesDto img = images.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"id\":").append(img.getId()).append(",");
            json.append("\"imagePath\":\"").append(img.getImagePath()).append("\",");
            json.append("\"imageOrder\":").append(img.getImageOrder()).append(",");
            json.append("\"createdAt\":\"").append(img.getCreatedAt()).append("\"");
            json.append("}");
        }
    }
    
    json.append("]}");
    
    response.getWriter().write(json.toString());
    
} catch (NumberFormatException e) {
    response.getWriter().write("{\"success\":false,\"message\":\"잘못된 장소 ID입니다.\"}");
} catch (Exception e) {
    e.printStackTrace();
    response.getWriter().write("{\"success\":false,\"message\":\"서버 오류가 발생했습니다.\"}");
}
%>
