<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DbConnect" %>
<%@ page import="Member.MemberDTO" %>
<%@ page import="Member.MemberDAO" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    // 로그인 폼에서 받은 데이터
    String userid = request.getParameter("userid");
    String passwd = request.getParameter("passwd");
    
    // 입력값 검증
    if (userid == null || userid.trim().isEmpty() || 
        passwd == null || passwd.trim().isEmpty()) {
%>
        <script>
            alert("아이디와 비밀번호를 모두 입력해주세요.");
            history.back();
        </script>
<%
        return;
    }
    
    // MemberDAO를 통한 로그인 검증
    MemberDAO dao = new MemberDAO();
    MemberDTO member = dao.getMember(userid);
    
    if (member == null) {
        // 아이디가 존재하지 않는 경우
%>
        <script>
            alert("존재하지 않는 아이디입니다.");
            history.back();
        </script>
<%
        return;
    }
    
    // 비밀번호 검증
    if (member.getPasswd() == null || !member.getPasswd().equals(passwd)) {
        // 비밀번호가 일치하지 않는 경우
%>
        <script>
            alert("비밀번호가 일치하지 않습니다.");
            history.back();
        </script>
<%
        return;
    }
    
    // 로그인 성공 - 세션에 로그인 정보 저장
    session.setAttribute("loginid", userid);
    session.setAttribute("nickname", member.getNickname());
    session.setAttribute("provider", member.getProvider());
%>

<script>
    location.href="<%=request.getContextPath()%>/index.jsp";
</script> 