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
            // 댓글 목록 로드
            loadComments(postId);
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
    const selectedCard = document.querySelector('[data-category-id="' + categoryId + '"]');
    if (selectedCard) selectedCard.classList.add('active');

    // 구분선 텍스트 업데이트
    const dividerText = document.querySelector('.divider-text');
    if (dividerText) dividerText.textContent = '📝 ' + categoryName + ' 글 목록';

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
        container.innerHTML = 
            '<div class="category-posts">' +
                '<h3 class="posts-category-title">🗺️ 코스추천</h3>' +
                '<div class="posts-list">' +
                    '<div class="no-posts">' +
                        '<p>코스추천 기능은 준비 중입니다.</p>' +
                    '</div>' +
                '</div>' +
            '</div>';
    } else if (categoryName.includes('같이 갈래')) {
        container.innerHTML = 
            '<div class="category-posts">' +
                '<h3 class="posts-category-title">👥 같이갈래</h3>' +
                '<div class="posts-list">' +
                    '<div class="no-posts">' +
                        '<p>같이갈래 기능은 준비 중입니다.</p>' +
                    '</div>' +
                '</div>' +
            '</div>';
    }
}

// 신고 관련 함수들
function reportPost(postId) {
    if (!isLoggedIn) {
        alert('로그인 후 이용해 주세요.');
        return;
    }
    
    // 이미 신고했는지 확인
    checkReportStatus(postId);
}

function checkReportStatus(postId) {
    fetch('<%=root%>/community/hpost_action.jsp?action=checkReport&id=' + postId)
        .then(response => response.json())
        .then(data => {
            if (data.alreadyReported) {
                alert('글당 신고는 1번만 가능합니다.');
                return;
            }
            openReportModal(postId);
        })
        .catch(() => {
            alert('신고 상태 확인 중 오류가 발생했습니다.');
        });
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



function loadComments(postId) {
    fetch('<%=root%>/community/hpost_comment_action.jsp?action=list&post_id=' + postId)
        .then(res => res.json())
        .then(data => {
            const space = document.getElementById('commentSpace');
            if (space) {
                if (data.length === 0) {
                    space.innerHTML = '<div class="no-comments">아직 등록된 댓글이 없습니다</div>';
                } else {
                    let html = '<div class="comment-header-section">';
                    html += '<div class="comment-count">댓글: ' + data.length + '개</div>';
                    html += '<div class="comment-sort-buttons">';
                    html += '<button type="button" class="sort-btn active" onclick="changeCommentSort(\'latest\')">최신순</button>';
                    html += '<button type="button" class="sort-btn" onclick="changeCommentSort(\'popular\')">인기순</button>';
                    html += '</div>';
                    html += '</div>';
                    html += '<div class="comment-list">';
                    data.forEach((comment, index) => {
                        const date = new Date(comment.created_at).toLocaleString('ko-KR', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit'
                        });
                        html += '<div class="comment-item" data-id="' + comment.id + '">';
                        html += '<div class="comment-header">';
                        html += '<div class="comment-info">';
                        // 로그인 상태에 따라 별 표시
                        let nicknameDisplay = comment.nickname;
                        if (comment.id_address && comment.id_address !== null && comment.id_address !== 'null') {
                            nicknameDisplay = '⭐ ' + comment.nickname;
                        }
                        html += '<span class="comment-nickname-display">' + nicknameDisplay + '</span>';
                        html += '<span class="comment-date">' + date + '</span>';
                        html += '</div>';
                        html += '<button class="comment-delete-btn" onclick="deleteComment(' + comment.id + ')">삭제</button>';
                        html += '</div>';
                        html += '<div class="comment-content">' + comment.content + '</div>';
                        html += '<div class="comment-actions">';
                        html += '<button class="comment-like-btn" onclick="likeComment(' + comment.id + ')">';
                        html += '<span>👍</span> <span>좋아요 (' + comment.likes + ')</span>';
                        html += '</button>';
                        html += '<button class="comment-dislike-btn" onclick="dislikeComment(' + comment.id + ')">';
                        html += '<span>👎</span> <span>싫어요 (' + comment.dislikes + ')</span>';
                        html += '</button>';
                        html += '</div>';
                        html += '</div>';
                    });
                    html += '</div>';
                    space.innerHTML = html;
                }
            }
        })
        .catch(error => {
            console.error('댓글 로드 중 오류 발생:', error);
        });
}

