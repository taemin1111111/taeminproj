<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="Member.MemberDTO" %>
<%@ page import="Member.MemberDAO" %>
<%@ page import="wishList.WishListDao" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    
    // 로그인하지 않은 경우 처리
    if(loginId == null) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
    
    // 회원 정보 가져오기
    MemberDAO dao = new MemberDAO();
    MemberDTO member = dao.getMember(loginId);
    
    if(member == null) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
    
    // 위시리스트 정보 가져오기
    WishListDao wishDao = new WishListDao();
    List<Map<String, Object>> wishList = wishDao.getWishListWithPlaceInfo(loginId);
    int wishCount = wishDao.getWishListCount(loginId);
%>

<div class="wishlist-full-container">
    <!-- 페이지 헤더 -->
    <div class="wishlist-header-section">
        <div class="wishlist-header-content">
            <div class="wishlist-header-left">
                <h2 class="wishlist-page-title">
                    <i class="bi bi-heart-fill text-danger me-3"></i>
                    전체 위시리스트
                </h2>
                <p class="wishlist-subtitle">내가 찜한 모든 핫플레이스를 한눈에 확인하세요</p>
            </div>
            <div class="wishlist-header-right">
                <div class="wishlist-stats">
                    <span class="wishlist-total-count">
                        <i class="bi bi-collection me-1"></i>
                        총 <strong><%= wishCount %></strong>개의 장소
                    </span>
                </div>
            </div>
        </div>
    </div>

    <!-- 위시리스트 내용 -->
    <div class="wishlist-content-section">
        <% if(wishList.isEmpty()) { %>
            <!-- 빈 위시리스트 -->
            <div class="empty-wishlist-full">
                <div class="empty-wishlist-icon">
                    <i class="bi bi-heart"></i>
                </div>
                <h3 class="empty-wishlist-title">아직 찜한 핫플레이스가 없어요</h3>
                <p class="empty-wishlist-description">
                    마음에 드는 핫플레이스를 찜하고 여기에 모아보세요!
                </p>
                <a href="<%= root %>/index.jsp" class="btn btn-primary btn-lg">
                    <i class="bi bi-search me-2"></i>핫플레이스 둘러보기
                </a>
            </div>
        <% } else { %>
            <!-- 카테고리 필터 버튼 -->
            <div class="wishlist-category-filter">
                <button class="category-filter-btn active" data-category="all">전체</button>
                <button class="category-filter-btn marker-club" data-category="1">C</button>
                <button class="category-filter-btn marker-hunting" data-category="2">H</button>
                <button class="category-filter-btn marker-lounge" data-category="3">L</button>
                <button class="category-filter-btn marker-pocha" data-category="4">P</button>
            </div>
            
            <!-- 위시리스트 그리드 -->
            <div class="wishlist-full-grid">
                <% for(Map<String, Object> wish : wishList) { %>
                    <div class="wishlist-full-card" data-wish-id="<%= wish.get("id") %>" data-category="<%= String.valueOf(wish.get("category_id")) %>">
                        <div class="wishlist-full-card-header">
                            <div class="wishlist-category-section">
                                <% 
                                Object categoryIdObj = wish.get("category_id");
                                if(categoryIdObj != null) { 
                                    int categoryId = (Integer)categoryIdObj;
                                    String categoryName = "";
                                    String categoryClass = "";
                                    
                                    switch(categoryId) {
                                        case 1:
                                            categoryName = "클럽";
                                            categoryClass = "category-club";
                                            break;
                                        case 2:
                                            categoryName = "헌팅포차";
                                            categoryClass = "category-hunting";
                                            break;
                                        case 3:
                                            categoryName = "라운지";
                                            categoryClass = "category-lounge";
                                            break;
                                        case 4:
                                            categoryName = "포차거리";
                                            categoryClass = "category-pocha";
                                            break;
                                        default:
                                            categoryName = "기타";
                                            categoryClass = "";
                                            break;
                                    }
                                %>
                                    <span class="category-badge <%= categoryClass %>"><%= categoryName %></span>
                                <% } %>
                            </div>
                            <div class="wishlist-card-actions">
                                <button class="wishlist-delete-btn" onclick="deleteWish(<%= wish.get("id") %>, <%= wish.get("place_id") %>)" title="위시리스트에서 삭제">
                                    <i class="bi bi-x-lg"></i>
                                </button>
                            </div>
                        </div>
                        
                        <div class="wishlist-full-card-body">
                            <h3 class="wishlist-place-name"><%= wish.get("place_name") %></h3>
                            <p class="wishlist-address">
                                <i class="bi bi-geo-alt me-2"></i>
                                <%= wish.get("address") %>
                            </p>
                            
                            <div class="wishlist-note-section">
                                <div class="wishlist-note-content">
                                    <i class="bi bi-chat-text me-2"></i>
                                    <% 
                                    Object noteObj = wish.get("personal_note");
                                    String personalNote = noteObj != null ? (String)noteObj : null;
                                    if(personalNote == null || personalNote.trim().isEmpty()) { 
                                    %>
                                        <span class="text-muted">메모가 없습니다. 메모를 추가해주세요.</span>
                                    <% } else { %>
                                        <span><%= personalNote %></span>
                                    <% } %>
                                </div>
                                <div class="wishlist-note-actions">
                                    <% if(personalNote == null || personalNote.trim().isEmpty()) { %>
                                        <button class="btn btn-sm btn-outline-primary" onclick="addNote(<%= wish.get("id") %>)">
                                            <i class="bi bi-plus me-1"></i>메모 추가
                                        </button>
                                    <% } else { %>
                                        <button class="btn btn-sm btn-outline-secondary" onclick="addNote(<%= wish.get("id") %>)">
                                            <i class="bi bi-pencil me-1"></i>수정
                                        </button>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="wishlist-date-info">
                                <i class="bi bi-calendar3 me-2"></i>
                                찜한 날짜: <%= wish.get("wish_date").toString().substring(0, 10) %>
                            </div>
                        </div>
                        
                        <div class="wishlist-full-card-footer">
                            <div class="wishlist-action-buttons">
                                <button class="btn btn-outline-primary" onclick="viewOnMap(<%= wish.get("lat") %>, <%= wish.get("lng") %>)">
                                    <i class="bi bi-map me-1"></i>지도에서 보기
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
            
            <!-- 뒤로가기 버튼 -->
            <div class="wishlist-back-section">
                <a href="<%= root %>/index.jsp?main=mypage/mypageMain.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>마이페이지로 돌아가기
                </a>
            </div>
        <% } %>
    </div>
</div>

<!-- 메모 추가/수정 모달 -->
<div class="modal fade" id="noteModal" tabindex="-1" aria-labelledby="noteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="noteModalLabel">메모 추가</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="noteForm">
                    <input type="hidden" id="wishId" name="wishId">
                    <div class="mb-3">
                        <label for="noteContent" class="form-label">메모 내용</label>
                        <textarea class="form-control" id="noteContent" name="noteContent" rows="4" placeholder="이 장소에 대한 메모를 입력해주세요..."></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" onclick="saveNote()">저장</button>
            </div>
        </div>
    </div>
</div>

<script>
// 위시리스트 삭제 함수
function deleteWish(wishId, placeId) {
    if(!confirm('정말로 이 장소를 위시리스트에서 삭제하시겠습니까?')) {
        return;
    }
    
    fetch('<%= root %>/main/wishAction.jsp?action=remove&place_id=' + placeId)
    .then(response => response.json())
    .then(data => {
        if(data.result === true) {
            // 삭제된 카드 제거
            const card = document.querySelector('[data-wish-id="' + wishId + '"]');
            if(card) {
                card.remove();
            }
            
            // 위시리스트 개수 업데이트
            const countElement = document.querySelector('.wishlist-total-count strong');
            if(countElement) {
                const currentCount = parseInt(countElement.textContent);
                countElement.textContent = (currentCount - 1);
            }
            
            // 위시리스트가 비어있으면 빈 상태 표시
            const wishlistGrid = document.querySelector('.wishlist-full-grid');
            if(wishlistGrid && wishlistGrid.children.length === 0) {
                location.reload(); // 페이지 새로고침으로 빈 상태 표시
            }
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

// 지도에서 보기 함수
function viewOnMap(lat, lng) {
    // 메인 페이지로 이동하여 해당 위치를 지도에 표시
    window.location.href = '<%= root %>/index.jsp?lat=' + lat + '&lng=' + lng;
}

// 카테고리 필터 함수
function filterWishlistByCategory(category, clickedBtn) {
    const cards = document.querySelectorAll('.wishlist-full-card');
    const filterBtns = document.querySelectorAll('.category-filter-btn');
    
    // 모든 버튼에서 active 클래스 제거
    filterBtns.forEach(btn => btn.classList.remove('active'));
    
    // 클릭된 버튼에 active 클래스 추가
    clickedBtn.classList.add('active');
    
    cards.forEach(card => {
        const cardCategory = card.getAttribute('data-category');
        
        if (category === 'all' || cardCategory === category) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

// 카테고리 필터 버튼 이벤트 리스너
document.addEventListener('DOMContentLoaded', function() {
    const filterBtns = document.querySelectorAll('.category-filter-btn');
    
    filterBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const category = this.getAttribute('data-category');
            filterWishlistByCategory(category, this);
        });
    });
});



// 메모 추가/수정 함수
function addNote(wishId) {
    document.getElementById('wishId').value = wishId;
    
    // 해당 위시리스트 카드에서 현재 메모 내용 가져오기
    const card = document.querySelector('[data-wish-id="' + wishId + '"]');
    const noteSpan = card.querySelector('.wishlist-note-content span');
    let currentNote = '';
    
    if (noteSpan && !noteSpan.classList.contains('text-muted')) {
        // 메모가 있는 경우: 내용 그대로 사용
        currentNote = noteSpan.textContent;
        document.getElementById('noteModalLabel').textContent = '메모 수정';
    } else {
        // 메모가 없는 경우
        currentNote = '';
        document.getElementById('noteModalLabel').textContent = '메모 추가';
    }
    
    document.getElementById('noteContent').value = currentNote;
    const modal = new bootstrap.Modal(document.getElementById('noteModal'));
    modal.show();
}

// 메모 저장 함수
function saveNote() {
    const wishId = document.getElementById('wishId').value;
    const noteContent = document.getElementById('noteContent').value;
    
    if (!noteContent.trim()) {
        alert('메모 내용을 입력해주세요.');
        return;
    }
    
    // AJAX로 메모 저장
    fetch('<%= root %>/mypage/noteAction.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: 'wishId=' + encodeURIComponent(wishId) + '&noteContent=' + encodeURIComponent(noteContent)
    })
    .then(response => response.json())
    .then(data => {
        if (data.result === true) {
            // 모달 닫기
            const modal = bootstrap.Modal.getInstance(document.getElementById('noteModal'));
            modal.hide();
            
            // 페이지 새로고침으로 업데이트된 메모 표시
            location.reload();
        } else {
            alert('메모 저장에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('메모 저장 중 오류가 발생했습니다.');
    });
}
</script>

<link rel="stylesheet" href="<%=root%>/css/mypage.css">