<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="review.ReviewDao" %>
<%@ page import="java.util.*" %>

<%
    String region = request.getParameter("region");
    boolean isSigungu = Boolean.parseBoolean(request.getParameter("isSigungu"));

    ReviewDao dao = new ReviewDao();
    double avg = isSigungu ? dao.getAverageStarsBySigungu(region) : dao.getAverageStars(region);
    int count = isSigungu ? dao.getReviewCountBySigungu(region) : dao.getReviewCount(region);

    String displayTitle = region + (isSigungu ? " 전체 평점" : " 평점");
    String userid = session.getAttribute("myid") != null ? (String) session.getAttribute("myid") : request.getRemoteAddr();
    String sessionNickname = (String) session.getAttribute("nickname");

    // ✅ 세션 메시지 (토스트용)
    String msg = (String) session.getAttribute("msg");
    String msgType = (String) session.getAttribute("msgType");
    session.removeAttribute("msg");
    session.removeAttribute("msgType");
%>

<!-- ✅ 토스트 -->
<div id="toast" style="position:fixed; top:20px; left:50%; transform:translateX(-50%); 
    z-index:9999; display:none; padding:15px 30px; border-radius:5px; font-weight:bold; color:#fff;"></div>

<script>
<% if (msg != null) { %>
  const toast = document.getElementById("toast");
  toast.innerText = "<%= msg %>";
  toast.style.backgroundColor = "<%= "success".equals(msgType) ? "#28a745" : "#dc3545" %>";
  toast.style.display = "block";
  setTimeout(() => toast.style.display = "none", 2000);
<% } %>
</script>

<!-- 평점 박스 -->
<div class="card-box mb-4 position-relative">
  <div class="d-flex align-items-center mb-2">
    <img src="<%=request.getContextPath()%>/logo/gps.png" alt="위치" width="30" class="me-2">
    <h4 class="mb-0" style="font-weight:700; font-size:1.25rem; color:var(--text-main);">
      <%= displayTitle %>
    </h4>
  </div>

  <p class="mb-1" style="color:var(--text-sub);">
    평균 평점:
    <% for(int i=1; i<=5; i++){ %>
      <i class="bi <%= (avg >= i) ? "bi-star-fill" : (avg >= i-0.5 ? "bi-star-half" : "bi-star") %>" style="color: var(--star-active);"></i>
    <% } %> (<%= String.format("%.1f", avg) %>)
  </p>

  <p class="mb-2" style="color:var(--text-sub);">후기 수: <%= count %>건</p>

  <% if (!isSigungu) { %>
    <button class="btn btn-sm btn-outline-primary" style="position:absolute; bottom:1rem; right:1rem;" data-bs-toggle="modal" data-bs-target="#reviewModal">
      후기 작성
    </button>
  <% } %>

  <hr class="divider">
  <% if (count == 0) { %>
  <div class="d-flex align-items-center justify-content-center mb-3">
    <img src="<%=request.getContextPath()%>/logo/thank.png" alt="감사 아이콘" width="80" class="me-3">
    <p class="text-muted mb-0 fs-5 text-center">
      아직 등록된 평점이 없습니다.<br>소중한 첫 평점을 남겨주세요!
    </p>
  </div>
  <% } %>
</div>

<!-- ✅ 후기 작성 모달 -->
<div class="modal fade" id="reviewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content modal-review">
      <form action="<%=request.getContextPath()%>/gpa/ReviewAction.jsp" method="post">
        <div class="modal-body">
          <h5 class="modal-title mb-4" style="font-weight:700; color:var(--accent-pink);"><%= region %> 후기 작성</h5>

          <!-- 리다이렉트용 파라미터 -->
          <input type="hidden" name="region" value="<%= region %>">
          <input type="hidden" name="isSigungu" value="<%= isSigungu %>">

          <!-- DB insert용 -->
          <input type="hidden" name="hg_id" value="<%= region %>">
          <input type="hidden" name="userid" value="<%= userid %>">

          <div class="mb-3">
            <label class="form-label">닉네임</label>
            <input type="text" name="nickname" class="form-control"
              value="<%= sessionNickname != null ? sessionNickname : "" %>"
              <%= sessionNickname != null ? "readonly" : "" %>
              placeholder="<%= sessionNickname != null ? "" : "닉네임을 입력해주세요" %>" required>
          </div>

          <div class="mb-3">
            <label class="form-label">비밀번호 (삭제용)</label>
            <input type="password" name="passwd" class="form-control" required>
          </div>

          <div class="mb-3">
            <label class="form-label">카테고리</label>
            <select name="category_id" class="form-select" required>
              <option value="">선택하세요</option>
              <option value="1">클럽</option>
              <option value="2">헌팅포차</option>
              <option value="3">라운지</option>
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label">별점</label>
            <select name="stars" class="form-select" required>
              <option value="">평점을 선택하세요</option>
              <% for (double i = 5.0; i >= 0.5; i -= 0.5) { %>
                <option value="<%= i %>"><%= i %>점</option>
              <% } %>
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label">후기 내용</label>
            <textarea name="content" class="form-control" rows="4" placeholder="내용을 입력하세요..." required></textarea>
          </div>
        </div>

        <div class="modal-footer">
          <button type="submit" class="btn btn-primary">등록</button>
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
        </div>
      </form>
    </div>
  </div>
</div>
