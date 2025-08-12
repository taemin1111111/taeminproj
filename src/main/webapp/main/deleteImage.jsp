<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, content_images.*, java.sql.*, java.io.*" %>
<%
response.setContentType("application/json; charset=UTF-8");

// 관리자 권한 확인
String provider = (String)session.getAttribute("provider");
if (provider == null || !"admin".equals(provider)) {
    response.getWriter().write("{\"success\":false,\"message\":\"관리자만 접근할 수 있습니다.\"}");
    return;
}

try {
    System.out.println("=== 이미지 삭제 시작 ===");
    System.out.println("요청 메서드: " + request.getMethod());
    System.out.println("Content-Type: " + request.getContentType());
    
    // 파라미터 받기 (POST와 GET 모두 지원)
    String imageIdStr = null;
    
    if ("POST".equals(request.getMethod())) {
        // POST 요청인 경우
        imageIdStr = request.getParameter("imageId");
        System.out.println("POST 파라미터에서 받은 imageId: " + imageIdStr);
        
        // FormData에서 직접 읽기 시도
        if (imageIdStr == null || imageIdStr.trim().isEmpty()) {
            // request body에서 직접 읽기
            BufferedReader reader = request.getReader();
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String body = sb.toString();
            System.out.println("Request Body: " + body);
            
            // FormData 파싱 시도
            if (body.contains("imageId=")) {
                String[] parts = body.split("&");
                for (String part : parts) {
                    if (part.startsWith("imageId=")) {
                        imageIdStr = part.substring("imageId=".length());
                        break;
                    }
                }
                System.out.println("Body에서 파싱된 imageId: " + imageIdStr);
            }
        }
    } else {
        // GET 요청인 경우
        imageIdStr = request.getParameter("imageId");
        System.out.println("GET 파라미터에서 받은 imageId: " + imageIdStr);
    }
    
    System.out.println("최종 imageId: " + imageIdStr);
    
    if (imageIdStr == null || imageIdStr.trim().isEmpty()) {
        System.out.println("이미지 ID가 없음");
        response.getWriter().write("{\"success\":false,\"message\":\"이미지 ID가 필요합니다.\"}");
        return;
    }
    
    int imageId = Integer.parseInt(imageIdStr);
    System.out.println("파싱된 imageId: " + imageId);
    
    // DAO 생성
    ContentImagesDao dao = new ContentImagesDao();
    
    // 이미지 정보 조회 (삭제 전에 백업)
    ContentImagesDto targetImage = dao.getImageById(imageId);
    
    if (targetImage == null) {
        System.out.println("DB에서 이미지를 찾을 수 없음: " + imageId);
        response.getWriter().write("{\"success\":false,\"message\":\"해당 이미지를 찾을 수 없습니다.\"}");
        return;
    }
    
    System.out.println("이미지 정보 조회 성공:");
    System.out.println("  - ID: " + targetImage.getId());
    System.out.println("  - 경로: " + targetImage.getImagePath());
    System.out.println("  - 장소ID: " + targetImage.getHotplaceId());
    System.out.println("  - 순서: " + targetImage.getImageOrder());
    
    // 실제 파일 삭제
    String webappPath = application.getRealPath("/");
    String imagePath = webappPath + targetImage.getImagePath().substring(1); // /uploads/places/... -> uploads/places/...
    
    System.out.println("웹앱 경로: " + webappPath);
    System.out.println("이미지 파일 경로: " + imagePath);
    
    File imageFile = new File(imagePath);
    boolean fileDeleted = false;
    
    if (imageFile.exists()) {
        System.out.println("파일 존재 확인됨: " + imageFile.getAbsolutePath());
        System.out.println("파일 크기: " + imageFile.length() + " bytes");
        
        fileDeleted = imageFile.delete();
        System.out.println("파일 삭제 시도 결과: " + (fileDeleted ? "성공" : "실패"));
        
        if (!fileDeleted) {
            System.out.println("파일 삭제 실패 - 전체 작업 중단");
            response.getWriter().write("{\"success\":false,\"message\":\"파일 삭제에 실패했습니다.\"}");
            return;
        }
    } else {
        System.out.println("파일이 존재하지 않음: " + imagePath);
        // 파일이 이미 없어도 계속 진행
    }
    
    // DB에서 이미지 정보 삭제
    System.out.println("DB에서 이미지 정보 삭제 시도...");
    boolean dbDeleted = dao.deleteImage(imageId);
    
    if (!dbDeleted) {
        System.out.println("DB 삭제 실패 - 전체 작업 실패");
        response.getWriter().write("{\"success\":false,\"message\":\"DB에서 이미지 삭제에 실패했습니다.\"}");
        return;
    }
    
    System.out.println("DB 삭제 성공");
    
    // 이미지 순서 재정렬
    System.out.println("이미지 순서 재정렬 시도...");
    boolean reordered = dao.reorderImagesAfterDelete(targetImage.getHotplaceId());
    
    if (!reordered) {
        System.out.println("순서 재정렬 실패 - DB 롤백 시도...");
        
        // 롤백: 삭제된 이미지 정보 복구
        boolean rollbackSuccess = dao.rollbackImageDelete(targetImage);
        
        if (rollbackSuccess) {
            System.out.println("롤백 성공 - 이미지 정보 복구됨");
            response.getWriter().write("{\"success\":false,\"message\":\"이미지 삭제는 성공했지만 순서 재정렬에 실패했습니다. 이미지가 복구되었습니다.\"}");
        } else {
            System.out.println("롤백 실패 - 데이터 불일치 발생!");
            response.getWriter().write("{\"success\":false,\"message\":\"이미지 삭제 중 오류가 발생했습니다. 관리자에게 문의하세요.\"}");
        }
        return;
    }
    
    System.out.println("순서 재정렬 성공");
    System.out.println("=== 이미지 삭제 완료 ===");
    
    // 모든 작업이 성공한 경우
    response.getWriter().write("{\"success\":true,\"message\":\"이미지가 성공적으로 삭제되었습니다.\"}");
    
} catch (NumberFormatException e) {
    System.out.println("NumberFormatException: " + e.getMessage());
    response.getWriter().write("{\"success\":false,\"message\":\"잘못된 이미지 ID입니다.\"}");
} catch (Exception e) {
    System.out.println("Exception 발생: " + e.getMessage());
    e.printStackTrace();
    response.getWriter().write("{\"success\":false,\"message\":\"서버 오류가 발생했습니다: " + e.getMessage() + "\"}");
}
%>
