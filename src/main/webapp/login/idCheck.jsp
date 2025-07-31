<%@ page contentType="text/plain; charset=UTF-8" %>
<%@ page import="Member.MemberDAO" %>

<%
    String userid = request.getParameter("userid");
    MemberDAO dao = new MemberDAO();

    if (dao.isDuplicateId(userid)) {
        out.print("duplicate");
    } else {
        out.print("ok");
    }
%>