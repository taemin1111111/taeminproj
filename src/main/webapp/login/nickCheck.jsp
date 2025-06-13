<%@ page contentType="text/plain; charset=UTF-8" %>
<%@ page import="Member.MemberDAO" %>

<%
    String nickname = request.getParameter("nickname");
    MemberDAO dao = new MemberDAO();

    if (dao.isDuplicateNickname(nickname)) {
        out.print("duplicate");
    } else {
        out.print("ok");
    }
%>
