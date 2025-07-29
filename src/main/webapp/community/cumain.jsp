<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="CCategory.CCategoryDao" %>
<%@ page import="CCategory.CCategoryDto" %>

<%
    String root = request.getContextPath();
    CCategoryDao dao = new CCategoryDao();
    List<CCategoryDto> categories = dao.getAllCategories();
%>

<div class="community-container">
    <!-- 환영 메시지 -->
    <div class="community-welcome">
        <h1 class="welcome-title">🎉 커뮤니티에 오신 것을 환영합니다!</h1>
        <p class="welcome-text">
            다양한 주제로 이야기를 나누고, 정보를 공유해보세요.<br>
            여러분의 소중한 경험과 이야기가 다른 분들에게 도움이 됩니다.
        </p>
    </div>

    <!-- 카테고리 헤더 -->
    <div class="community-header">
        <h2 class="community-title">💬 이야기 나누기</h2>
        <p class="community-subtitle">관심 있는 주제를 선택해보세요</p>
    </div>

    <!-- 카테고리 그리드 -->
    <div class="category-grid">
        <% for(CCategoryDto cat : categories) { %>
            <div class="category-card" data-category-id="<%= cat.getId() %>">
                <div class="category-icon">
                    <% if(cat.getName().contains("헌팅썰")) { %>
                        ❤️
                    <% } else if(cat.getName().contains("코스 추천")) { %>
                        🗺️
                    <% } else if(cat.getName().contains("같이 갈래")) { %>
                        👥
                    <% } %>
                </div>
                <h3 class="category-name"><%= cat.getName() %></h3>
                <p class="category-description">
                    <% if(cat.getName().contains("헌팅썰")) { %>
                        헌팅 관련 이야기와 경험을 공유해보세요.
                    <% } else if(cat.getName().contains("코스 추천")) { %>
                        이 게시판은 직접 다녀온 핫플 이동 코스를 공유하는 공간입니다.<br>
                        어떤 지역에서 어디를 먼저 가고, 다음엔 어디로 갔는지,<br>
                        장소별 분위기나 사람들 반응까지 솔직하게 풀어줘!
                    <% } else if(cat.getName().contains("같이 갈래")) { %>
                        혼자 놀긴 아쉽고, 같이 가면 더 핫한 밤!<br>
                        오늘 같이 놀 사람? 주말에 클럽갈 멤버?<br>
                        오픈채팅, 파티 모집, 원데이 크루 구인까지<br>
                        당신의 다음 핫한 밤을 함께할 사람을 여기서 찾아봐.
                    <% } %>
                </p>
                <button class="category-btn" onclick="loadCategoryPosts(<%= cat.getId() %>, '<%= cat.getName() %>')">
                    들어가기 →
                </button>
            </div>
        <% } %>
    </div>

    <!-- 구분선 -->
    <div class="community-divider">
        <hr>
        <span class="divider-text">📝 최근 글 목록</span>
    </div>

    <!-- 글 목록 영역 -->
    <div class="posts-section">
        <div id="posts-container">
            <!-- 기본: 첫 번째 카테고리 글 목록을 서버사이드로 렌더링해서 보여줌 -->
            <%-- JS에서 AJAX로 동적으로 변경됨 --%>
            <%-- 최초 로딩 시에는 헌팅썰(hpost_list.jsp) 불러오기 --%>
            <jsp:include page="hpost_list.jsp" />
        </div>
    </div>
</div>

<script>
function loadCategoryPosts(categoryId, categoryName) {
    const container = document.getElementById('posts-container');
    container.innerHTML = '<div class="loading-message"><p>글을 불러오는 중...</p></div>';

    // 카테고리 카드 스타일 업데이트
    const allCards = document.querySelectorAll('.category-card');
    allCards.forEach(card => card.classList.remove('active'));
    const selectedCard = document.querySelector(`[data-category-id="${categoryId}"]`);
    if (selectedCard) selectedCard.classList.add('active');

    // 구분선 텍스트 업데이트
    const dividerText = document.querySelector('.divider-text');
    if (dividerText) dividerText.textContent = `📝 ${categoryName} 글 목록`;

    // AJAX로 해당 카테고리 글 목록 JSP 불러오기
    if (categoryName.includes('헌팅썰')) {
        fetch('<%=root%>/community/hpost_list.jsp')
            .then(res => res.text())
            .then(html => {
                container.innerHTML = html;
            })
            .catch(() => {
                container.innerHTML = '<div class="error-message"><p>글을 불러오는데 실패했습니다.</p></div>';
            });
    } else if (categoryName.includes('코스 추천')) {
        container.innerHTML = `
            <div class="category-posts">
                <h3 class="posts-category-title">🗺️ 코스추천</h3>
                <div class="posts-list">
                    <div class="no-posts">
                        <p>코스추천 기능은 준비 중입니다.</p>
                    </div>
                </div>
            </div>
        `;
    } else if (categoryName.includes('같이 갈래')) {
        container.innerHTML = `
            <div class="category-posts">
                <h3 class="posts-category-title">👥 같이갈래</h3>
                <div class="posts-list">
                    <div class="no-posts">
                        <p>같이갈래 기능은 준비 중입니다.</p>
                    </div>
                </div>
            </div>
        `;
    }
}

// 글 상세보기 로드 함수
function loadPostDetail(postId) {
    const container = document.getElementById('posts-container');
    container.innerHTML = '<div class="loading-message"><p>글을 불러오는 중...</p></div>';
    
    fetch('<%=root%>/community/hpost_detail.jsp?id=' + postId)
        .then(response => response.text())
        .then(html => {
            container.innerHTML = html;
        })
        .catch(() => {
            container.innerHTML = '<div class="error-message"><p>글을 불러오는데 실패했습니다.</p></div>';
        });
}

// 사진 미리보기 함수 정의 (전역 함수로 한 번만 정의)
window.updatePhotoPreview = function(input, photoId) {
    const textElement = document.getElementById(photoId + '-text');
    const previewElement = document.getElementById(photoId + '-preview');
    const file = input.files[0];
    
    if (file) {
        // 사진 미리보기로 버튼 변경
        const reader = new FileReader();
        reader.onload = function(e) {
            previewElement.src = e.target.result;
            previewElement.style.display = 'block';
            textElement.style.display = 'none';
        };
        reader.readAsDataURL(file);
    } else {
        // 파일이 없으면 기본 텍스트로 복원
        textElement.textContent = '+';
        textElement.style.display = 'block';
        previewElement.style.display = 'none';
        textElement.style.color = '#666';
        textElement.style.fontWeight = 'normal';
    }
};

// 페이지 로드 시 첫 번째 카테고리 자동 선택
window.addEventListener('DOMContentLoaded', function() {
    const firstCard = document.querySelector('.category-card');
    if (firstCard) {
        const categoryId = firstCard.getAttribute('data-category-id');
        const categoryName = firstCard.querySelector('.category-name').textContent;
        loadCategoryPosts(categoryId, categoryName);
    }
});
</script>