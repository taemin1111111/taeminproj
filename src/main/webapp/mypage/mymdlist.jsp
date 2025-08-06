<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="MD.MdWishDao" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    
    // 로그인하지 않은 경우 처리
    if(loginId == null) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
    
    // 내가 찜한 MD 정보 가져오기
    MdWishDao mdWishDao = new MdWishDao();
    List<Map<String, Object>> myMdWishes = mdWishDao.getUserMdWishesWithInfo(loginId, 1000); // 모든 MD 가져오기
    int mdWishCount = mdWishDao.getUserMdWishCount(loginId);
%>

<div class="mymdlist-container">
    <!-- 헤더 섹션 -->
    <div class="mymdlist-header">
        <div class="header-content">
            <h1 class="mymdlist-title">
                <i class="bi bi-collection-heart-fill text-danger me-3"></i>
                내가 소장한 MD
            </h1>
            <p class="mymdlist-subtitle">소중한 MD 컬렉션을 관리해보세요</p>
            <div class="mymdlist-stats">
                <span class="stat-item">
                    <i class="bi bi-heart-fill text-danger"></i>
                    총 <strong><%= mdWishCount %></strong>개의 MD
                </span>
            </div>
        </div>
    </div>

    <!-- MD 컬렉션 섹션 -->
    <div class="md-collection-section">
        <% if(myMdWishes.isEmpty()) { %>
            <div class="empty-collection">
                <div class="empty-icon">
                    <i class="bi bi-collection-heart"></i>
                </div>
                <h3 class="empty-title">아직 소장한 MD가 없어요</h3>
                <p class="empty-description">첫 번째 MD를 소장해보세요!</p>
                <a href="<%= root %>/index.jsp?main=clubmd/clubmd.jsp" class="btn btn-primary btn-lg">
                    <i class="bi bi-search me-2"></i>MD 둘러보기
                </a>
            </div>
        <% } else { %>
            <div class="md-collection-grid">
                <% for(Map<String, Object> mdWish : myMdWishes) { %>
                    <div class="md-collection-card" data-md-id="<%= mdWish.get("mdId") %>">
                        <!-- 카드 헤더 -->
                        <div class="card-header-section">
                            <div class="md-badge">
                                <span class="badge bg-primary">MD</span>
                            </div>
                            <button class="remove-md-btn" onclick="removeFromCollection(<%= mdWish.get("mdId") %>)" title="컬렉션에서 제거">
                                <i class="bi bi-x-circle-fill"></i>
                            </button>
                        </div>
                        
                        <!-- MD 사진 -->
                        <div class="md-image-section">
                            <% if(mdWish.get("photo") != null && !mdWish.get("photo").toString().isEmpty()) { %>
                                <img src="<%= root %>/mdphotos/<%= mdWish.get("photo") %>" alt="MD 사진" class="md-image">
                            <% } else { %>
                                <div class="md-image-placeholder">
                                    <i class="bi bi-person-circle"></i>
                                </div>
                            <% } %>
                        </div>
                        
                        <!-- MD 정보 -->
                        <div class="md-info-section">
                            <h3 class="md-name"><%= mdWish.get("mdName") %></h3>
                            
                            <div class="md-location">
                                <i class="bi bi-geo-alt-fill text-primary"></i>
                                <span class="place-name"><%= mdWish.get("placeName") %></span>
                            </div>
                            
                            <div class="md-address">
                                <i class="bi bi-map text-muted"></i>
                                <small class="address-text"><%= mdWish.get("address") %></small>
                            </div>
                            
                            <% if(mdWish.get("contact") != null && !mdWish.get("contact").toString().isEmpty()) { %>
                                <div class="md-contact">
                                    <i class="bi bi-telephone-fill text-success"></i>
                                    <span class="contact-text"><%= mdWish.get("contact") %></span>
                                </div>
                            <% } %>
                            
                            <% if(mdWish.get("description") != null && !mdWish.get("description").toString().isEmpty()) { %>
                                <div class="md-description">
                                    <p class="description-text"><%= mdWish.get("description") %></p>
                                </div>
                            <% } %>
                        </div>
                        
                        <!-- 소장 정보 -->
                        <div class="collection-info">
                            <div class="collection-date">
                                <i class="bi bi-calendar-heart text-danger"></i>
                                <span>소장일: <%= mdWish.get("createdAt").toString().substring(0, 10) %></span>
                            </div>
                        </div>
                        
                        <!-- 액션 버튼 -->
                        <div class="md-actions">
                            <button class="btn btn-outline-primary btn-sm" onclick="viewOnMap('<%= mdWish.get("placeName") %>', '<%= mdWish.get("address") %>')">
                                <i class="bi bi-map me-1"></i>지도에서 보기
                            </button>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</div>

<script>
// 컬렉션에서 MD 제거
function removeFromCollection(mdId) {
    if (!confirm('정말로 이 MD를 컬렉션에서 제거하시겠습니까?')) {
        return;
    }
    
    fetch('<%= root %>/clubmd/mdWishAction.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=remove&mdId=' + mdId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // 제거된 카드 애니메이션과 함께 제거
            const card = document.querySelector(`[data-md-id="${mdId}"]`);
            if (card) {
                card.style.transform = 'scale(0.8)';
                card.style.opacity = '0';
                setTimeout(() => {
                    card.remove();
                    
                    // 카드가 없어지면 빈 상태 표시
                    const grid = document.querySelector('.md-collection-grid');
                    if (grid && grid.children.length === 0) {
                        location.reload();
                    }
                }, 300);
            }
            
            // 통계 업데이트
            const statElement = document.querySelector('.mymdlist-stats .stat-item strong');
            if (statElement) {
                const currentCount = parseInt(statElement.textContent);
                statElement.textContent = (currentCount - 1);
            }
        } else {
            alert(data.message || 'MD 제거에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('MD 제거 중 오류가 발생했습니다.');
    });
}

// 지도에서 보기
function viewOnMap(placeName, address) {
    window.location.href = '<%= root %>/index.jsp?search=' + encodeURIComponent(placeName + ' ' + address);
}
</script>

<link rel="stylesheet" href="<%=root%>/css/mypage.css">