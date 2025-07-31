<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    String root = request.getContextPath();
    String mainPage = "main/main.jsp";
    if (request.getParameter("main") != null) {
        mainPage = request.getParameter("main");
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>어디핫?</title>

<!-- 구글 폰트: Noto Sans KR -->
<link
	href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap"
	rel="stylesheet">

<!-- Bootstrap 5.3.3 -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<!-- Bootstrap Icons -->
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">

<!-- 외부 스타일시트 연결 -->
<link rel="stylesheet" href="<%=root%>/css/all.css">
<!-- gpaform,main,title,footer -->
<link rel="stylesheet" href="<%=root%>/css/review.css">
<!-- 후기작성 -->
<link rel="stylesheet" href="<%=root%>/css/LoginModal.css">
<!-- 후기작성 -->
<link rel="stylesheet" href="<%=root%>/css/join.css">
<!-- 커뮤니티 -->
<link rel="stylesheet" href="<%=root%>/css/community.css">
<!-- 마이페이지 -->
<link rel="stylesheet" href="<%=root%>/css/mypage.css">
</head>
<body>

	<!-- 상단 타이틀 영역 -->
	<jsp:include page="main/title.jsp" />

	<!-- 중앙 콘텐츠 영역 -->
	<div class="centered-content">
		<jsp:include page="<%=mainPage %>" />
	</div>

	<!-- 하단 푸터 영역 -->
	<jsp:include page="main/footer.jsp" />

</body>
</html>
