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
<%@ page import="MD.MdWishDao" %>
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
    
    // 내가 찜한 MD 정보 가져오기
    MdWishDao mdWishDao = new MdWishDao();
    List<Map<String, Object>> myMdWishes = mdWishDao.getUserMdWishesWithInfo(loginId, 5); // 최근 5개
    int mdWishCount = mdWishDao.getUserMdWishCount(loginId);
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
            <button class="btn btn-outline-primary me-2" onclick="showEditModal()">
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

<!-- 내가 찜한 MD 섹션 -->
<div class="md-wishlist-section">
    <div class="section-header">
        <h3 class="section-title">
            <i class="bi bi-chat-dots me-2"></i>
            내가 찜한 MD 리스트
        </h3>
        <span class="section-count">총 <strong><%= mdWishCount %></strong>개의 MD</span>
    </div>
    
    <% if(myMdWishes.isEmpty()) { %>
        <div class="empty-md-wishlist">
            <div class="empty-icon">
                <i class="bi bi-heart"></i>
            </div>
            <p class="empty-text">아직 찜한 MD가 없어요</p>
            <a href="<%= root %>/index.jsp?main=clubmd/clubmd.jsp" class="btn btn-outline-primary">
                <i class="bi bi-search me-1"></i>MD 둘러보기
            </a>
        </div>
    <% } else { %>
        <div class="md-wishlist-grid">
            <% for(Map<String, Object> mdWish : myMdWishes) { %>
                <div class="md-wishlist-card">
                    <div class="md-wishlist-card-header">
                        <div class="md-wishlist-category">
                            <span class="category-badge category-md">MD</span>
                        </div>
                        <button class="md-wishlist-delete-btn" onclick="deleteMdWish(<%= mdWish.get("mdId") %>)">
                            <i class="bi bi-x-lg"></i>
                        </button>
                    </div>
                    <div class="md-wishlist-card-body">
                        <% if(mdWish.get("photo") != null && !mdWish.get("photo").toString().isEmpty()) { %>
                            <div class="md-photo">
                                <img src="<%= root %>/mdphotos/<%= mdWish.get("photo") %>" alt="MD 사진" class="md-photo-img">
                            </div>
                        <% } else { %>
                            <div class="md-photo-placeholder">
                                <i class="bi bi-person-circle"></i>
                            </div>
                        <% } %>
                        <h5 class="md-name"><%= mdWish.get("mdName") %></h5>
                        <p class="md-place">
                            <i class="bi bi-geo-alt me-1"></i>
                            <%= mdWish.get("placeName") %>
                        </p>
                        <p class="md-address">
                            <small class="text-muted"><%= mdWish.get("address") %></small>
                        </p>
                        <% if(mdWish.get("contact") != null && !mdWish.get("contact").toString().isEmpty()) { %>
                            <p class="md-contact">
                                <i class="bi bi-telephone me-1"></i>
                                <%= mdWish.get("contact") %>
                            </p>
                        <% } %>
                        <% if(mdWish.get("description") != null && !mdWish.get("description").toString().isEmpty()) { %>
                            <p class="md-description">
                                <small><%= mdWish.get("description") %></small>
                            </p>
                        <% } %>
                        <div class="md-wish-date">
                            <i class="bi bi-calendar3 me-1"></i>
                            찜한 날짜: <%= mdWish.get("createdAt").toString().substring(0, 10) %>
                        </div>
                    </div>

                </div>
            <% } %>
        </div>
        
        <% if(mdWishCount > 0) { %>
            <div class="view-all-md-wishes">
                <a href="<%= root %>/index.jsp?main=mypage/mymdlist.jsp" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-right me-1"></i>전체 찜MD 보기
                </a>
            </div>
        <% } %>
    <% } %>
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

