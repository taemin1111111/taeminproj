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
            <div class="input-group">
                <input type="text" name="nickname" id="nickname" class="form-control" placeholder="닉네임" required>
                <button type="button" class="btn btn-outline-secondary" onclick="checkNickname()">중복확인</button>
            </div>
            <div id="nickCheckResult" class="mt-1 small"></div>
        </div>



        <!-- 이메일 (이메일 필수 + 인증코드 발송) -->
        <div class="mb-3">
            <div class="input-group">
                <input type="email" name="email" id="email" class="form-control" placeholder="이메일" required>
                <button type="button" class="btn btn-outline-primary" onclick="sendEmailCode()">인증요청</button>
            </div>
            <div id="emailResult" class="mt-1 small"></div>
        </div>

        <!-- 이메일 인증코드 입력 -->
        <div class="mb-3">
            <div class="input-group">
                
                <input type="text" id="emailCodeInput" class="form-control" placeholder="이메일 인증코드 입력" disabled>
                <button type="button" class="btn btn-outline-success" onclick="verifyEmailCode()" disabled>확인</button>
            </div>
            <div id="emailCodeResult" class="mt-1 small"></div>
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
// ✅ 아이디 중복확인 (AJAX 연결)
function checkId() {
    const userid = document.getElementById("userid").value.trim();
    if(userid.length < 4) {
        document.getElementById("idCheckResult").textContent = "아이디는 최소 4자 이상 입력해주세요.";
        document.getElementById("idCheckResult").style.color = "red";
        return;
    }
    fetch("<%=root%>/login/idCheck.jsp?userid=" + encodeURIComponent(userid))
        .then(res => res.text())
        .then(result => {
            if (result.trim() === "ok") {
                document.getElementById("idCheckResult").textContent = "사용가능한 아이디입니다.";
                document.getElementById("idCheckResult").style.color = "green";
            } else {
                document.getElementById("idCheckResult").textContent = "이미 사용중인 아이디입니다.";
                document.getElementById("idCheckResult").style.color = "red";
            }
        });
}

// ✅ 닉네임 중복확인 (AJAX 연결)
function checkNickname() {
    const nickname = document.getElementById("nickname").value.trim();
    if(nickname === "") {
        document.getElementById("nickCheckResult").textContent = "닉네임을 입력하세요.";
        document.getElementById("nickCheckResult").style.color = "red";
        return;
    }
    fetch("<%=root%>/login/nickCheck.jsp?nickname=" + encodeURIComponent(nickname))
        .then(res => res.text())
        .then(result => {
            if (result.trim() === "ok") {
                document.getElementById("nickCheckResult").textContent = "사용가능한 닉네임입니다.";
                document.getElementById("nickCheckResult").style.color = "green";
            } else {
                document.getElementById("nickCheckResult").textContent = "이미 사용중인 닉네임입니다.";
                document.getElementById("nickCheckResult").style.color = "red";
                document.getElementById("nickname").value = "";
                document.getElementById("nickname").focus();
            }
        });
}

// ✅ 이메일 인증코드 발송
function sendEmailCode() {
    const email = document.getElementById("email").value.trim();
    if(email === "") {
        document.getElementById("emailResult").innerText = "이메일을 입력하세요.";
        document.getElementById("emailResult").style.color = "red";
        return;
    }
    
    // 이메일 형식 검증
    const emailRegex = /^[A-Za-z0-9+_.-]+@(.+)$/;
    if (!emailRegex.test(email)) {
        document.getElementById("emailResult").innerText = "올바른 이메일 형식이 아닙니다.";
        document.getElementById("emailResult").style.color = "red";
        return;
    }
    
    // 버튼 비활성화
    const button = event.target;
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = "발송중...";
    
    fetch("<%=root%>/login/sendEmailVerification.jsp", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: "email=" + encodeURIComponent(email)
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            document.getElementById("emailResult").innerText = data.message;
            document.getElementById("emailResult").style.color = "green";
            // 인증코드 입력 필드와 확인 버튼 활성화
            document.getElementById("emailCodeInput").disabled = false;
            document.getElementById("emailCodeInput").focus();
            document.querySelector('button[onclick="verifyEmailCode()"]').disabled = false;
        } else {
            document.getElementById("emailResult").innerText = data.message;
            document.getElementById("emailResult").style.color = "red";
        }
    })
    .catch(error => {
        document.getElementById("emailResult").innerText = "오류가 발생했습니다.";
        document.getElementById("emailResult").style.color = "red";
    })
    .finally(() => {
        // 버튼 다시 활성화
        button.disabled = false;
        button.textContent = originalText;
    });
}

// ✅ 이메일 인증코드 확인
function verifyEmailCode() {
    const email = document.getElementById("email").value.trim();
    const code = document.getElementById("emailCodeInput").value.trim();
    
    if(email === "") {
        document.getElementById("emailCodeResult").innerText = "이메일을 먼저 입력하세요.";
        document.getElementById("emailCodeResult").style.color = "red";
        return;
    }
    
    if(code === "") {
        document.getElementById("emailCodeResult").innerText = "인증코드를 입력하세요.";
        document.getElementById("emailCodeResult").style.color = "red";
        return;
    }
    
    // 버튼 비활성화
    const button = event.target;
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = "확인중...";
    
    fetch("<%=root%>/login/verifyEmailCode.jsp", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: "email=" + encodeURIComponent(email) + "&code=" + encodeURIComponent(code)
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            document.getElementById("emailCodeResult").innerText = data.message;
            document.getElementById("emailCodeResult").style.color = "green";
            // 인증 완료 표시
            document.getElementById("email").readOnly = true;
            document.getElementById("emailCodeInput").readOnly = true;
            // 이메일 인증 완료 플래그 설정
            window.emailVerified = true;
        } else {
            document.getElementById("emailCodeResult").innerText = data.message;
            document.getElementById("emailCodeResult").style.color = "red";
        }
    })
    .catch(error => {
        document.getElementById("emailCodeResult").innerText = "오류가 발생했습니다.";
        document.getElementById("emailCodeResult").style.color = "red";
    })
    .finally(() => {
        // 버튼 다시 활성화
        button.disabled = false;
        button.textContent = originalText;
    });
}

// ✅ 비밀번호 검증
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

// ✅ 비밀번호 일치검사
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

// ✅ 최종 submit 전 검증
function checkBeforeSubmit() {
    if (pwRuleResult.style.color !== "green" || pwCheckResult.style.color !== "green") {
        alert("비밀번호 조건 또는 비밀번호 확인을 다시 확인하세요.");
        return false;
    }
    
    // 이메일 인증 확인
    if (!window.emailVerified) {
        alert("이메일 인증을 완료해주세요.");
        return false;
    }
    
    return true;
}
</script>
