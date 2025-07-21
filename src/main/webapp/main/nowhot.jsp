<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*, hotplace_info.*, Category.*" %>
<%
    String root = request.getContextPath();
    HotplaceDao hotplaceDao = new HotplaceDao();
    CategoryDao categoryDao = new CategoryDao();
    List<CategoryDto> categoryList = categoryDao.getAllCategories();
%>

<h5 class="fw-bold mb-3">🔥 지금 핫한 투표</h5>

<!-- 클럽 정보 부분 (동적으로 변경됨) -->
<div id="hotplaceInfoSection">
  <div id="voteGuide" class="vote-guide-container">
    <i class="bi bi-geo-alt vote-guide-icon"></i>
    <div class="vote-guide-title">먼저 지도를 클릭해서</div>
    <div class="vote-guide-title">위치를 선택해주세요 !!</div>
    <div class="vote-guide-subtitle">(위치를 선택해야 투표가 가능합니다)</div>
    <button id="pickLocationBtn" class="pick-location-btn">
      <i class="bi bi-geo-alt-fill"></i>
      지정하기
    </button>
  </div>
  
  <div id="hotplaceInfo" class="hotplace-info mb-3 p-3 rounded" style="display: none;">
    <h6 class="fw-bold mb-1" id="voteHotplaceName"></h6>
    <p class="mb-2 small" id="voteHotplaceAddress"></p>
    <span class="badge bg-light text-dark" id="voteCategoryBadge"></span>
  </div>
</div>

<!-- 투표 폼 (항상 보임) -->
<form id="voteForm">
  <input type="hidden" id="voteHotplaceId" name="hotplaceId">
  
  <!-- 1번 질문 -->
  <div class="mb-3">
    <label class="form-label fw-bold">1. 지금 사람 많음?</label>
    <div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="crowd" id="crowd1" value="1">
        <label class="form-check-label" for="crowd1">한산함</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="crowd" id="crowd2" value="2">
        <label class="form-check-label" for="crowd2">적당함</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="crowd" id="crowd3" value="3">
        <label class="form-check-label" for="crowd3">붐빔</label>
      </div>
    </div>
  </div>

  <!-- 2번 질문 -->
  <div class="mb-3">
    <label class="form-label fw-bold">2. 줄 서야 함? (대기 있음?)</label>
    <div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="wait" id="wait1" value="1">
        <label class="form-check-label" for="wait1">바로입장</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="wait" id="wait2" value="2">
        <label class="form-check-label" for="wait2">10분정도</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="wait" id="wait3" value="3">
        <label class="form-check-label" for="wait3">30분</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="wait" id="wait4" value="4">
        <label class="form-check-label" for="wait4">1시간 이상</label>
      </div>
    </div>
  </div>

  <!-- 3번 질문 -->
  <div class="mb-3">
    <label class="form-label fw-bold">3. 남녀 성비 어때?</label>
    <div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="gender" id="gender1" value="1">
        <label class="form-check-label" for="gender1">여초</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="gender" id="gender2" value="2">
        <label class="form-check-label" for="gender2">반반</label>
      </div>
      <div class="form-check form-check-inline">
        <input class="form-check-input" type="radio" name="gender" id="gender3" value="3">
        <label class="form-check-label" for="gender3">남초</label>
      </div>
    </div>
  </div>

  <button type="submit" class="btn btn-primary btn-sm w-100">
    <i class="bi bi-fire"></i> 투표하기
  </button>
</form>

<script>
// 폼/섹션 상태 관리
let pickMode = false;

// 지정하기 버튼 클릭 시 지도에 포커스(번쩍)
document.getElementById('pickLocationBtn').onclick = function() {
  pickMode = true;
  // 지도 번쩍 효과 (투명한 트렌디한 핑크) - 3번 반복
  const mapDiv = window.parent ? window.parent.document.getElementById('map') : document.getElementById('map');
  if (mapDiv) {
    let count = 0;
    const blinkInterval = setInterval(() => {
      // 인라인 스타일로 직접 적용
      mapDiv.style.boxShadow = '0 0 0 4px rgba(255, 20, 147, 0.3), 0 0 20px 8px rgba(255, 20, 147, 0.2), 0 0 40px 16px rgba(255, 20, 147, 0.1)';
      setTimeout(() => { 
        mapDiv.style.boxShadow = ''; 
      }, 200);
      count++;
      if (count >= 3) {
        clearInterval(blinkInterval);
      }
    }, 400);
  }
};

// 외부에서 호출: 마커 클릭 시 클럽 정보만 변경
function showVoteForm(hotplaceId, name, address, categoryId) {
  // pickMode 체크 제거
  // 클럽 정보 부분만 변경
  document.getElementById('voteGuide').style.display = 'none';
  document.getElementById('hotplaceInfo').style.display = 'block';
  pickMode = false;

  document.getElementById('voteHotplaceId').value = hotplaceId;
  document.getElementById('voteHotplaceName').textContent = name;
  document.getElementById('voteHotplaceAddress').textContent = address;
  var categoryNames = { 1: '클럽', 2: '헌팅', 3: '라운지', 4: '포차' };
  document.getElementById('voteCategoryBadge').textContent = categoryNames[categoryId] || '';
  document.getElementById('voteForm').reset();
}

// 투표 폼 제출
document.getElementById('voteForm').addEventListener('submit', function(e) {
  e.preventDefault();
  const hotplaceId = document.getElementById('voteHotplaceId').value;
  const crowd = document.querySelector('input[name="crowd"]:checked');
  const wait = document.querySelector('input[name="wait"]:checked');
  const gender = document.querySelector('input[name="gender"]:checked');
  if (!hotplaceId) {
    alert('위치를 먼저 선택해주세요!');
    return;
  }
  if (!crowd || !wait || !gender) {
    alert('모든 항목을 선택해주세요!');
    return;
  }
  const formData = new FormData();
  formData.append('hotplaceId', hotplaceId);
  formData.append('crowd', crowd.value);
  formData.append('wait', wait.value);
  formData.append('gender', gender.value);
  fetch('<%=root%>/main/voteAction.jsp', {
    method: 'POST',
    body: formData
  })
  .then(response => {
    if (response.ok) {
      alert('투표가 완료되었습니다!');
      // 클럽 정보 부분을 다시 초기 상태로
      document.getElementById('hotplaceInfo').style.display = 'none';
      document.getElementById('voteGuide').style.display = 'block';
      document.getElementById('voteForm').reset();
    } else {
      alert('투표 처리 중 오류가 발생했습니다.');
    }
  })
  .catch(error => {
    console.error('Error:', error);
    alert('투표 처리 중 오류가 발생했습니다.');
  });
});
</script>