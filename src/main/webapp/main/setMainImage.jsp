<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, content_images.*, java.sql.*" %>
<%
response.setContentType("application/json; charset=UTF-8");

// 관리자 권한 확인
String provider = (String)session.getAttribute("provider");
if (provider == null || !"admin".equals(provider)) {
    response.getWriter().write("{\"success\":false,\"message\":\"관리자만 접근할 수 있습니다.\"}");
    return;
}

try {
    System.out.println("=== 대표사진 변경 시작 ===");
    
    // 파라미터 받기
    String imageIdStr = request.getParameter("imageId");
    String placeIdStr = request.getParameter("placeId");
    
    System.out.println("받은 파라미터 - imageId: " + imageIdStr + ", placeId: " + placeIdStr);
    
    if (imageIdStr == null || imageIdStr.trim().isEmpty() || 
        placeIdStr == null || placeIdStr.trim().isEmpty()) {
        System.out.println("필수 파라미터 누락");
        response.getWriter().write("{\"success\":false,\"message\":\"이미지 ID와 장소 ID가 필요합니다.\"}");
        return;
    }
    
    int imageId = Integer.parseInt(imageIdStr);
    int placeId = Integer.parseInt(placeIdStr);
    
    System.out.println("파싱된 파라미터 - imageId: " + imageId + ", placeId: " + placeId);
    
    // DAO 생성
    ContentImagesDao dao = new ContentImagesDao();
    
    // 대표사진 변경 실행
    boolean success = dao.setAsMainImage(imageId, placeId);
    
    if (success) {
        System.out.println("대표사진 변경 성공");
        response.getWriter().write("{\"success\":true,\"message\":\"대표사진이 성공적으로 변경되었습니다.\"}");
    } else {
        System.out.println("대표사진 변경 실패");
        response.getWriter().write("{\"success\":false,\"message\":\"대표사진 변경에 실패했습니다.\"}");
    }
    
    System.out.println("=== 대표사진 변경 완료 ===");
    
} catch (NumberFormatException e) {
    System.out.println("NumberFormatException: " + e.getMessage());
    response.getWriter().write("{\"success\":false,\"message\":\"잘못된 파라미터입니다.\"}");
} catch (Exception e) {
    System.out.println("Exception 발생: " + e.getMessage());
    e.printStackTrace();
    response.getWriter().write("{\"success\":false,\"message\":\"서버 오류가 발생했습니다: " + e.getMessage() + "\"}");
}
%>
