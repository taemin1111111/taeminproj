<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="MD.MdDao" %>
<%@ page import="MD.MdDto" %>
<%@ page import="MD.MdWishDao" %>
<%@ page import="hotplace_info.HotplaceDao" %>
<%@ page import="hotplace_info.HotplaceDto" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String nickname = (String)session.getAttribute("nickname");
    String provider = (String)session.getAttribute("provider");
    
    // 페이징 파라미터 처리
    String pageParam = request.getParameter("page");
    int currentPage = 1;
    int pageSize = 10; // 페이지당 10개
    
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    // MD 정보와 장소 정보를 함께 조회 (페이징 적용)
    MdDao mdDao = new MdDao();
    List<Map<String, Object>> mdList = mdDao.getMdWithPlaceInfoPaged(currentPage, pageSize);
    int mdCount = mdDao.getMdCount();
    int totalPages = mdDao.getTotalPages(pageSize);
    
    // 장소 목록 조회 (자동완성용)
    HotplaceDao hotplaceDao = new HotplaceDao();
    List<String> hotplaceNameList = hotplaceDao.getAllHotplaceNames();
    List<HotplaceDto> hotplaceList = hotplaceDao.getAllHotplaces();
%>

<script>
// 장소명 목록을 JavaScript 변수로 설정 (main.jsp와 동일한 방식)
var hotplaceNameList = [<% for(int i=0;i<hotplaceNameList.size();i++){ %>'<%=hotplaceNameList.get(i).replace("'", "\\'")%>'<% if(i<hotplaceNameList.size()-1){%>,<%}}%>];

// 장소 정보 목록 (ID 매핑용)
var hotplaceList = [
    <% for(int i=0; i<hotplaceList.size(); i++) { 
        HotplaceDto place = hotplaceList.get(i); %>
    {
        id: <%= place.getId() %>,
        name: '<%= place.getName().replace("'", "\\'") %>',
        address: '<%= place.getAddress().replace("'", "\\'") %>'
    }<% if(i < hotplaceList.size()-1) { %>,<% } %>
    <% } %>
];


</script>

