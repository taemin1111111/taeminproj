<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="review.ReviewDao" %>
<%@ page import="review.ReviewDto" %>
<%@ page import="java.sql.Timestamp" %>

<%
request.setCharacterEncoding("UTF-8");

// 파라미터 받기
String hg_id = request.getParameter("hg_id");
String userid = request.getParameter("userid");
String nickname = request.getParameter("nickname");
String passwd = request.getParameter("passwd");
String content = request.getParameter("content");
String starsStr = request.getParameter("stars");
String categoryStr = request.getParameter("category_id");
String region = request.getParameter("region");
String isSigunguStr = request.getParameter("isSigungu");

boolean isSigungu = Boolean.parseBoolean(isSigunguStr);

// ✅ 방어로직 : 시군구일 경우 작성불가
if (isSigungu) {
    out.print("{\"success\": false, \"message\": \"시군구에서는 리뷰를 작성할 수 없습니다.\"}");
    return;
}

double stars = 0;
int category_id = 0;

try {
	System.out.println("⭐ starsStr = " + starsStr);
	System.out.println("📦 categoryStr = " + categoryStr);
	System.out.println("➡ isSigungu = " + isSigungu);
	stars = Double.parseDouble(starsStr);
    category_id = Integer.parseInt(categoryStr);
} catch (Exception e) {
    out.print("{\"success\": false, \"message\": \"평점 데이터 오류\"}");
    return;
}

ReviewDao dao = new ReviewDao();

// ✅ 중복 검사 (userid + hg_id + category_id)
boolean isDuplicate = dao.isAlreadyExist(userid, hg_id, category_id);
if (isDuplicate) {
    out.print("{\"success\": false, \"message\": \"이미 해당 지역과 카테고리에 작성한 리뷰가 존재합니다.\"}");
    return;
}

// ✅ DB Insert
ReviewDto dto = new ReviewDto();
dto.setHg_id(hg_id);
dto.setUserid(userid);
dto.setNickname(nickname);
dto.setPasswd(passwd);
dto.setContent(content);
dto.setStars(stars);
dto.setCategory_id(category_id);
dto.setGood(0);
dto.setWriteday(new Timestamp(System.currentTimeMillis()));
dto.setType(null);

boolean result = dao.insertReview(dto);

if (result) {
    out.print("{\"success\": true}");
} else {
    out.print("{\"success\": false, \"message\": \"후기 등록 실패\"}");
}
%>
