<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="modal fade" id="reviewModal" tabindex="-1"
	aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content modal-review">
			<form id="reviewForm">
				<div class="modal-body">
					<h5 class="modal-title mb-4"
						style="font-weight: 700; color: var(--accent-pink);">후기 작성</h5>

					<!-- 지역정보 (loadRegionData 호출시 세팅됨) -->
					<input type="hidden" name="region" id="regionInput"> <input
						type="hidden" name="isSigungu" id="isSigunguInput"> <input
						type="hidden" name="hg_id" id="hgIdInput"> <input
						type="hidden" name="userid"
						value="<%= session.getAttribute("loginid") != null ? session.getAttribute("loginid") : request.getRemoteAddr() %>">

					<div class="mb-3">
						<label class="form-label">닉네임</label> <input type="text"
							name="nickname" class="form-control"
							value="<%= session.getAttribute("nickname") != null ? session.getAttribute("nickname") : "" %>"
							<%= session.getAttribute("nickname") != null ? "readonly" : "" %>
							placeholder="닉네임을 입력하세요" required>
					</div>

					<div class="mb-3">
						<label class="form-label">비밀번호 (삭제용)</label> <input
							type="password" name="passwd" class="form-control" required>
					</div>

					<div class="mb-3">
						<label class="form-label">카테고리</label> <select name="category_id"
							class="form-select" required>
							<option value="">선택하세요</option>
							<option value="1">클럽</option>
							<option value="2">헌팅포차</option>
							<option value="3">라운지</option>
						</select>
					</div>

					<div class="mb-3">
						<label class="form-label">별점</label> <select name="stars"
							class="form-select" required>
							<option value="">평점을 선택하세요</option>
							<% for (double i = 5.0; i >= 0.5; i -= 0.5) { %>
							<option value="<%= i %>"><%= i %></option>
							<% } %>
						</select>
					</div>

					<div class="mb-3">
						<label class="form-label">후기 내용</label>
						<textarea name="content" class="form-control" rows="4"
							placeholder="내용을 입력하세요..." required></textarea>
					</div>
				</div>

				<div class="modal-footer">
					<button type="submit" class="btn btn-primary">등록</button>
					<button type="button" class="btn btn-secondary"
						data-bs-dismiss="modal">닫기</button>
				</div>
			</form>
		</div>
	</div>
</div>

<script>
document.getElementById("reviewForm").addEventListener("submit", function(e) {
    e.preventDefault();

    // FormData 생성
    const formData = new FormData(this);

    // FormData → URLSearchParams 로 변환
    const params = new URLSearchParams(formData);

    
    // fetch로 POST 요청 보내기
    fetch("<%=request.getContextPath()%>/review/ReviewAction.jsp", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded" // ✅ 핵심
        },
        body: params.toString() // ✅ 핵심
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            const reviewModal = bootstrap.Modal.getInstance(document.getElementById("reviewModal"));
            reviewModal.hide();

            loadRegionData(formData.get("region"), formData.get("isSigungu"));

            showToast("후기 등록 성공!", "success");
        } else {
            showToast(data.message, "error");
        }
    })
    .catch(err => {
        console.error(err);
        showToast("서버 오류 발생", "error");
    });
});
</script>
