<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="CCategory.CCategoryDao" %>
<%@ page import="CCategory.CCategoryDto" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>커뮤니티 카테고리</title>
</head>
<body>
<%
    CCategoryDao dao = new CCategoryDao();
    List<CCategoryDto> categories = dao.getAllCategories();
%>
<div>
    <h2>카테고리</h2>
    <ul>
    <% for(CCategoryDto cat : categories) { %>
        <li>
            <button type="button"><%= cat.getName() %></button>
        </li>
    <% } %>
    </ul>
</div>
</body>
</html>