<!-- 정보 수정 모달 -->
<div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="editModalLabel">
                    <i class="bi bi-pencil text-primary me-2"></i>정보 수정
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="editForm">
                                                              <!-- 닉네임 수정 -->
                      <div class="mb-3">
                          <label for="editNickname" class="form-label">닉네임</label>
                          <div class="input-group">
                              <input type="text" class="form-control" id="editNickname" name="nickname" 
                                     value="<%= member.getNickname() %>" required disabled>
                              <button type="button" class="btn btn-outline-secondary" onclick="checkNickname()">중복확인</button>
                          </div>
                          <div id="nicknameResult" class="mt-1 small"></div>
                          <div class="form-text">닉네임은 다른 사용자에게 표시됩니다. '관리자'가 포함된 닉네임은 사용할 수 없습니다.</div>
                      </div>
                    
                                                                                   <!-- 현재 비밀번호 입력 (일반 사용자만) -->
                     <% if(!"naver".equals(member.getProvider())) { %>
                     <div class="mb-3">
                         <label for="currentPassword" class="form-label">현재 비밀번호</label>
                         <div class="input-group">
                             <input type="password" class="form-control" id="currentPassword" name="currentPassword" 
                                    placeholder="현재 비밀번호를 입력해주세요">
                             <button type="button" class="btn btn-outline-secondary" onclick="checkCurrentPassword()">확인</button>
                         </div>
                         <div id="currentPasswordResult" class="mt-1 small"></div>
                         <div class="form-text">닉네임을 변경하려면 현재 비밀번호를 입력해주세요.</div>
                     </div>
                     <% } else { %>
                     <div class="alert alert-info" role="alert">
                         <i class="bi bi-info-circle me-2"></i>
                         네이버 로그인 사용자는 닉네임을 바로 변경할 수 있습니다.
                     </div>
                     <% } %>
                     
                     <!-- 일반 회원만 새 비밀번호 변경 표시 -->
                     <% if(!"naver".equals(member.getProvider())) { %>
                     <div class="mb-3">
                         <label for="newPassword" class="form-label">새 비밀번호 (선택사항)</label>
                         <input type="password" class="form-control" id="newPassword" name="newPassword" 
                                placeholder="새 비밀번호를 입력해주세요" disabled>
                         <div id="newPasswordResult" class="mt-1 small"></div>
                         <div class="form-text">10자 이상, 영문+숫자+특수문자 포함 필수</div>
                     </div>
                     
                     <div class="mb-3">
                         <label for="confirmPassword" class="form-label">새 비밀번호 확인</label>
                         <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                placeholder="새 비밀번호를 다시 입력해주세요" disabled>
                         <div id="confirmPasswordResult" class="mt-1 small"></div>
                     </div>
                     <% } else { %>
                     <div class="alert alert-info" role="alert">
                         <i class="bi bi-info-circle me-2"></i>
                         네이버 로그인 사용자는 닉네임만 변경할 수 있습니다.
                     </div>
                     <% } %>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" onclick="updateProfile()">수정 완료</button>
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

<!-- 메모 추가/수정 모달 -->
<div class="modal fade" id="noteModal" tabindex="-1" aria-labelledby="noteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="noteModalLabel">
                    <i class="bi bi-chat-text text-primary me-2"></i>메모 추가
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="noteForm">
                    <input type="hidden" id="wishId" name="wishId">
                    <div class="mb-3">
                        <label for="noteContent" class="form-label">메모 내용</label>
                        <textarea class="form-control" id="noteContent" name="noteContent" rows="4" 
                                  placeholder="이 장소에 대한 메모를 작성해주세요..."></textarea>
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
// 정보 수정 모달 표시 함수
function showEditModal() {
    // 모달 열 때 모든 필드 초기화
    const editNickname = document.getElementById('editNickname');
    const currentPassword = document.getElementById('currentPassword');
    const newPassword = document.getElementById('newPassword');
    const confirmPassword = document.getElementById('confirmPassword');
    const currentPasswordResult = document.getElementById('currentPasswordResult');
    const newPasswordResult = document.getElementById('newPasswordResult');
    const confirmPasswordResult = document.getElementById('confirmPasswordResult');
    const nicknameResult = document.getElementById('nicknameResult');
    
    // 네이버 사용자인지 확인
    const isNaverUser = <%= "naver".equals(member.getProvider()) ? "true" : "false" %>;
    
    // 각 요소가 존재하는지 확인 후 초기화
    if (editNickname) {
        // 네이버 사용자는 닉네임 필드를 바로 활성화
        editNickname.disabled = !isNaverUser;
    }
    if (currentPassword) {
        currentPassword.disabled = false;
        currentPassword.value = '';
    }
    if (newPassword) {
        newPassword.disabled = true;
        newPassword.value = '';
    }
    if (confirmPassword) {
        confirmPassword.disabled = true;
        confirmPassword.value = '';
    }
    
    // 결과 메시지 초기화
    if (currentPasswordResult) {
        currentPasswordResult.textContent = '';
    }
    if (newPasswordResult) {
        newPasswordResult.textContent = '';
    }
    if (confirmPasswordResult) {
        confirmPasswordResult.textContent = '';
    }
    if (nicknameResult) {
        nicknameResult.textContent = '';
    }
    
    // 확인 버튼 초기화 (일반 사용자만)
    const checkButton = document.querySelector('button[onclick="checkCurrentPassword()"]');
    if (checkButton) {
        checkButton.disabled = false;
        checkButton.textContent = '확인';
    }
    
    // 닉네임 중복확인 버튼 초기화
    const nicknameCheckButton = document.querySelector('button[onclick="checkNickname()"]');
    if (nicknameCheckButton) {
        nicknameCheckButton.disabled = false;
        nicknameCheckButton.textContent = '중복확인';
    }
    
    const modal = new bootstrap.Modal(document.getElementById('editModal'));
    modal.show();
}

