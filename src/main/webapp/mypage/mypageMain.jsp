<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="Member.MemberDTO" %>
<%@ page import="Member.MemberDAO" %>
<%@ page import="wishList.WishListDao" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>
<%@ page import="hottalk_comment.Hottalk_CommentDao" %>
<%@ page import="hottalk_comment.Hottalk_CommentDto" %>
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
    
    // 내가 쓴 게시글 정보 가져오기
    HpostDao postDao = new HpostDao();
    List<HpostDto> myPosts = postDao.getPostsByUserid(loginId, 5); // 최근 5개
    int postCount = postDao.getPostCountByUserid(loginId);
    
    // 내가 쓴 댓글 정보 가져오기
    Hottalk_CommentDao commentDao = new Hottalk_CommentDao();
    List<Hottalk_CommentDto> myComments = commentDao.getCommentsByUserid(loginId, 5); // 최근 5개
    int commentCount = commentDao.getCommentCountByUserid(loginId);
%>

<div class="mypage-container">

    <div class="profile-card">
        <div class="profile-header">
            <div class="profile-avatar">
                <i class="bi bi-person-fill"></i>
            </div>
            <div class="profile-info">
                <h3 class="profile-name"><%= member.getNickname() %></h3>
                <span class="profile-type">
                    <% if("naver".equals(member.getProvider())) { %>
                        <i class="bi bi-check-circle-fill text-success me-1"></i>네이버 계정
                    <% } else { %>
                        <i class="bi bi-check-circle-fill text-primary me-1"></i>일반 계정
                    <% } %>
                </span>
            </div>
        </div>

        <div class="profile-details">
            <div class="detail-item">
                <div class="detail-label">
                    <i class="bi bi-person me-2"></i>닉네임
                </div>
                <div class="detail-value"><%= member.getNickname() %></div>
            </div>

            <div class="detail-item">
                <div class="detail-label">
                    <i class="bi bi-envelope me-2"></i>이메일
                </div>
                <div class="detail-value"><%= member.getEmail() %></div>
            </div>

            <div class="detail-item">
                <div class="detail-label">
                    <i class="bi bi-calendar-event me-2"></i>가입일
                </div>
                <div class="detail-value">
                    <%= member.getRegdate() != null ? member.getRegdate().toString().substring(0, 10) : "정보 없음" %>
                </div>
            </div>

            <div class="detail-item">
                <div class="detail-label">
                    <i class="bi bi-shield-check me-2"></i>로그인 방식
                </div>
                <div class="detail-value">
                    <% if("naver".equals(member.getProvider())) { %>
                        <span class="badge bg-success">네이버 로그인</span>
                    <% } else { %>
                        <span class="badge bg-primary">일반 로그인</span>
                    <% } %>
                </div>
            </div>
        </div>

        <div class="profile-actions">
            <button class="btn btn-outline-primary me-2">
                <i class="bi bi-pencil me-1"></i>정보 수정
            </button>
            <button class="btn btn-outline-danger" onclick="showWithdrawModal()">
                <i class="bi bi-person-x me-1"></i>회원 탈퇴
            </button>
        </div>
    </div>

    <!-- 위시리스트 섹션 -->
    <div class="wishlist-section">
        <div class="wishlist-header">
            <h4 class="wishlist-title">
                <i class="bi bi-heart-fill text-danger me-2"></i>
                내가 찜한 핫플레이스
                <span class="wishlist-count">(<%= wishCount %>개)</span>
            </h4>
        </div>

        <% if(wishList.isEmpty()) { %>
            <div class="empty-wishlist">
                <div class="empty-icon">
                    <i class="bi bi-heart"></i>
                </div>
                <p class="empty-text">아직 찜한 핫플레이스가 없어요</p>
                <a href="<%= root %>/index.jsp" class="btn btn-outline-primary">
                    <i class="bi bi-search me-1"></i>핫플레이스 둘러보기
                </a>
            </div>
        <% } else { %>
            <div class="wishlist-grid">
                <% for(Map<String, Object> wish : wishList) { %>
                    <div class="wishlist-card" data-wish-id="<%= wish.get("id") %>">
                        <div class="wishlist-card-header">
                            <div class="wishlist-category">
                                <% if(wish.get("category_name") != null) { 
                                    String categoryName = (String)wish.get("category_name");
                                    String categoryClass = "";
                                    if(categoryName.contains("클럽")) {
                                        categoryClass = "category-club";
                                    } else if(categoryName.contains("헌팅")) {
                                        categoryClass = "category-hunting";
                                    } else if(categoryName.contains("라운지")) {
                                        categoryClass = "category-lounge";
                                    } else if(categoryName.contains("포차")) {
                                        categoryClass = "category-pocha";
                                    }
                                %>
                                    <span class="category-badge <%= categoryClass %>"><%= categoryName %></span>
                                <% } %>
                            </div>
                            <button class="wishlist-delete-btn" onclick="deleteWish(<%= wish.get("id") %>, <%= wish.get("place_id") %>)">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </div>
                        <div class="wishlist-card-body">
                            <h5 class="wishlist-place-name"><%= wish.get("place_name") %></h5>
                            <p class="wishlist-address">
                                <i class="bi bi-geo-alt me-1"></i>
                                <%= wish.get("address") %>
                            </p>
                            <div class="wishlist-note">
                                <div class="wishlist-note-content">
                                    <i class="bi bi-chat-text me-1"></i>
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
                            <div class="wishlist-date">
                                <i class="bi bi-calendar3 me-1"></i>
                                찜한 날짜: <%= wish.get("wish_date").toString().substring(0, 10) %>
                            </div>
                        </div>
                        <div class="wishlist-card-footer">
                            <button class="btn btn-sm btn-outline-primary" onclick="viewOnMap(<%= wish.get("lat") %>, <%= wish.get("lng") %>)">
                                <i class="bi bi-map me-1"></i>지도에서 보기
                            </button>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
        
        <!-- 전체 위시리스트 보기 버튼 -->
        <div class="wishlist-view-all">
            <a href="<%= root %>/index.jsp?main=mypage/mywishlist.jsp" class="btn btn-outline-primary btn-lg">
                <i class="bi bi-plus-circle me-2"></i>전체 위시 리스트 보기
            </a>
        </div>
    </div>
</div>

<!-- 내가 쓴 게시글 섹션 -->
<div class="my-posts-section">
    <div class="section-header">
        <h3 class="section-title">
            <i class="bi bi-file-text me-2"></i>
            내가 쓴 게시글
        </h3>
        <span class="section-count">총 <strong><%= postCount %></strong>개의 게시글</span>
    </div>
    
    <% if(myPosts.isEmpty()) { %>
        <div class="empty-posts">
            <p class="empty-text">아직 작성한 게시글이 없어요</p>
        </div>
    <% } else { %>
        <div class="posts-list">
            <% for(HpostDto post : myPosts) { %>
                <div class="post-item">
                    <div class="post-header">
                        <span class="post-nickname"><%= post.getNickname() %></span>
                        <span class="post-date"><%= post.getCreated_at().toString().substring(0, 10) %></span>
                    </div>
                    <div class="post-title" onclick="viewPostDetail(<%= post.getId() %>)" style="cursor: pointer;">
                        <%= post.getTitle() %>
                    </div>
                    <div class="post-stats">
                        <span class="stat-item">
                            <i class="bi bi-hand-thumbs-up"></i>
                            <%= post.getLikes() %>
                        </span>
                        <span class="stat-item">
                            <i class="bi bi-hand-thumbs-down"></i>
                            <%= post.getDislikes() %>
                        </span>
                        <span class="stat-item">
                            <i class="bi bi-chat"></i>
                            <%= commentDao.getCommentCountByPostId(post.getId()) %>
                        </span>
                        <span class="stat-item">
                            <i class="bi bi-eye"></i>
                            <%= post.getViews() %>
                        </span>
                    </div>
                </div>
            <% } %>
        </div>
        
        <% if(postCount > 5) { %>
            <div class="view-all-posts">
                <a href="#" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-right me-1"></i>전체 게시글 보기
                </a>
            </div>
        <% } %>
    <% } %>
</div>

<!-- 내가 쓴 댓글 섹션 -->
<div class="my-comments-section">
    <div class="section-header">
        <h3 class="section-title">
            <i class="bi bi-chat-dots me-2"></i>
            내가 쓴 댓글
        </h3>
        <span class="section-count">총 <strong><%= commentCount %></strong>개의 댓글</span>
    </div>
    
    <% if(myComments.isEmpty()) { %>
        <div class="empty-comments">
            <p class="empty-text">아직 작성한 댓글이 없어요</p>
        </div>
    <% } else { %>
        <div class="comments-list">
            <% for(Hottalk_CommentDto comment : myComments) { %>
                <div class="comment-item">
                    <div class="comment-header">
                        <span class="comment-nickname"><%= comment.getNickname() %></span>
                        <span class="comment-date"><%= comment.getCreated_at().toString().substring(0, 10) %></span>
                    </div>
                    <div class="comment-content">
                        <%= comment.getContent() %>
                    </div>
                    <div class="comment-stats">
                        <span class="stat-item">
                            <i class="bi bi-hand-thumbs-up"></i>
                            <%= comment.getLikes() %>
                        </span>
                        <span class="stat-item">
                            <i class="bi bi-hand-thumbs-down"></i>
                            <%= comment.getDislikes() %>
                        </span>
                    </div>
                </div>
            <% } %>
        </div>
        
        <% if(commentCount > 5) { %>
            <div class="view-all-comments">
                <a href="#" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-right me-1"></i>전체 댓글 보기
                </a>
            </div>
        <% } %>
    <% } %>
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

<!-- 회원 탈퇴 모달 -->
<div class="modal fade" id="withdrawModal" tabindex="-1" aria-labelledby="withdrawModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="withdrawModalLabel">
                    <i class="bi bi-exclamation-triangle text-danger me-2"></i>회원 탈퇴
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-warning" role="alert">
                    <i class="bi bi-exclamation-triangle me-2"></i>
                    <strong>주의!</strong> 회원 탈퇴 시 모든 데이터가 영구적으로 삭제됩니다.
                </div>
                <form id="withdrawForm">
                    <div class="mb-3">
                        <label for="password" class="form-label">비밀번호 확인</label>
                        <input type="password" class="form-control" id="password" name="password" placeholder="현재 비밀번호를 입력해주세요" required>
                    </div>
                    <div class="mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="confirmWithdraw" required>
                            <label class="form-check-label" for="confirmWithdraw">
                                회원 탈퇴에 동의합니다
                            </label>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-danger" onclick="withdrawAccount()">회원 탈퇴</button>
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
            const countElement = document.querySelector('.wishlist-count');
            if(countElement) {
                const currentCount = parseInt(countElement.textContent.match(/\d+/)[0]);
                countElement.textContent = '(' + (currentCount - 1) + '개)';
            }
            
            // 위시리스트가 비어있으면 빈 상태 표시
            const wishlistGrid = document.querySelector('.wishlist-grid');
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

// 메모 추가/수정 함수
function addNote(wishId) {
    document.getElementById('wishId').value = wishId;
    
    // 해당 위시리스트 카드에서 현재 메모 내용 가져오기
    const card = document.querySelector('[data-wish-id="' + wishId + '"]');
    const noteSpan = card.querySelector('.wishlist-note span');
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



// 회원 탈퇴 모달 표시 함수
function showWithdrawModal() {
    const modal = new bootstrap.Modal(document.getElementById('withdrawModal'));
    modal.show();
}

// 회원 탈퇴 처리 함수
function withdrawAccount() {
    const password = document.getElementById('password').value;
    const confirmWithdraw = document.getElementById('confirmWithdraw').checked;
    
    if (!password.trim()) {
        alert('비밀번호를 입력해주세요.');
        return;
    }
    
    if (!confirmWithdraw) {
        alert('회원 탈퇴에 동의해주세요.');
        return;
    }
    
    if (!confirm('정말로 회원 탈퇴를 진행하시겠습니까?\n모든 데이터가 영구적으로 삭제됩니다.')) {
        return;
    }
    
    // AJAX로 회원 탈퇴 요청
    fetch('<%= root %>/mypage/withdrawAction.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: 'password=' + encodeURIComponent(password)
    })
    .then(response => response.json())
    .then(data => {
        if (data.result === true) {
            alert('회원 탈퇴가 완료되었습니다.');
            // 로그아웃 처리 후 메인 페이지로 이동
            window.location.href = '<%= root %>/login/logout.jsp';
        } else {
            alert(data.message || '회원 탈퇴에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('회원 탈퇴 중 오류가 발생했습니다.');
    });
}

// 게시글 상세보기 함수
function viewPostDetail(postId) {
    // 커뮤니티 페이지로 이동하여 해당 게시글 상세보기
    window.location.href = '<%= root %>/index.jsp?main=community/cumain.jsp&post=' + postId;
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