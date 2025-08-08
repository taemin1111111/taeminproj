<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String nickname = (String)session.getAttribute("nickname");
    String provider = (String)session.getAttribute("provider");
%>


<!-- ✅ title.jsp - 상단 헤더 영역 -->
<header style="background-color: #1a1a1a;" class="text-white py-3 px-4 shadow-sm">
    <div class="container d-flex justify-content-between align-items-center">
        
        <!--  로고 -->
        <div class="logo-box" style="cursor: pointer;">
            <a href="<%=root%>/index.jsp?main=main/main.jsp">
                <img src="<%=root %>/logo/mainlogo2.png" alt="어디핫 로고" style="height: 60px;">
            </a>
        </div>

        <!--  중앙 메뉴 -->
        <nav class="flex-grow-1 text-center header-nav">
            <ul class="nav justify-content-center">
                <!-- 📌 핫플 평점보기 -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                         핫플 평점보기
                    </a>
                    <ul class="dropdown-menu text-start">
                       <li><a class="dropdown-item" href="<%=root%>/index.jsp?main=review/gpaform.jsp">지역별 평점 보기</a></li>
                    </ul>
                </li>

                <!-- 썰 게시판 -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                        썰 게시판
                    </a>
                    <ul class="dropdown-menu text-start">
                        <li><a class="dropdown-item" href="<%=root%>/community/best.jsp">전체 베스트 썰</a></li>
                        <li><a class="dropdown-item" href="<%=root%>/index.jsp?main=community/cumain.jsp">지역별 베스트 썰</a></li>
                    </ul>
                </li>

                <!-- 클럽 MD에게 문의하기 -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=root%>/index.jsp?main=clubmd/clubmd.jsp">클럽 MD에게 문의하기</a>
                </li>

                <!-- 테이블 예약하기 -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=root%>/index.jsp?main=clubtable/clubtable.jsp">테이블 예약하기</a>
                </li>

                <!-- 📢 공지사항 -->
                <li class="nav-item">
                    <a class="nav-link" href="<%=root%>/index.jsp?main=notice/noticemain.jsp">공지사항</a>
                </li>
            </ul>
        </nav>

        <!-- 🙋 로그인/회원가입 or 마이페이지 -->
     <div class="ms-3">
    <% if(loginId == null) { %>
        <a href="#" data-bs-toggle="modal" data-bs-target="#loginModal">
            로그인 / 회원가입
        </a>
    <% } else { 
        String iconClass = "bi-person-fill";  // 기본 아이콘 (사람)
        if("admin".equals(provider)) {  // provider가 "admin"이면 톱니바퀴
            iconClass = "bi-gear-fill";
        }
    %>
        <div class="btn-group">
            <button type="button" class="btn btn-outline-light dropdown-toggle" data-bs-toggle="dropdown">
                <i class="bi <%=iconClass%> me-1"></i> <%= nickname %>님
            </button>
            <ul class="dropdown-menu dropdown-menu-end">
                <% if("admin".equals(provider)) { %>
                    <!-- 관리자 전용 메뉴 -->
                    <li><a class="dropdown-item" href="<%=root%>/index.jsp?main=admin/member.jsp">회원 관리</a></li>
                    <li><a class="dropdown-item" href="<%=root%>/index.jsp?main=adminpage/report.jsp">게시판 관리</a></li>
                    <li><a class="dropdown-item" href="<%=root%>/index.jsp?main=admin/dashboard.jsp">통계/대시보드</a></li>
                    <li><a class="dropdown-item" href="<%=root%>/index.jsp?main=admin/settings.jsp">시스템 설정</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="<%=root%>/login/logout.jsp">로그아웃</a></li>
                <% } else { %>
                    <!-- 일반 사용자 메뉴 -->
                    <li><a class="dropdown-item" href="<%=root%>/index.jsp?main=mypage/mypageMain.jsp">마이페이지</a></li>
                    <li><a class="dropdown-item" href="<%=root%>/index.jsp?main=qna/qna.jsp">1:1 질문하기</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="<%=root%>/login/logout.jsp">로그아웃</a></li>
                <% } %>
            </ul>
        </div>
    <% } %>
</div>


    </div>
</header>

<!-- ✅ 로그인 모달 JSP include -->
<jsp:include page="/login/loginModal.jsp" />
