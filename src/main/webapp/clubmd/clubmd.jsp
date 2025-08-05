<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="MD.MdDao" %>
<%@ page import="MD.MdDto" %>
<%@ page import="hotplace_info.HotplaceDao" %>
<%@ page import="hotplace_info.HotplaceDto" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String nickname = (String)session.getAttribute("nickname");
    String provider = (String)session.getAttribute("provider");
    
    // MD 정보와 장소 정보를 함께 조회
    MdDao mdDao = new MdDao();
    List<Map<String, Object>> mdList = mdDao.getMdWithPlaceInfo();
    int mdCount = mdDao.getMdCount();
    
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

<div class="container">
    <div class="card-box">
        <div class="section-title">
            <i class="bi bi-chat-dots"></i>
            클럽 MD 예약 창
        </div>
        
        <!-- 관리자만 MD 등록 버튼 표시 -->
        <% if("admin".equals(provider)) { %>
            <div class="text-end mb-3">
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#mdRegisterModal">
                    <i class="bi bi-plus-circle"></i> MD 등록
                </button>
            </div>
        <% } %>
        
        <!-- MD 정보 출력 -->
        <% if(mdCount > 0) { %>
            <div class="row">
                <% for(Map<String, Object> md : mdList) { %>
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card h-100">
                            <% if(md.get("photo") != null && !md.get("photo").toString().isEmpty()) { %>
                                <img src="<%= root %>/mdphotos/<%= md.get("photo") %>" class="card-img-top" alt="MD 사진" style="height: 200px; object-fit: cover;">
                            <% } else { %>
                                <div class="card-img-top bg-light d-flex align-items-center justify-content-center" style="height: 200px;">
                                    <i class="bi bi-person-circle" style="font-size: 4rem; color: #ccc;"></i>
                                </div>
                            <% } %>
                            <div class="card-body">
                                <h5 class="card-title"><%= md.get("mdName") %></h5>
                                <p class="card-text">
                                    <i class="bi bi-geo-alt"></i> <%= md.get("placeName") %>
                                </p>
                                <p class="card-text text-muted">
                                    <small><%= md.get("address") %></small>
                                </p>
                                <% if(md.get("contact") != null && !md.get("contact").toString().isEmpty()) { %>
                                    <p class="card-text">
                                        <i class="bi bi-telephone"></i> <%= md.get("contact") %>
                                    </p>
                                <% } %>
                                <% if(md.get("description") != null && !md.get("description").toString().isEmpty()) { %>
                                    <p class="card-text"><%= md.get("description") %></p>
                                <% } %>
                            </div>
                            <div class="card-footer text-muted">
                                <small>등록일: <%= md.get("createdAt") != null ? md.get("createdAt").toString().substring(0, 10) : "" %></small>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <!-- MD가 없을 때 메시지 -->
            <div class="text-center py-5">
                <i class="bi bi-exclamation-triangle text-warning" style="font-size: 3rem;"></i>
                <h4 class="mt-3">등록된 MD가 없습니다</h4>
                <p class="text-muted">현재 등록된 MD가 없습니다.</p>
                <p class="text-muted">관리자에게 연락해서 MD 등록을 해주세요!</p>
            </div>
        <% } %>
    </div>
</div>

<!-- MD 등록 모달 -->
<div class="modal fade" id="mdRegisterModal" tabindex="-1" aria-labelledby="mdRegisterModalLabel" aria-hidden="true">
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
</script>