<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="Member.MemberDTO" %>
<%@ page import="Member.MemberDAO" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    
    // 로그인하지 않은 경우 처리
    if(loginId == null) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
    
    // 회원 정보 가져오기
    MemberDAO dao = new MemberDAO();
    MemberDTO member = dao.getMember(loginId);
    
    if(member == null) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
%>

<div class="mypage-container">


    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <i class="bi bi-person-fill"></i>
            </div>
            <div class="profile-info">
                <h3 class="profile-name"><%= member.getNickname() %></h3>
                <span class="profile-type">
                    <% if("naver".equals(member.getProvider())) { %>
                        <i class="bi bi-check-circle-fill text-success me-1"></i>네이버 계정
                    <% } else { %>
                        <i class="bi bi-check-circle-fill text-primary me-1"></i>일반 계정
                    <% } %>
                </span>
            </div>
        </div>

        <div class="profile-details">
            <div class="detail-item">
                <div class="detail-label">
                    <i class="bi bi-person me-2"></i>닉네임
                </div>
                <div class="detail-value"><%= member.getNickname() %></div>
            </div>

            <div class="detail-item">
                <div class="detail-label">
                    <i class="bi bi-envelope me-2"></i>이메일
                </div>
                <div class="detail-value"><%= member.getEmail() %></div>
            </div>

            <div class="detail-item">
                <div class="detail-label">
                    <i class="bi bi-calendar-event me-2"></i>가입일
                </div>
                <div class="detail-value">
                    <%= member.getRegdate() != null ? member.getRegdate().toString().substring(0, 10) : "정보 없음" %>
                </div>
            </div>

            <div class="detail-item">
                <div class="detail-label">
                    <i class="bi bi-shield-check me-2"></i>로그인 방식
                </div>
                <div class="detail-value">
                    <% if("naver".equals(member.getProvider())) { %>
                        <span class="badge bg-success">네이버 로그인</span>
                    <% } else { %>
                        <span class="badge bg-primary">일반 로그인</span>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="profile-actions">
            <button class="btn btn-outline-primary me-2">
                <i class="bi bi-pencil me-1"></i>정보 수정
            </button>
            <button class="btn btn-outline-secondary">
                <i class="bi bi-gear me-1"></i>설정
            </button>
        </div>
    </div>
</div>

<link rel="stylesheet" href="<%=root%>/css/mypage.css">