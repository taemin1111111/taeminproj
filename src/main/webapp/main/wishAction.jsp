<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="wishList.WishListDao" %>
<%@ page import="java.util.*" %>
<%
request.setCharacterEncoding("UTF-8");
String action = request.getParameter("action");
String placeIdStr = request.getParameter("place_id");
String userid = (String) session.getAttribute("loginid");
int placeId = 0;
if (placeIdStr != null && !placeIdStr.isEmpty()) {
    placeId = Integer.parseInt(placeIdStr);
}
WishListDao dao = new WishListDao();
response.setContentType("application/json; charset=UTF-8");

if (userid == null) {
    out.print("{\"result\":false,\"error\":\"not_logged_in\"}");
    return;
}

if ("check".equals(action)) {
    boolean wished = dao.isWished(userid, placeId);
    out.print("{\"result\":" + wished + "}");
} else if ("add".equals(action)) {
    boolean ok = dao.insertWishlist(userid, placeId);
    out.print("{\"result\":" + ok + "}");
} else if ("remove".equals(action)) {
    boolean ok = dao.deleteWishlist(userid, placeId);
    out.print("{\"result\":" + ok + "}");
} else if ("count".equals(action)) {
    int cnt = dao.getWishCount(placeId);
    out.print("{\"result\":true,\"count\":" + cnt + "}");
} else {
    out.print("{\"result\":false,\"error\":\"invalid_action\"}");
}
%>