function likeComment(commentId) {
    fetch('<%=root%>/community/hpost_comment_vote_action.jsp?action=like&comment_id=' + commentId)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // 해당 댓글의 좋아요/싫어요 수 업데이트
                const commentItem = document.querySelector('.comment-item[data-id="' + commentId + '"]');
                if (commentItem) {
                    const likeBtn = commentItem.querySelector('.comment-like-btn span:last-child');
                    const dislikeBtn = commentItem.querySelector('.comment-dislike-btn span:last-child');
                    if (likeBtn) likeBtn.textContent = '좋아요 (' + data.likes + ')';
                    if (dislikeBtn) dislikeBtn.textContent = '싫어요 (' + data.dislikes + ')';
                }
            } else {
                console.error('댓글 좋아요 실패:', data.error);
            }
        })
        .catch(error => {
            console.error('댓글 좋아요 오류:', error);
        });
}

function dislikeComment(commentId) {
    fetch('<%=root%>/community/hpost_comment_vote_action.jsp?action=dislike&comment_id=' + commentId)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // 해당 댓글의 좋아요/싫어요 수 업데이트
                const commentItem = document.querySelector('.comment-item[data-id="' + commentId + '"]');
                if (commentItem) {
                    const likeBtn = commentItem.querySelector('.comment-like-btn span:last-child');
                    const dislikeBtn = commentItem.querySelector('.comment-dislike-btn span:last-child');
                    if (likeBtn) likeBtn.textContent = '좋아요 (' + data.likes + ')';
                    if (dislikeBtn) dislikeBtn.textContent = '싫어요 (' + data.dislikes + ')';
                }
            } else {
                console.error('댓글 싫어요 실패:', data.error);
            }
        })
        .catch(error => {
            console.error('댓글 싫어요 오류:', error);
        });
}

// 댓글 정렬 함수
function changeCommentSort(sortType) {
    const postId = document.querySelector('.post-detail-container').dataset.postId;
    const sortButtons = document.querySelectorAll('.comment-sort-buttons .sort-btn');
    
    // 버튼 활성화 상태 변경
    sortButtons.forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    // 댓글 목록 새로고침 (정렬 타입 포함)
    loadCommentsWithSort(postId, sortType);
}

// 정렬 타입을 포함한 댓글 로드 함수
function loadCommentsWithSort(postId, sortType) {
    fetch('<%=root%>/community/hpost_comment_action.jsp?action=list&post_id=' + postId + '&sort=' + sortType)
        .then(res => res.json())
        .then(data => {
            const space = document.getElementById('commentSpace');
            if (space) {
                if (data.length === 0) {
                    space.innerHTML = '<div class="no-comments">아직 등록된 댓글이 없습니다</div>';
                } else {
                    let html = '<div class="comment-header-section">';
                    html += '<div class="comment-count">댓글: ' + data.length + '개</div>';
                    html += '<div class="comment-sort-buttons">';
                    html += '<button type="button" class="sort-btn ' + (sortType === 'latest' ? 'active' : '') + '" onclick="changeCommentSort(\'latest\')">최신순</button>';
                    html += '<button type="button" class="sort-btn ' + (sortType === 'popular' ? 'active' : '') + '" onclick="changeCommentSort(\'popular\')">인기순</button>';
                    html += '</div>';
                    html += '</div>';
                    html += '<div class="comment-list">';
                    data.forEach((comment, index) => {
                        const date = new Date(comment.created_at).toLocaleString('ko-KR', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit'
                        });
                        html += '<div class="comment-item" data-id="' + comment.id + '">';
                        html += '<div class="comment-header">';
                        html += '<div class="comment-info">';
                        // 로그인 상태에 따라 별 표시
                        let nicknameDisplay = comment.nickname;
                        if (comment.id_address && comment.id_address !== null && comment.id_address !== 'null') {
                            nicknameDisplay = '⭐ ' + comment.nickname;
                        }
                        html += '<span class="comment-nickname-display">' + nicknameDisplay + '</span>';
                        html += '<span class="comment-date">' + date + '</span>';
                        html += '</div>';
                        html += '<button class="comment-delete-btn" onclick="deleteComment(' + comment.id + ')">삭제</button>';
                        html += '</div>';
                        html += '<div class="comment-content">' + comment.content + '</div>';
                        html += '<div class="comment-actions">';
                        html += '<button class="comment-like-btn" onclick="likeComment(' + comment.id + ')">';
                        html += '<span>👍</span> <span>좋아요 (' + comment.likes + ')</span>';
                        html += '</button>';
                        html += '<button class="comment-dislike-btn" onclick="dislikeComment(' + comment.id + ')">';
                        html += '<span>👎</span> <span>싫어요 (' + comment.dislikes + ')</span>';
                        html += '</button>';
                        html += '</div>';
                        html += '</div>';
                    });
                    html += '</div>';
                    space.innerHTML = html;
                }
            }
        })
        .catch(error => {
            console.error('댓글 로드 중 오류 발생:', error);
        });
}

