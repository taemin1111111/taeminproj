<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="review.ReviewDao" %>
<%@ page import="review.ReviewDto" %>
<%
request.setCharacterEncoding("UTF-8");

String reviewNumStr = request.getParameter("reviewNum");
int reviewNum = Integer.parseInt(reviewNumStr);

// 로그인 여부 확인 (userid 한 컬럼만 사용)
String userid = (String)session.getAttribute("loginid");
if (userid == null || userid.trim().isEmpty()) {
    userid = request.getRemoteAddr(); // 비로그인 시 IP를 userid로 사용
}

ReviewDao dao = new ReviewDao();
boolean already = dao.hasAlreadyRecommended(reviewNum, userid);

if (already) {
    out.print("{\"success\":false, \"message\":\"이미 추천하셨습니다.\"}");
    return;
}

boolean ok = dao.recommendReview(reviewNum, userid);
if (ok) {
    // 추천수 다시 조회
    ReviewDto dto = dao.getReviewByNum(reviewNum);
    out.print("{\"success\":true, \"good\":" + dto.getGood() + "}");
} else {
    out.print("{\"success\":false, \"message\":\"추천 실패\"}");
}
%>