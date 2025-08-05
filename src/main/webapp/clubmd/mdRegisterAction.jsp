<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="MD.MdDao" %>
<%@ page import="MD.MdDto" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>
<%
    response.setContentType("application/json; charset=UTF-8");
    
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String provider = (String)session.getAttribute("provider");
    
    // 관리자 권한 확인
    if(loginId == null || !"admin".equals(provider)) {
        response.getWriter().write("{\"success\": false, \"message\": \"관리자만 MD를 등록할 수 있습니다.\"}");
        return;
    }
    
    try {
        // 파일 업로드 설정
        String uploadPath = application.getRealPath("/mdphotos");
        int maxSize = 10 * 1024 * 1024; // 10MB
        
        // 업로드 디렉토리 생성
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // MultipartRequest로 파일과 데이터 받기
        MultipartRequest multi = new MultipartRequest(request, uploadPath, maxSize, "UTF-8", new DefaultFileRenamePolicy());
        
        // 폼 데이터 받기
        String mdName = multi.getParameter("mdName");
        String placeIdStr = multi.getParameter("placeId");
        String contact = multi.getParameter("contact");
        String description = multi.getParameter("description");
        String photo = multi.getFilesystemName("photo");
        
        // 필수 필드 검증
        if (mdName == null || mdName.trim().isEmpty() ||
            placeIdStr == null || placeIdStr.trim().isEmpty()) {
            response.getWriter().write("{\"success\": false, \"message\": \"필수 항목을 모두 입력해주세요.\"}");
            return;
        }
        
        // placeId를 정수로 변환
        int placeId;
        try {
            placeId = Integer.parseInt(placeIdStr.trim());
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\": false, \"message\": \"올바른 장소를 선택해주세요.\"}");
            return;
        }
        
        // MD DTO 생성
        MdDto mdDto = new MdDto();
        mdDto.setMdName(mdName.trim());
        mdDto.setPlaceId(placeId);
        mdDto.setContact(contact != null ? contact.trim() : "");
        mdDto.setDescription(description != null ? description.trim() : "");
        mdDto.setPhoto(photo != null ? photo : "");
        mdDto.setVisible(true);
        
        // DAO로 등록
        MdDao mdDao = new MdDao();
        boolean result = mdDao.insertMd(mdDto);
        
        if (result) {
            response.getWriter().write("{\"success\": true, \"message\": \"MD가 성공적으로 등록되었습니다.\"}");
        } else {
            response.getWriter().write("{\"success\": false, \"message\": \"MD 등록에 실패했습니다.\"}");
        }
        
    } catch (Exception e) {
        System.out.println("MD 등록 오류: " + e.getMessage());
        e.printStackTrace();
        response.getWriter().write("{\"success\": false, \"message\": \"MD 등록 중 오류가 발생했습니다.\"}");
    }
%> 