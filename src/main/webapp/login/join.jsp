<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String root = request.getContextPath();
%>

<div class="container my-4" style="max-width: 600px;">
    <h3 class="mb-4 fw-bold text-center">회원가입</h3>

    <form method="post" action="<%=root%>/login/joinAction.jsp" onsubmit="return checkBeforeSubmit()">

        <!-- 아이디 -->
        <div class="mb-3">
            <div class="input-group">
                <input type="text" name="userid" id="userid" class="form-control" placeholder="아이디" required>
                <button type="button" class="btn btn-outline-secondary" onclick="checkId()">중복확인</button>
            </div>
            <div id="idCheckResult" class="mt-1 small"></div>
        </div>

        <!-- 비밀번호 -->
        <div class="mb-3">
            <input type="password" name="passwd" id="passwd" class="form-control" placeholder="비밀번호" required>
            <div id="pwRuleResult" class="mt-1 small"></div>
        </div>

        <!-- 비밀번호 확인 -->
        <div class="mb-3">
            <input type="password" name="passwdConfirm" id="passwdConfirm" class="form-control" placeholder="비밀번호 확인" required>
            <div id="pwCheckResult" class="mt-1 small"></div>
        </div>

        <!-- 이름 -->
        <div class="mb-3">
            <input type="text" name="name" class="form-control" placeholder="이름" required>
        </div>

        <!-- 닉네임 -->
        <div class="mb-3">
            <input type="text" name="nickname" class="form-control" placeholder="닉네임" required>
        </div>

        <!-- 휴대폰번호 -->
        <div class="mb-3">
            <input type="text" name="phone" class="form-control" placeholder="휴대폰번호" required>
        </div>

        <!-- 이메일 -->
        <div class="mb-3">
            <input type="email" name="email" class="form-control" placeholder="이메일 (선택)">
        </div>

        <!-- 생년월일 -->
        <div class="mb-3">
            <input type="date" name="birth" class="form-control">
        </div>

        <!-- 성별 -->
        <div class="mb-3">
            <select name="gender" class="form-select">
                <option value="">성별 선택</option>
                <option value="M">남자</option>
                <option value="F">여자</option>
            </select>
        </div>

        <!-- 약관동의 -->
        <div class="form-check mb-3">
            <input class="form-check-input" type="checkbox" required>
            <label class="form-check-label">이용약관 및 개인정보 수집 동의 (필수)</label>
        </div>

        <button type="submit" class="btn btn-primary w-100">회원가입 완료</button>
    </form>
</div>

<script>
// ✅ 아이디 중복확인 (서버연결은 나중에 AJAX로 추가)
function checkId() {
    const userid = document.getElementById("userid").value;
    if(userid.length < 4) {
        document.getElementById("idCheckResult").textContent = "아이디는 최소 4자 이상 입력해주세요.";
        document.getElementById("idCheckResult").style.color = "red";
        return;
    }
    document.getElementById("idCheckResult").textContent = "사용가능한 아이디입니다.";
    document.getElementById("idCheckResult").style.color = "green";
}

// ✅ 비밀번호 보안규칙 검사
const pwInput = document.getElementById('passwd');
const pwRuleResult = document.getElementById('pwRuleResult');
pwInput.addEventListener("input", function() {
    const regex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\[\]{};':"\\|,.<>\/?]).{10,}$/;
    if (pwInput.value === "") {
        pwRuleResult.textContent = "";
    } else if (regex.test(pwInput.value)) {
        pwRuleResult.textContent = "사용가능한 비밀번호입니다.";
        pwRuleResult.style.color = "green";
    } else {
        pwRuleResult.textContent = "10자 이상, 영문+숫자+특수문자 포함 필수";
        pwRuleResult.style.color = "red";
    }
});

// ✅ 비밀번호 일치 검사 (이제 깔끔하게 수정된 부분)
const pwConfirmInput = document.getElementById('passwdConfirm');
const pwCheckResult = document.getElementById('pwCheckResult');
pwConfirmInput.addEventListener("input", function() {
    if (pwInput.value === "" || pwConfirmInput.value === "") {
        pwCheckResult.textContent = "";
        return;
    }
    if (pwInput.value === pwConfirmInput.value) {
        pwCheckResult.textContent = "비밀번호가 일치합니다.";
        pwCheckResult.style.color = "green";
    } else {
        pwCheckResult.textContent = "비밀번호가 일치하지 않습니다.";
        pwCheckResult.style.color = "red";
    }
});

// ✅ 전송 전 최종검증
function checkBeforeSubmit() {
    if (pwRuleResult.style.color !== "green" || pwCheckResult.style.color !== "green") {
        alert("비밀번호 조건 또는 비밀번호 확인을 다시 확인하세요.");
        return false;
    }
    return true;
}
</script>
