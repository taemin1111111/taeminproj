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
                    구경가기
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

<!-- 토스트 메시지 영역 삭제 -->

<script>
var isLoggedIn = <%= session.getAttribute("loginid") != null ? "true" : "false" %>;
// showToast 함수 삭제

// 글 상세보기 로드 함수
function loadPostDetail(postId) {
    const container = document.getElementById('posts-container');
    container.innerHTML = '<div class="loading-message"><p>글을 불러오는 중...</p></div>';
    
    // 조회수 증가
    fetch('<%=root%>/community/hpost_action.jsp?action=view&id=' + postId)
        .then(response => response.json())
        .then(data => {
            // 조회수 증가 후 글 로드
            return fetch('<%=root%>/community/hpost_detail.jsp?id=' + postId);
        })
        .then(response => response.text())
        .then(html => {
            container.innerHTML = html;
            try {
                if (typeof updateCommentCount === 'function') {
                    updateCommentCount(postId);
                }
            } catch (e) {
                // 에러 무시
            }
        })
        .catch(() => {
            container.innerHTML = '<div class="error-message"><p>글을 불러오는데 실패했습니다.</p></div>';
        });
    
    // URL에 post 파라미터 추가
    const currentUrl = new URL(window.location);
    currentUrl.searchParams.set('post', postId);
    history.pushState({postId: postId}, '', currentUrl.toString());
}

// 목록으로 돌아가기 함수 추가
function loadCategoryPosts(categoryId, categoryName) {
    const container = document.getElementById('posts-container');
    container.innerHTML = '<div class="loading-message"><p>글을 불러오는 중...</p></div>';

    // URL에서 post 파라미터 제거
    const currentUrl = new URL(window.location);
    currentUrl.searchParams.delete('post');
    history.pushState({}, '', currentUrl.toString());

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
        // page 파라미터가 있으면 전달
        let page = 1;
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('page')) {
            page = urlParams.get('page');
        }
        fetch(`<%=root%>/community/hpost_list.jsp?page=${page}`)
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

// 신고 관련 함수들
function reportPost(postId) {
    if (!isLoggedIn) {
        alert('로그인 후 이용해 주세요.');
        return;
    }
    openReportModal(postId);
}

function openReportModal(postId) {
    // 모달이 없으면 생성
    if (!document.getElementById('reportModal')) {
        createReportModal();
    }
    document.getElementById('reportPostId').value = postId;
    document.getElementById('reportModal').style.display = 'flex';
    document.body.style.overflow = 'hidden';
    setTimeout(() => {
        const detailInput = document.getElementById('reportDetail');
        if (detailInput) detailInput.focus();
    }, 100);
}

function closeReportModal() {
    document.getElementById('reportModal').style.display = 'none';
    document.body.style.overflow = 'auto';
    if (document.getElementById('reportForm')) {
        document.getElementById('reportForm').reset();
    }
}

function createReportModal() {
    const modalHTML = `
        <div id="reportModal" class="modal-overlay" style="display: none;">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>🚨 글 신고하기</h3>
                    <button class="modal-close" onclick="closeReportModal()">&times;</button>
                </div>
                <form id="reportForm" class="modal-form" onsubmit="return false;">
                    <input type="hidden" id="reportPostId" value="">
                    
                    <div class="form-group">
                        <label class="form-label">신고 사유 *</label>
                        <select id="reportReason" name="reason" class="form-select" required>
                            <option value="">신고 사유를 선택해주세요</option>
                            <option value="spam">스팸/광고성 글</option>
                            <option value="inappropriate">부적절한 내용</option>
                            <option value="harassment">욕설/비방</option>
                            <option value="copyright">저작권 침해</option>
                            <option value="other">기타</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">상세 내용</label>
                        <textarea id="reportDetail" name="detail" class="form-textarea" 
                                  placeholder="신고 사유에 대한 상세한 설명을 작성해주세요 (선택사항)" rows="4"></textarea>
                    </div>
                    
                    <div class="modal-actions">
                        <button type="button" class="submit-btn" onclick="submitReport()">신고하기</button>
                        <button type="button" class="cancel-btn" onclick="closeReportModal()">취소</button>
                    </div>
                </form>
            </div>
        </div>
    `;
    document.body.insertAdjacentHTML('beforeend', modalHTML);
    
    // 폼 제출 이벤트 리스너 추가
    const reportForm = document.getElementById('reportForm');
    if (reportForm) {
        reportForm.addEventListener('submit', function(e) {
            e.preventDefault();
            e.stopPropagation();
            submitReport();
            return false;
        });
    }
}

function submitReport() {
    const postId = document.getElementById('reportPostId').value;
    const reason = document.getElementById('reportReason').value;
    const detail = document.getElementById('reportDetail').value;

    if (!reason) {
        alert('신고 사유를 선택해주세요.');
        return;
    }

    // URL 인코딩 방식으로 데이터 준비
    const params = new URLSearchParams();
    params.append('action', 'report');
    params.append('id', postId);
    params.append('reason', reason);
    params.append('detail', detail);

    fetch('<%=root%>/community/hpost_action.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: params.toString()
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('소중한 신고 감사합니다!!');
            closeReportModal();
        } else {
            alert('신고 처리 중 오류가 발생했습니다.');
        }
    })
    .catch(() => {
        alert('신고 처리 중 오류가 발생했습니다.');
    });
}

// 댓글 관련 함수 (hpost_detail.jsp에서 이동)
function updateCommentCount(postId) {
    fetch('<%=root%>/community/hpost_comment_action.jsp?action=count&post_id=' + postId)
        .then(res => res.json())
        .then(data => {
            const space = document.getElementById('commentSpace');
            if (space) {
                if (data.count === 0) {
                    space.textContent = '아직 댓글이 없습니다';
                } else {
                    space.textContent = '댓글 ' + data.count + '개';
                }
            }
        });
}

function submitComment(postId) {
    const nickname = document.getElementById('commentNickname').value.trim();
    const passwd = document.getElementById('commentPasswd').value.trim();
    const content = document.getElementById('commentContent').value.trim();
    if (!content) {
        alert('댓글을 입력하세요.');
        return;
    }
    if (!nickname) {
        alert('닉네임을 입력하세요.');
        return;
    }
    if (!passwd) {
        alert('비밀번호를 입력하세요.');
        return;
    }
    const params = new URLSearchParams();
    params.append('action', 'insert');
    params.append('post_id', postId);
    params.append('nickname', nickname);
    params.append('passwd', passwd);
    params.append('content', content);
    fetch('<%=root%>/community/hpost_comment_action.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            document.getElementById('commentContent').value = '';
            document.getElementById('commentNickname').value = '';
            document.getElementById('commentPasswd').value = '';
            alert('댓글이 등록되었습니다.');
            updateCommentCount(postId);
        } else {
            alert('댓글 등록 실패');
        }
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
    // URL에서 post 파라미터 확인
    const urlParams = new URLSearchParams(window.location.search);
    const postId = urlParams.get('post');
    
    if (postId) {
        // post 파라미터가 있으면 해당 글의 디테일 페이지 로드
        loadPostDetail(postId);
    } else {
        // post 파라미터가 없으면 첫 번째 카테고리 자동 선택
    const firstCard = document.querySelector('.category-card');
    if (firstCard) {
        const categoryId = firstCard.getAttribute('data-category-id');
        const categoryName = firstCard.querySelector('.category-name').textContent;
        loadCategoryPosts(categoryId, categoryName);
        }
    }
});
</script>