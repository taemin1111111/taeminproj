<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String root = request.getContextPath();
%>

<!-- 부트스트랩 아이콘용 링크 (index.jsp <head>에 이미 있을 수도 있음) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">

<footer class="bg-black text-white mt-5 py-4 border-top border-secondary">
    <div class="container text-center small">
        <div class="mb-2">
            <strong>어디핫? (WhereHot)</strong> &middot; 당신이 찾는 오늘의 핫플레이스
        </div>
        <div class="mb-2 text-muted">
            대표: 홍길동 &nbsp;|&nbsp; 문의: <a href="mailto:contact@odihot.com" class="text-decoration-none text-light">contact@odihot.com</a>
        </div>
        <div class="mb-2 text-muted">
            사업자등록번호: 123-45-67890 &nbsp;|&nbsp; 통신판매업 신고번호: 2025-서울강남-0000
        </div>
        <div class="mb-2">
            <a href="<%=root %>/privacy.jsp" class="text-decoration-none text-secondary">개인정보처리방침</a> &nbsp;|&nbsp;
            <a href="<%=root %>/terms.jsp" class="text-decoration-none text-secondary">이용약관</a> &nbsp;|&nbsp;
            <a href="<%=root %>/notice/list.jsp" class="text-decoration-none text-secondary">공지사항</a>
        </div>
        <div class="mt-3">
            <!-- ✅ 인스타그램 아이콘 링크 (네 계정으로 바꿔) -->
            <a href="https://www.instagram.com/너의계정아이디" target="_blank" class="text-white text-decoration-none">
                <i class="bi bi-instagram" style="font-size: 1.5rem;"></i>
                <span class="ms-1">Instagram</span>
            </a>
        </div>
        <div class="text-muted mt-2">
            ⓒ 2025 어디핫? All rights reserved.
        </div>
    </div>
</footer>
