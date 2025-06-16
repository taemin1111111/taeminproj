<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="review.ReviewDao, review.ReviewDto" %>
<%@ page import="java.sql.Timestamp" %>

<%
request.setCharacterEncoding("UTF-8");
String root = request.getContextPath();

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

double stars = 0;
int category_id = 0;
boolean isSigungu = Boolean.parseBoolean(isSigunguStr);

// 타입 변환
try {
    stars = Double.parseDouble(starsStr);
    category_id = Integer.parseInt(categoryStr);
} catch (Exception e) {
    session.setAttribute("msg", "평점 데이터 오류");
    session.setAttribute("msgType", "error");
    response.sendRedirect(root + "/index.jsp?main=gpa/gpaform.jsp&region=" + region + "&isSigungu=" + isSigungu);
    return;
}

// 중복 검사
ReviewDao dao = new ReviewDao();
boolean isDuplicate = dao.isAlreadyExist(userid, hg_id, category_id);

if (isDuplicate) {
    session.setAttribute("msg", "동일 지역·카테고리는 한 번만 작성 가능합니다.");
    session.setAttribute("msgType", "error");
} else {
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
        session.setAttribute("msg", "평점 등록이 완료되었습니다.");
        session.setAttribute("msgType", "success");
    } else {
        session.setAttribute("msg", "평점 등록 실패");
        session.setAttribute("msgType", "error");
    }
}

// ✅ 등록 후 → gpaform.jsp 내부로 돌아감
response.sendRedirect(root + "/index.jsp?main=gpa/gpaform.jsp&region=" + region + "&isSigungu=" + isSigungu);
%>