// 닉네임 중복 체크 함수
function checkNickname() {
    const nickname = document.getElementById('editNickname').value.trim();
    
    if (!nickname) {
        document.getElementById('nicknameResult').textContent = '닉네임을 입력해주세요.';
        document.getElementById('nicknameResult').style.color = 'red';
        return;
    }
    
    // 관리자 닉네임 제한
    if (nickname.toLowerCase().includes('관리자')) {
        document.getElementById('nicknameResult').textContent = "'관리자'가 포함된 닉네임은 사용할 수 없습니다.";
        document.getElementById('nicknameResult').style.color = 'red';
        return;
    }
    
    // 버튼 비활성화
    const button = event.target;
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = '확인중...';
    
    fetch('<%= root %>/mypage/checkNicknameAction.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: 'nickname=' + encodeURIComponent(nickname)
    })
    .then(response => response.json())
    .then(data => {
        if (data.result === true) {
            document.getElementById('nicknameResult').textContent = data.message;
            document.getElementById('nicknameResult').style.color = 'green';
            button.disabled = true;
            button.textContent = '확인됨';
        } else {
            document.getElementById('nicknameResult').textContent = data.message;
            document.getElementById('nicknameResult').style.color = 'red';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        document.getElementById('nicknameResult').textContent = '닉네임 확인 중 오류가 발생했습니다.';
        document.getElementById('nicknameResult').style.color = 'red';
    })
    .finally(() => {
        if (document.getElementById('nicknameResult').style.color !== 'green') {
            button.disabled = false;
            button.textContent = originalText;
        }
    });
}

// 현재 비밀번호 확인 함수
function checkCurrentPassword() {
    const currentPassword = document.getElementById('currentPassword').value.trim();
    
    if (!currentPassword) {
        document.getElementById('currentPasswordResult').textContent = '현재 비밀번호를 입력해주세요.';
        document.getElementById('currentPasswordResult').style.color = 'red';
        return;
    }
    
    // 버튼 비활성화
    const button = event.target;
    const originalText = button.textContent;
    button.disabled = true;
    button.textContent = '확인중...';
    
    fetch('<%= root %>/mypage/checkCurrentPasswordAction.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: 'currentPassword=' + encodeURIComponent(currentPassword)
    })
    .then(response => response.json())
    .then(data => {
                 if (data.result === true) {
             const currentPasswordResult = document.getElementById('currentPasswordResult');
             const editNickname = document.getElementById('editNickname');
             const newPassword = document.getElementById('newPassword');
             const confirmPassword = document.getElementById('confirmPassword');
             const currentPassword = document.getElementById('currentPassword');
             
             if (currentPasswordResult) {
                 currentPasswordResult.textContent = data.message;
                 currentPasswordResult.style.color = 'green';
             }
             
             // 닉네임 입력 필드 활성화
             if (editNickname) {
                 editNickname.disabled = false;
             }
             
             // 새 비밀번호 입력 필드들 활성화
             if (newPassword) {
                 newPassword.disabled = false;
             }
             if (confirmPassword) {
                 confirmPassword.disabled = false;
             }
             
             // 현재 비밀번호 필드 비활성화
             if (currentPassword) {
                 currentPassword.disabled = true;
             }
             
             button.disabled = true;
             button.textContent = '확인됨';
         } else {
            document.getElementById('currentPasswordResult').textContent = data.message;
            document.getElementById('currentPasswordResult').style.color = 'red';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        document.getElementById('currentPasswordResult').textContent = '비밀번호 확인 중 오류가 발생했습니다.';
        document.getElementById('currentPasswordResult').style.color = 'red';
    })
    .finally(() => {
        if (document.getElementById('currentPasswordResult').style.color !== 'green') {
            button.disabled = false;
            button.textContent = originalText;
        }
    });
}

// 새 비밀번호 검증
const newPasswordInput = document.getElementById('newPassword');
const newPasswordResult = document.getElementById('newPasswordResult');
if (newPasswordInput) {
    newPasswordInput.addEventListener("input", function() {
        const regex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\[\]{};':"\\|,.<>\/?]).{10,}$/;
        if (newPasswordInput.value === "") {
            newPasswordResult.textContent = "";
        } else if (regex.test(newPasswordInput.value)) {
            newPasswordResult.textContent = "사용가능한 비밀번호입니다.";
            newPasswordResult.style.color = "green";
        } else {
            newPasswordResult.textContent = "10자 이상, 영문+숫자+특수문자 포함 필수";
            newPasswordResult.style.color = "red";
        }
    });
}

