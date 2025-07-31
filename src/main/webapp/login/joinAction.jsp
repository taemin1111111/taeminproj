<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DB.DbConnect" %>
<%@ page import="Member.MemberDTO" %>
<%@ page import="Member.MemberDAO" %>
<%@ page import="EmailVerification.EmailVerificationDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 공통 파라미터 받기
    String userid   = request.getParameter("userid");
    String name     = request.getParameter("name");
    String email    = request.getParameter("email");
    String nickname = request.getParameter("nickname");
    String birthStr = request.getParameter("birth");
    String gender   = request.getParameter("gender");
    String provider = request.getParameter("provider");   // 이게 join_type 역할
    String phone    = "";  // 휴대폰 번호는 빈 값으로 설정

    // 패스워드는 일반 회원가입만 받음
    String passwd = request.getParameter("passwd");
    if ("naver".equals(provider)) {
        passwd = null;
    }

    // birth → Date 변환 (Date가 아니라면 String으로 그대로 넣어도됨)
    Date birth = null;
    if (birthStr != null && !birthStr.isEmpty()) {
        birth = Date.valueOf(birthStr);   // yyyy-MM-dd 형태일 때만 가능
    }

    // 이메일 인증 확인 (일반 회원가입만)
    if (!"naver".equals(provider)) {
        EmailVerificationDAO emailDao = new EmailVerificationDAO();
        if (!emailDao.isEmailVerified(email)) {
%>
            <script>
                alert("이메일 인증을 완료해주세요.");
                history.back();
            </script>
<%
            return;
        }
    }

    // dto에 담기
    MemberDTO dto = new MemberDTO();
    dto.setUserid(userid);
    dto.setName(name);
    dto.setEmail(email);
    dto.setNickname(nickname);
    dto.setPhone(phone);
    dto.setBirth(birth);
    dto.setGender(gender);
    dto.setPasswd(passwd);
    dto.setProvider(provider);
    dto.setStatus("정상");  // 초기상태는 항상 정상

    // DAO 호출 → DB 저장
    MemberDAO dao = new MemberDAO();
    dao.insertMember(dto);
%>

<script>
    alert("회원가입이 완료되었습니다!");
    location.href="<%=request.getContextPath()%>/index.jsp";
</script>