<div class="md-container">
    <!-- 헤더 섹션 -->
    <div class="md-header">
        <div class="md-header-content">
            <h1 class="md-title">
                <i class="bi bi-shield-check me-3"></i>
                클럽 MD 예약 창
            </h1>
            <p class="md-subtitle">검증된 MD들과 안전하게 예약하세요</p>
            <span class="md-badge">
                <i class="bi bi-verified me-2"></i>검증된 MD
            </span>
        </div>
    </div>
    
    <!-- 신뢰도 표시 섹션 -->
    <div class="md-trust-section">
        <div class="md-trust-grid">
            <div class="md-trust-item">
                <div class="md-trust-icon">
                    <i class="bi bi-shield-check"></i>
                </div>
                <div class="md-trust-title">검증된 MD</div>
                <div class="md-trust-desc">모든 MD는 신원이 확인된 검증된 MD입니다</div>
            </div>
            <div class="md-trust-item">
                <div class="md-trust-icon">
                    <i class="bi bi-lock"></i>
                </div>
                <div class="md-trust-title">안전한 예약</div>
                <div class="md-trust-desc">개인정보 보호 및 안전한 예약 시스템</div>
            </div>
            <div class="md-trust-item">
                <div class="md-trust-icon">
                    <i class="bi bi-star"></i>
                </div>
                <div class="md-trust-title">고객 만족</div>
                <div class="md-trust-desc">높은 고객 만족도와 신뢰받는 서비스</div>
            </div>
        </div>
    </div>
    
    <!-- MD 카드 섹션 -->
    <div class="md-cards-section">
        
        <!-- 관리자만 MD 등록 버튼 표시 -->
        <% if("admin".equals(provider)) { %>
            <div class="text-end mb-3">
                <button type="button" class="md-admin-btn" data-bs-toggle="modal" data-bs-target="#mdRegisterModal">
                    <i class="bi bi-plus-circle me-2"></i> MD 등록
                </button>
            </div>
        <% } %>
        
        <!-- MD 정보 출력 -->
        <% if(mdCount > 0) { %>
            <div class="md-cards-grid">
                <% for(Map<String, Object> md : mdList) { %>
                    <div class="md-card">
                        <!-- 검증 배지 -->
                        <div class="md-verified-badge">
                            <i class="bi bi-shield-check me-1"></i>검증됨
                        </div>
                        
                        <!-- 찜 버튼 (우상단) -->
                        <% if(loginId != null) { %>
                            <% 
                            MdWishDao wishDao = new MdWishDao();
                            boolean isWished = wishDao.isMdWished((Integer)md.get("mdId"), loginId);
                            %>
                            <button type="button" 
                                    class="md-wish-btn <%= isWished ? "wished" : "" %>"
                                    onclick="toggleMdWish(<%= md.get("mdId") != null ? md.get("mdId") : 0 %>, this)"
                                    data-md-id="<%= md.get("mdId") != null ? md.get("mdId") : 0 %>"
                                    data-wished="<%= isWished %>">
                                <i class="bi <%= isWished ? "bi-heart-fill" : "bi-heart" %>"></i>
                            </button>
                        <% } %>
                        
                        <div class="md-card-header">
                            <% if(md.get("photo") != null && !md.get("photo").toString().isEmpty()) { %>
                                <img src="<%= root %>/mdphotos/<%= md.get("photo") %>" class="md-card-image" alt="MD 사진">
                            <% } else { %>
                                <div class="md-card-placeholder">
                                    <i class="bi bi-person-circle"></i>
                                </div>
                            <% } %>
                        </div>
                        
                        <div class="md-card-body">
                            <h5 class="md-card-name"><%= md.get("mdName") %></h5>
                            <div class="md-card-location">
                                <i class="bi bi-geo-alt"></i>
                                <span class="md-card-place"><%= md.get("placeName") %></span>
                            </div>
                            <div class="md-card-address">
                                <i class="bi bi-geo-alt-fill"></i>
                                <span class="address-text"><%= md.get("address") %></span>
                            </div>
                            <% if(md.get("contact") != null && !md.get("contact").toString().isEmpty()) { %>
                                <div class="md-card-contact">
                                    <i class="bi bi-telephone"></i>
                                    <span class="md-card-contact-text"><%= md.get("contact") %></span>
                                </div>
                            <% } %>
                            <% if(md.get("description") != null && !md.get("description").toString().isEmpty()) { %>
                                <div class="md-card-description">
                                    <span class="description-text">연결주소: <%= md.get("description") %></span>
                                </div>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
            
            <!-- 페이징 네비게이션 -->
            <% if(totalPages > 1) { %>
                <nav class="md-pagination">
                    <ul class="pagination">
                        <!-- 이전 페이지 -->
                        <% if(currentPage > 1) { %>
                            <li class="page-item">
                                <a class="page-link" href="<%= root %>/index.jsp?main=clubmd/clubmd.jsp&page=<%= currentPage - 1 %>" aria-label="이전">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>
                        <% } else { %>
                            <li class="page-item disabled">
                                <span class="page-link" aria-hidden="true">&laquo;</span>
                            </li>
                        <% } %>
                        
                        <!-- 페이지 번호 -->
                        <% 
                        int startPage = Math.max(1, currentPage - 2);
                        int endPage = Math.min(totalPages, currentPage + 2);
                        
                        if(startPage > 1) { %>
                            <li class="page-item">
                                <a class="page-link" href="<%= root %>/index.jsp?main=clubmd/clubmd.jsp&page=1">1</a>
                            </li>
                            <% if(startPage > 2) { %>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                            <% } %>
                        <% } %>
                        
                        <% for(int i = startPage; i <= endPage; i++) { %>
                            <li class="page-item <%= i == currentPage ? "active" : "" %>">
                                <a class="page-link" href="<%= root %>/index.jsp?main=clubmd/clubmd.jsp&page=<%= i %>"><%= i %></a>
                            </li>
                        <% } %>
                        
                        <% if(endPage < totalPages) { %>
                            <% if(endPage < totalPages - 1) { %>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                            <% } %>
                            <li class="page-item">
                                <a class="page-link" href="<%= root %>/index.jsp?main=clubmd/clubmd.jsp&page=<%= totalPages %>"><%= totalPages %></a>
                            </li>
                        <% } %>
                        
                        <!-- 다음 페이지 -->
                        <% if(currentPage < totalPages) { %>
                            <li class="page-item">
                                <a class="page-link" href="<%= root %>/index.jsp?main=clubmd/clubmd.jsp&page=<%= currentPage + 1 %>" aria-label="다음">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                        <% } else { %>
                            <li class="page-item disabled">
                                <span class="page-link" aria-hidden="true">&raquo;</span>
                            </li>
                        <% } %>
                    </ul>
                </nav>
                
                <!-- 페이지 정보 표시 -->
                <div class="text-center text-muted mt-2">
                    <small>총 <%= mdCount %>개의 MD 중 <%= (currentPage - 1) * pageSize + 1 %>-<%= Math.min(currentPage * pageSize, mdCount) %>번째</small>
                </div>
            <% } %>
        <% } else { %>
            <!-- MD가 없을 때 메시지 -->
            <div class="md-empty-state">
                <div class="md-empty-icon">
                    <i class="bi bi-exclamation-triangle"></i>
                </div>
                <h4 class="md-empty-title">등록된 MD가 없습니다</h4>
                <p class="md-empty-description">현재 등록된 MD가 없습니다.</p>
                <p class="md-empty-description">관리자에게 연락해서 MD 등록을 해주세요!</p>
            </div>
        <% } %>
    </div>
</div>

<!-- MD 등록 모달 -->
<div class="modal fade md-modal" id="mdRegisterModal" tabindex="-1" aria-labelledby="mdRegisterModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="mdRegisterModalLabel">MD 등록</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="mdRegisterForm">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="mdName" class="form-label">MD 이름 *</label>
                                <input type="text" class="form-control" id="mdName" name="mdName" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="placeSearch" class="form-label">장소 검색 *</label>
                                <div class="position-relative">
                                    <input type="text" class="form-control" id="placeSearch" 
                                           placeholder="장소명을 입력하세요" autocomplete="off">
                                    <input type="hidden" id="placeId" name="placeId" required>
                                    <div id="placeSearchResults" class="position-absolute w-100 bg-white border rounded shadow-sm" 
                                         style="position:absolute; left:0; top:46px; width:100%; background:rgba(255,255,255,0.97); border-radius:14px; box-shadow:0 4px 16px rgba(0,0,0,0.10); z-index:9999; flex-direction:column; overflow:hidden; border:1.5px solid #e0e0e0; display:none !important;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="contact" class="form-label">연락처</label>
                        <input type="text" class="form-control" id="contact" name="contact" 
                               placeholder="인스타 아이디 또는 오픈채팅 링크">
                    </div>
                    
                    <div class="mb-3">
                        <label for="description" class="form-label">소개</label>
                        <textarea class="form-control" id="description" name="description" rows="4" 
                                  placeholder="MD에 대한 간단한 소개나 특징을 적어주세요"></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label for="photo" class="form-label">사진</label>
                        <input type="file" class="form-control" id="photo" name="photo" accept="image/*">
                        <div class="form-text">선택사항입니다. MD 사진을 업로드해주세요.</div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" onclick="registerMd()">등록</button>
            </div>
        </div>
    </div>
</div>

<script>
// 장소 검색 및 자동완성 기능 (main.jsp와 동일한 방식)
let searchTimeout;

// 모달이 완전히 로드된 후에 이벤트 리스너 등록
document.addEventListener('DOMContentLoaded', function() {
    // 모달이 열릴 때마다 이벤트 리스너 등록
    const mdRegisterModal = document.getElementById('mdRegisterModal');
    if (mdRegisterModal) {
        mdRegisterModal.addEventListener('shown.bs.modal', function() {
            setupSearchListener();
        });
    }
});

function setupSearchListener() {
    const searchInput = document.getElementById('placeSearch');
    if (!searchInput) {
        return;
    }
    
    searchInput.addEventListener('input', function() {
        const searchTerm = this.value.trim();
        const resultsDiv = document.getElementById('placeSearchResults');
        const placeIdInput = document.getElementById('placeId');
        
        if (!resultsDiv) {
            return;
        }
        
        // 이전 타이머 클리어
        clearTimeout(searchTimeout);
        
        if (searchTerm.length < 2) {
            resultsDiv.style.setProperty('display', 'none', 'important');
            placeIdInput.value = '';
            return;
        }
        
        // 300ms 후에 검색 실행 (타이핑 중단 시)
        searchTimeout = setTimeout(() => {
            // main.jsp와 동일한 방식으로 클라이언트에서 필터링
            const filtered = hotplaceNameList.filter(function(item) {
                return item && item.toLowerCase().indexOf(searchTerm.toLowerCase()) !== -1;
            }).slice(0, 8); // 최대 8개
            
            resultsDiv.innerHTML = '';
            
            if (filtered.length > 0) {
                // main.jsp와 동일한 방식으로 단순하게 표시
                resultsDiv.innerHTML = filtered.map(function(placeName) {
                    const place = hotplaceList.find(p => p.name === placeName);
                    if (place) {
                        return '<div class="autocomplete-item" style="padding:10px 18px; font-size:1.04rem; color:#222 !important; cursor:pointer; transition:background 0.13s; border-bottom:1px solid #f3f3f3; background:transparent;" data-place-id="' + place.id + '" data-place-name="' + place.name + '" data-place-address="' + place.address + '">' + placeName + '</div>';
                    }
                    return '';
                }).join('');
                
                // 클릭 이벤트 추가
                Array.from(resultsDiv.children).forEach(function(child) {
                    child.onclick = function() {
                        const placeId = this.getAttribute('data-place-id');
                        const placeName = this.getAttribute('data-place-name');
                        const placeAddress = this.getAttribute('data-place-address');
                        document.getElementById('placeSearch').value = placeName + ' - ' + placeAddress;
                        document.getElementById('placeId').value = placeId;
                        resultsDiv.style.setProperty('display', 'none', 'important');
                    };
                });
                
                resultsDiv.style.setProperty('display', 'flex', 'important');
            } else {
                resultsDiv.innerHTML = '<div class="autocomplete-item" style="padding:10px 18px; font-size:1.04rem; color:#666; text-align:center;">검색 결과가 없습니다.</div>';
                resultsDiv.style.setProperty('display', 'flex', 'important');
            }
        }, 300);
    });
    
    // 검색 결과 외부 클릭 시 닫기
    document.addEventListener('click', function(e) {
        const resultsDiv = document.getElementById('placeSearchResults');
        const searchInput = document.getElementById('placeSearch');
        
        if (!searchInput.contains(e.target) && !resultsDiv.contains(e.target)) {
            resultsDiv.style.setProperty('display', 'none', 'important');
        }
    });
}

// 스타일: hover 효과 (main.jsp와 동일)
var style = document.createElement('style');
style.innerHTML = `.autocomplete-item:hover { background: #f0f4fa !important; color: #1275E0 !important; }`;
document.head.appendChild(style);

function registerMd() {
    const form = document.getElementById('mdRegisterForm');
    const formData = new FormData(form);
    
    // 필수 필드 검증
    const mdName = formData.get('mdName');
    const placeId = formData.get('placeId');
    
    if (!mdName || !placeId) {
        alert('필수 항목을 모두 입력해주세요.');
        return;
    }
    
    // AJAX로 전송
    fetch('<%= root %>/clubmd/mdRegisterAction.jsp', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert('MD가 성공적으로 등록되었습니다.');
            location.reload(); // 페이지 새로고침
        } else {
            alert('MD 등록에 실패했습니다: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('MD 등록 중 오류가 발생했습니다.');
    });
}

// MD 찜 토글 함수
function toggleMdWish(mdId, button) {
    const isWished = button.getAttribute('data-wished') === 'true';
    const action = isWished ? 'remove' : 'add';
    
    // 버튼 비활성화 (중복 클릭 방지)
    button.disabled = true;
    
    // AJAX 요청
    const formData = new URLSearchParams();
    formData.append('action', action);
    formData.append('mdId', mdId);
    
    fetch('<%= root %>/clubmd/mdWishAction.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // 찜 상태 토글
            const newWished = !isWished;
            button.setAttribute('data-wished', newWished);
            
            // 아이콘 변경
            const icon = button.querySelector('i');
            if (newWished) {
                icon.className = 'bi bi-heart-fill text-danger';
            } else {
                icon.className = 'bi bi-heart text-muted';
            }
            
            // 버튼 활성화
            button.disabled = false;
        } else {
            alert(data.message);
            button.disabled = false;
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('찜 처리 중 오류가 발생했습니다.');
        button.disabled = false;
    });
}
</script>