<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="CCategory.CCategoryDao" %>
<%@ page import="CCategory.CCategoryDto" %>

<%
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
                    <% } else if(cat.getName().contains("코스추천")) { %>
                        🗺️
                    <% } else if(cat.getName().contains("같이갈래")) { %>
                        👥
                    <% } else { %>
                        📝
                    <% } %>
                </div>
                <h3 class="category-name"><%= cat.getName() %></h3>
                <p class="category-description">
                    <% if(cat.getName().contains("헌팅썰")) { %>
                        헌팅 관련 이야기와 경험을 공유해보세요.
                    <% } else if(cat.getName().contains("코스추천")) { %>
                        좋은 코스와 장소를 추천해보세요.
                    <% } else if(cat.getName().contains("같이갈래")) { %>
                        함께 갈 사람을 찾아보세요.
                    <% } else { %>
                        다양한 주제로 이야기를 나누는 공간입니다.
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
    let url = '';
    if (categoryName.includes('헌팅썰')) url = 'hpost_list.jsp';
    else if (categoryName.includes('코스추천')) url = 'hroot_list.jsp';
    else if (categoryName.includes('같이갈래')) url = 'hfriend_list.jsp';
    else url = 'hpost_list.jsp';

    fetch(url)
        .then(res => res.text())
        .then(html => {
            container.innerHTML = html;
        })
        .catch(() => {
            container.innerHTML = '<div class="error-message"><p>글을 불러오는데 실패했습니다.</p></div>';
        });
}

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