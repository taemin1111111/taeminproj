<%@ page contentType="text/html; charset=UTF-8"%>
<%
    String root = request.getContextPath();
%>

<div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content p-4">

            <!-- 닫기 버튼 -->
            <button type="button" class="btn-close position-absolute top-0 end-0 m-3" data-bs-dismiss="modal" aria-label="Close"></button>

            <div class="row">

                <!-- 왼쪽 폼 영역 -->
                <div class="col-md-7">

                    <!-- ✅ 로그인 폼 -->
                    <div id="loginForm">
                        <h4 class="mb-3 fw-bold">로그인</h4>

                        <form method="post" action="<%=root%>/login/loginAction.jsp">
                            <div class="mb-3">
                                <input type="text" name="userid" class="form-control" placeholder="아이디" required>
                            </div>
                            <div class="mb-3">
                                <input type="password" name="passwd" class="form-control" placeholder="비밀번호" required>
                            </div>

                            <div class="mb-3 form-check">
                                <input type="checkbox" class="form-check-input" id="rememberId">
                                <label class="form-check-label" for="rememberId">아이디 저장</label>
                                <span class="ms-3 small"> 
                                    <a href="#">아이디 찾기</a> | 
                                    <a href="#">비밀번호 재설정</a> | 
                                    <a href="#" onclick="showJoin()">회원가입</a>
                                </span>
                            </div>

                            <button type="submit" class="btn btn-danger w-100">로그인</button>
                        </form>

                        <hr>

                        <div class="d-flex justify-content-center my-3">
                            <a href="https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=Uhipu8CFRcKrmTNw5xie&redirect_uri=http%3A%2F%2Flocalhost%3A8083%2Fhotplace%2Flogin%2FnaverCallback.jsp&state=random_state">
                                <img src="https://static.nid.naver.com/oauth/small_g_in.PNG" alt="네이버 로그인" style="width: 300px; height: 50px;">
                            </a>
                        </div>
                    </div>

                    <!-- ✅ 회원가입 선택 화면 -->
                    <div id="joinSelectForm" style="display: none;">
                        <h4 class="mb-4 text-center fw-bold">회원가입 방법 선택</h4>

                        <!-- 일반 회원가입 -->
                        <button class="btn btn-primary w-100 mb-3" onclick="showNormalJoin()">
                            일반 회원가입
                        </button>

                        <!-- 네이버 간편회원가입 -->
                        <a href="https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=Uhipu8CFRcKrmTNw5xie&redirect_uri=http%3A%2F%2Flocalhost%3A8083%2Fhotplace%2Flogin%2FnaverCallback.jsp&state=random_state"
                           style="display: block; width: 300px; height: 50px; background: #03C75A; border: none; border-radius: 4px; color: white; text-decoration: none; font-size: 16px; font-weight: 500; margin: 0 auto 10px auto;">
                           <img src="https://static.nid.naver.com/oauth/small_g_in.PNG" alt="네이버" style="width: 300px; height: 50px;">
                        </a>
                    </div>

                    <!-- ✅ 일반 회원가입 폼 -->
                    <div id="joinForm" style="display: none;">
                        <jsp:include page="/login/join.jsp" />
                    </div>

                </div>

                <!-- 오른쪽 이미지 영역 -->
                <div class="col-md-5 d-flex align-items-center justify-content-center">
                    <img src="#" alt="안내 이미지" style="max-width: 100%; height: auto;">
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// 로그인 → 회원가입 선택 화면으로 전환
function showJoin() {
    document.getElementById("loginForm").style.display = "none";
    document.getElementById("joinForm").style.display = "none";
    document.getElementById("joinSelectForm").style.display = "block";
}

// 회원가입 선택 화면 → 일반 회원가입 폼으로 전환
function showNormalJoin() {
    document.getElementById("joinSelectForm").style.display = "none";
    document.getElementById("joinForm").style.display = "block";
}

// 일반 회원가입 → 다시 로그인으로 돌아가기 (옵션)
function showLogin() {
    document.getElementById("joinForm").style.display = "none";
    document.getElementById("joinSelectForm").style.display = "none";
    document.getElementById("loginForm").style.display = "block";
}

// 모달이 닫힐 때 항상 로그인 폼으로 초기화
const loginModalEl = document.getElementById('loginModal');
if (loginModalEl) {
  loginModalEl.addEventListener('hidden.bs.modal', function () {
    showLogin();
  });
}
</script>
