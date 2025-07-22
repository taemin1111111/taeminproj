<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, VoteNowHot.*" %>
<%
    // 1. JSP 진입 확인용 로그
    System.out.println("🔥🔥🔥 voteAction.jsp 진입 확인용 로그 🔥🔥🔥");
    request.setCharacterEncoding("UTF-8");
    
    // 2. 파라미터 값 로그
    String placeId = request.getParameter("hotplaceId");
    String congestion = request.getParameter("crowd");
    String genderRatio = request.getParameter("gender");
    String waitTime = request.getParameter("wait");
    System.out.println("placeId=" + placeId);
    System.out.println("congestion=" + congestion);
    System.out.println("genderRatio=" + genderRatio);
    System.out.println("waitTime=" + waitTime);
    
    // 3. 세션 userId 로그
    String voterId = (String) session.getAttribute("userId");
    if (voterId == null) {
        voterId = "anonymous"; // 임시 사용자 ID
    }
    System.out.println("voterId=" + voterId);
    
    // 투표 데이터 검증
    if (placeId == null || congestion == null || genderRatio == null || waitTime == null) {
        response.sendRedirect("nowhot.jsp?error=invalid_data");
        return;
    }
    
    try {
        VoteNowHotDto voteDto = new VoteNowHotDto();
        voteDto.setPlaceId(Integer.parseInt(placeId));
        voteDto.setVoterId(voterId);
        voteDto.setCongestion(Integer.parseInt(congestion));
        voteDto.setGenderRatio(Integer.parseInt(genderRatio));
        voteDto.setWaitTime(Integer.parseInt(waitTime));
        voteDto.setVotedAt(new Date());
        
        VoteNowHotDao voteDao = new VoteNowHotDao();
        voteDao.insertVote(voteDto);
        
        // 성공 시 메인 페이지로 리다이렉트
        response.sendRedirect("main.jsp?success=vote_completed");
        
    } catch (Exception e) {
        // 4. 에러 로그 (이미 있음)
        e.printStackTrace();
        System.out.println("투표 인서트 에러: " + e.getMessage());
        // 에러 발생 시 에러 페이지로 리다이렉트
        response.sendRedirect("nowhot.jsp?error=save_failed");
    }
%> 