function deleteComment(commentId) {
    const passwd = prompt('댓글 삭제를 위해 비밀번호를 입력하세요:');
    if (!passwd) {
        return; // 취소한 경우
    }
    
    const params = new URLSearchParams();
    params.append('action', 'delete');
    params.append('comment_id', commentId);
    params.append('passwd', passwd);
    
    fetch('<%=root%>/community/hpost_comment_action.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            alert(data.message || '댓글이 삭제되었습니다.');
            // 댓글 목록 새로고침
            const postId = document.querySelector('.post-detail-container').dataset.postId;
            loadComments(postId);
        } else {
            alert(data.error || '댓글 삭제에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('댓글 삭제 오류:', error);
        alert('댓글 삭제 중 오류가 발생했습니다.');
    });
}

// 좋아요/싫어요 함수들을 전역으로 정의
function likePost(postId) {
    fetch('<%=root%>/community/hpost_action.jsp?action=like&id=' + postId)
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                document.getElementById('likes-count').textContent = data.likes;
                document.getElementById('dislikes-count').textContent = data.dislikes;
                
                // 버튼 상태 업데이트
                const likeBtn = document.querySelector('.like-btn');
                const dislikeBtn = document.querySelector('.dislike-btn');
                
                if (data.action === 'added' || data.action === 'changed') {
                    likeBtn.classList.add('active');
                    dislikeBtn.classList.remove('active');
                } else if (data.action === 'removed') {
                    likeBtn.classList.remove('active');
                    dislikeBtn.classList.remove('active');
                }
            } else {
                alert(data.error || '좋아요 처리에 실패했습니다.');
            }
        })
        .catch(() => {
            alert('좋아요 처리 중 오류가 발생했습니다.');
        });
}

