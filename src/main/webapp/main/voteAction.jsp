<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, VoteNowHot.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 투표 데이터 받기
    String placeId = request.getParameter("hotplaceId");
    String congestion = request.getParameter("crowd");
    String genderRatio = request.getParameter("gender");
    String waitTime = request.getParameter("wait");
    
    // 세션에서 사용자 정보 가져오기 (로그인 기능이 있다면)
    String voterId = (String) session.getAttribute("userId");
    if (voterId == null) {
        voterId = "anonymous"; // 임시 사용자 ID
    }
    
    // 투표 데이터 검증
    if (placeId == null || congestion == null || genderRatio == null || waitTime == null) {
        response.sendRedirect("nowhot.jsp?error=invalid_data");
        return;
    }
    
    System.out.println("placeId=" + placeId);
    System.out.println("congestion=" + congestion);
    System.out.println("genderRatio=" + genderRatio);
    System.out.println("waitTime=" + waitTime);
    System.out.println("voterId=" + voterId);
    
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
        // 에러 발생 시 에러 페이지로 리다이렉트
        response.sendRedirect("nowhot.jsp?error=save_failed");
    }
%> 