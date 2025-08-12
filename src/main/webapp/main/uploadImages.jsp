<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, content_images.*, java.sql.*, java.io.*, javax.servlet.*, javax.servlet.http.*" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%
// 관리자 권한 확인
String provider = (String)session.getAttribute("provider");
if (provider == null || !"admin".equals(provider)) {
    out.println("<script>alert('관리자만 접근할 수 있습니다.'); history.back();</script>");
    return;
}

try {
    System.out.println("=== 이미지 업로드 시작 ===");
    
    // Tomcat 배포 디렉토리의 uploads 폴더에 저장
    String webappPath = application.getRealPath("/");
    String uploadPath = webappPath + "uploads" + File.separator + "places" + File.separator;
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        boolean created = uploadDir.mkdirs();
        System.out.println("업로드 디렉토리 생성: " + (created ? "성공" : "실패"));
    }
    
    System.out.println("웹앱 경로: " + webappPath);
    System.out.println("업로드 경로: " + uploadPath);
    System.out.println("업로드 디렉토리 존재: " + uploadDir.exists());
    System.out.println("업로드 디렉토리 절대 경로: " + uploadDir.getAbsolutePath());
    
    int maxSize = 10 * 1024 * 1024; // 10MB
    MultipartRequest multi = new MultipartRequest(request, uploadPath, maxSize, "UTF-8", new DefaultFileRenamePolicy());
    
    // place_id 파라미터 읽기
    String placeIdStr = multi.getParameter("place_id");
    System.out.println("place_id 파라미터: " + placeIdStr);
    
    if (placeIdStr == null || placeIdStr.trim().isEmpty()) {
        out.println("<script>alert('장소 ID가 필요합니다.'); history.back();</script>");
        return;
    }
    
    int placeId = Integer.parseInt(placeIdStr);
    System.out.println("받은 placeId: " + placeId);
    
    // 이미지 파일 처리
    String imageFileName = multi.getFilesystemName("images");
    System.out.println("이미지 파일명: " + imageFileName);
    
    if (imageFileName == null || imageFileName.trim().isEmpty()) {
        out.println("<script>alert('업로드할 이미지가 없습니다.'); history.back();</script>");
        return;
    }
    
    // 장소별 폴더로 이동
    String placeFolder = uploadPath + placeId + "/";
    File placeDir = new File(placeFolder);
    if (!placeDir.exists()) {
        placeDir.mkdirs();
    }
    
    // 파일을 장소별 폴더로 이동
    File sourceFile = new File(uploadPath + imageFileName);
    String newFileName = System.currentTimeMillis() + "_" + imageFileName;
    File targetFile = new File(placeFolder + newFileName);
    
    if (sourceFile.renameTo(targetFile)) {
        System.out.println("파일 이동 성공: " + targetFile.getAbsolutePath());
        System.out.println("웹 접근 경로: " + targetFile.getAbsolutePath());
    } else {
        // rename 실패 시 복사
        try (FileInputStream fis = new FileInputStream(sourceFile);
             FileOutputStream fos = new FileOutputStream(targetFile)) {
            byte[] buffer = new byte[1024];
            int length;
            while ((length = fis.read(buffer)) > 0) {
                fos.write(buffer, 0, length);
            }
        }
        sourceFile.delete(); // 원본 파일 삭제
        System.out.println("파일 복사 성공: " + targetFile.getAbsolutePath());
        System.out.println("웹 접근 경로: " + targetFile.getAbsolutePath());
    }
    
    // DAO 생성
    ContentImagesDao dao = new ContentImagesDao();
    
    // DB에 이미지 정보 저장 - 웹 접근 경로로 저장
    ContentImagesDto imageDto = new ContentImagesDto();
    imageDto.setHotplaceId(placeId);
    // 웹 접근 경로로 저장 (상대 경로 사용)
    String webImagePath = "/uploads/places/" + placeId + "/" + newFileName;
    imageDto.setImagePath(webImagePath);
    imageDto.setImageOrder(dao.getNextImageOrder(placeId));
    
    System.out.println("DB에 저장할 이미지 경로: " + imageDto.getImagePath());
    
    if (dao.insertImage(imageDto)) {
        System.out.println("DB 저장 성공");
        System.out.println("최종 저장된 이미지 경로: " + imageDto.getImagePath());
        String contextPath = request.getContextPath();
        out.println("<script>alert('이미지가 성공적으로 업로드되었습니다.'); window.location.href='" + contextPath + "/index.jsp?main=main/main.jsp';</script>");
    } else {
        System.out.println("DB 저장 실패");
        out.println("<script>alert('이미지 업로드에 실패했습니다.'); history.back();</script>");
    }
    
} catch (NumberFormatException e) {
    out.println("<script>alert('잘못된 장소 ID입니다.'); history.back();</script>");
} catch (Exception e) {
    e.printStackTrace();
    out.println("<script>alert('서버 오류가 발생했습니다: " + e.getMessage() + "'); history.back();</script>");
}
%>