function dislikePost(postId) {
    fetch('<%=root%>/community/hpost_action.jsp?action=dislike&id=' + postId)
        .then(response => response.json())
        .then(data => {
            if(data.success) {
                document.getElementById('likes-count').textContent = data.likes;
                document.getElementById('dislikes-count').textContent = data.dislikes;
                
                // 버튼 상태 업데이트
                const likeBtn = document.querySelector('.like-btn');
                const dislikeBtn = document.querySelector('.dislike-btn');
                
                if (data.action === 'added' || data.action === 'changed') {
                    dislikeBtn.classList.add('active');
                    likeBtn.classList.remove('active');
                } else if (data.action === 'removed') {
                    dislikeBtn.classList.remove('active');
                    likeBtn.classList.remove('active');
                }
            } else {
                alert(data.error || '싫어요 처리에 실패했습니다.');
            }
        })
        .catch(() => {
            alert('싫어요 처리 중 오류가 발생했습니다.');
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
            document.getElementById('commentPasswd').value = '';
            
            // 로그인된 사용자는 닉네임 유지, 비로그인 사용자는 초기화
            const nicknameField = document.getElementById('commentNickname');
            if (nicknameField && nicknameField.readOnly) {
                // readonly인 경우 (로그인된 사용자) - 닉네임 유지
                // 아무것도 하지 않음
            } else {
                // 편집 가능한 경우 (비로그인 사용자) - 초기화
                nicknameField.value = '';
            }
            
            alert('댓글이 등록되었습니다.');
            // 댓글 목록 새로고침
            loadComments(postId);
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

// 이미지 모달 관련 변수 (전역)
let currentImageIndex = 0;
let imageUrls = [];

// 이미지 모달 열기 (전역 함수)
window.openImageModal = function(imageSrc, imageIndex) {
    // 현재 게시글의 모든 이미지 URL 수집
    const postPhotos = document.querySelector('.post-photos');
    if (postPhotos) {
        const images = postPhotos.querySelectorAll('.post-photo');
        imageUrls = Array.from(images).map(img => img.src);
        currentImageIndex = imageIndex - 1; // 0-based index
    }
    
    const modal = document.getElementById('imageModal');
    const modalImg = document.getElementById('modalImage');
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    const counter = document.getElementById('imageCounter');
    
    modalImg.src = imageSrc;
    modal.classList.add('show');
    
    // 이미지가 2개 이상일 때만 네비게이션 버튼과 카운터 표시
    if (imageUrls.length > 1) {
        prevBtn.style.display = 'flex';
        nextBtn.style.display = 'flex';
        counter.style.display = 'block';
        updateImageCounter();
    } else {
        prevBtn.style.display = 'none';
        nextBtn.style.display = 'none';
        counter.style.display = 'none';
    }
    
    // ESC 키로 모달 닫기
    document.addEventListener('keydown', handleKeyDown);
};

// 이미지 모달 닫기 (전역 함수)
window.closeImageModal = function() {
    const modal = document.getElementById('imageModal');
    modal.classList.remove('show');
    document.removeEventListener('keydown', handleKeyDown);
};

// 이전 이미지 (전역 함수)
window.prevImage = function() {
    if (imageUrls.length > 1) {
        currentImageIndex = (currentImageIndex - 1 + imageUrls.length) % imageUrls.length;
        const modalImg = document.getElementById('modalImage');
        modalImg.src = imageUrls[currentImageIndex];
        updateImageCounter();
    }
};

// 다음 이미지 (전역 함수)
window.nextImage = function() {
    if (imageUrls.length > 1) {
        currentImageIndex = (currentImageIndex + 1) % imageUrls.length;
        const modalImg = document.getElementById('modalImage');
        modalImg.src = imageUrls[currentImageIndex];
        updateImageCounter();
    }
};

// 이미지 카운터 업데이트
function updateImageCounter() {
    const counter = document.getElementById('imageCounter');
    counter.textContent = (currentImageIndex + 1) + ' / ' + imageUrls.length;
}

// 키보드 이벤트 처리
function handleKeyDown(event) {
    if (event.key === 'Escape') {
        closeImageModal();
    } else if (event.key === 'ArrowLeft') {
        prevImage();
    } else if (event.key === 'ArrowRight') {
        nextImage();
    }
}

// 정렬 관련 변수
let currentSort = 'latest'; // 'latest' 또는 'popular'
let currentCategoryId = 1; // 기본 카테고리 ID

// 정렬 변경 함수
function changeSort(sortType) {
    currentSort = sortType;
    
    // 버튼 상태 업데이트
    const sortBtns = document.querySelectorAll('.sort-btn');
    sortBtns.forEach(btn => btn.classList.remove('active'));
    
    if (sortType === 'latest') {
        document.querySelector('.sort-btn[onclick="changeSort(\'latest\')"]').classList.add('active');
    } else if (sortType === 'popular') {
        document.querySelector('.sort-btn[onclick="changeSort(\'popular\')"]').classList.add('active');
    }
    
    // 현재 페이지에서 정렬된 목록 로드
    loadSortedPosts(1);
}

// 정렬된 글 목록 로드
function loadSortedPosts(page) {
    const container = document.getElementById('posts-container');
    container.innerHTML = '<div class="loading-message"><p>글을 불러오는 중...</p></div>';
    
    const url = currentSort === 'latest' 
        ? '<%=root%>/community/hpost_list.jsp?page=' + page
        : '<%=root%>/community/hpost_list.jsp?sort=popular&page=' + page;
    
    fetch(url)
        .then(response => response.text())
        .then(html => {
            container.innerHTML = html;
        })
        .catch(() => {
            container.innerHTML = '<div class="error-message"><p>글을 불러오는데 실패했습니다.</p></div>';
        });
}

// 카테고리별 글 로드 함수 수정
function loadCategoryPosts(categoryId, categoryName) {
    currentCategoryId = categoryId;
    currentSort = 'latest'; // 카테고리 변경 시 최신순으로 초기화
    
    // 카테고리 카드 활성화
    const categoryCards = document.querySelectorAll('.category-card');
    categoryCards.forEach(card => card.classList.remove('active'));
    
    const selectedCard = document.querySelector('[data-category-id="' + categoryId + '"]');
    if (selectedCard) selectedCard.classList.add('active');
    
    // 구분선 텍스트 업데이트
    const dividerText = document.querySelector('.divider-text');
    if (dividerText) dividerText.textContent = '📝 ' + categoryName + ' 글 목록';
    
    // 글 목록 로드
    const container = document.getElementById('posts-container');
    container.innerHTML = '<div class="loading-message"><p>글을 불러오는 중...</p></div>';
    
    fetch('<%=root%>/community/hpost_list.jsp?category=' + categoryId)
        .then(response => response.text())
        .then(html => {
            container.innerHTML = html;
        })
        .catch(() => {
            container.innerHTML = '<div class="error-message"><p>글을 불러오는데 실패했습니다.</p></div>';
        });
}

// 글 삭제 함수 (전역 함수)
window.deletePost = function(postId) {
    const passwd = prompt('글을 삭제하려면 비밀번호를 입력하세요:');
    if (!passwd) {
        return; // 취소한 경우
    }
    
    const params = new URLSearchParams();
    params.append('action', 'delete');
    params.append('id', postId);
    params.append('passwd', passwd);
    
    fetch('<%=root%>/community/hpost_delete_action.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            alert(data.message || '글이 삭제되었습니다.');
            // 글 상세 페이지에서 목록으로 돌아가기
            loadCategoryPosts(currentCategoryId, '헌팅썰');
        } else {
            alert(data.error || '글 삭제에 실패했습니다.');
        }
    })
    .catch(error => {
        console.error('글 삭제 오류:', error);
        alert('글 삭제 중 오류가 발생했습니다.');
    });
}
</script>