// 새 비밀번호 일치검사
const confirmPasswordInput = document.getElementById('confirmPassword');
const confirmPasswordResult = document.getElementById('confirmPasswordResult');
if (confirmPasswordInput && newPasswordInput) {
    confirmPasswordInput.addEventListener("input", function() {
        if (newPasswordInput.value === "" || confirmPasswordInput.value === "") {
            confirmPasswordResult.textContent = "";
            return;
        }
        if (newPasswordInput.value === confirmPasswordInput.value) {
            confirmPasswordResult.textContent = "비밀번호가 일치합니다.";
            confirmPasswordResult.style.color = "green";
        } else {
            confirmPasswordResult.textContent = "비밀번호가 일치하지 않습니다.";
            confirmPasswordResult.style.color = "red";
        }
    });
}

// 프로필 업데이트 함수
function updateProfile() {
    const nickname = document.getElementById('editNickname').value.trim();
    const currentPassword = document.getElementById('currentPassword')?.value || '';
    const newPassword = document.getElementById('newPassword')?.value || '';
    const confirmPassword = document.getElementById('confirmPassword')?.value || '';
    const isNaverUser = <%= "naver".equals(member.getProvider()) ? "true" : "false" %>;
    
         // 닉네임 검증
     if (!nickname) {
         alert('닉네임을 입력해주세요.');
         return;
     }
     
     // 관리자 닉네임 제한
     if (nickname.toLowerCase().includes('관리자')) {
         alert("'관리자'가 포함된 닉네임은 사용할 수 없습니다.");
         return;
     }
     
     // 닉네임 중복 체크 확인 (닉네임이 변경된 경우에만)
     const nicknameResult = document.getElementById('nicknameResult');
     const currentNickname = '<%= member.getNickname() %>';
     if (nickname !== currentNickname && nicknameResult && nicknameResult.style.color !== 'green') {
         alert('닉네임 중복 확인을 먼저 해주세요.');
         return;
     }
    
         // 일반 사용자만 현재 비밀번호 확인 필요
     if (!isNaverUser && document.getElementById('currentPasswordResult')?.style.color !== 'green') {
         alert('현재 비밀번호를 먼저 확인해주세요.');
         return;
     }
    
    // 일반 사용자의 경우 새 비밀번호 입력 시 유효성 검사
    if (!isNaverUser && newPassword) {
        if (newPasswordResult?.style.color !== 'green') {
            alert('새 비밀번호 조건을 확인해주세요.');
            return;
        }
        
        if (confirmPasswordResult?.style.color !== 'green') {
            alert('새 비밀번호 확인을 다시 확인해주세요.');
            return;
        }
    }
    
         // AJAX로 프로필 업데이트 요청
     const params = new URLSearchParams();
     params.append('nickname', nickname);
     params.append('currentPassword', currentPassword);
     if (!isNaverUser && newPassword) {
         params.append('newPassword', newPassword);
     }
     
     fetch('<%= root %>/mypage/updateProfileAction.jsp', {
         method: 'POST',
         headers: {
             'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
         },
         body: params.toString()
     })
    .then(response => response.json())
    .then(data => {
        if (data.result === true) {
            alert('정보가 성공적으로 수정되었습니다.');
            // 모달 닫기
            const modal = bootstrap.Modal.getInstance(document.getElementById('editModal'));
            modal.hide();
            // 페이지 새로고침
            location.reload();
        } else {
            alert(data.message || '정보 수정에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('정보 수정 중 오류가 발생했습니다.');
    });
}

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

// MD 찜 삭제 함수
function deleteMdWish(mdId) {
    if (!confirm('정말로 이 MD를 찜 목록에서 삭제하시겠습니까?')) {
        return;
    }
    
    // AJAX로 MD 찜 삭제
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
            // 삭제된 카드 제거
            const card = event.target.closest('.md-wishlist-card');
            if (card) {
                card.remove();
            }
            
            // MD 찜 개수 업데이트
            const countElement = document.querySelector('.md-wishlist-section .section-count strong');
            if (countElement) {
                const currentCount = parseInt(countElement.textContent);
                countElement.textContent = (currentCount - 1);
            }
            
            // MD 찜 목록이 비어있으면 빈 상태 표시
            const mdWishlistGrid = document.querySelector('.md-wishlist-grid');
            if (mdWishlistGrid && mdWishlistGrid.children.length === 0) {
                location.reload(); // 페이지 새로고침으로 빈 상태 표시
            }
        } else {
            alert(data.message || 'MD 찜 삭제에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('MD 찜 삭제 중 오류가 발생했습니다.');
    });
}


</script>

<link rel="stylesheet" href="<%=root%>/css/mypage.css">