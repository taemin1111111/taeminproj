<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="MD.MdDao" %>
<%@ page import="MD.MdDto" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String nickname = (String)session.getAttribute("nickname");
    String provider = (String)session.getAttribute("provider");
    
    // MD 정보 조회
    MdDao mdDao = new MdDao();
    List<MdDto> mdList = mdDao.getAllVisibleMd();
    int mdCount = mdDao.getMdCount();
%>

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
                <% for(MdDto md : mdList) { %>
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card h-100">
                            <% if(md.getPhoto() != null && !md.getPhoto().isEmpty()) { %>
                                <img src="<%= root %>/mdphotos/<%= md.getPhoto() %>" class="card-img-top" alt="MD 사진" style="height: 200px; object-fit: cover;">
                            <% } else { %>
                                <div class="card-img-top bg-light d-flex align-items-center justify-content-center" style="height: 200px;">
                                    <i class="bi bi-person-circle" style="font-size: 4rem; color: #ccc;"></i>
                                </div>
                            <% } %>
                            <div class="card-body">
                                <h5 class="card-title"><%= md.getMdName() %></h5>
                                <p class="card-text text-muted"><%= md.getClubName() %></p>
                                <% if(md.getContact() != null && !md.getContact().isEmpty()) { %>
                                    <p class="card-text">
                                        <i class="bi bi-telephone"></i> <%= md.getContact() %>
                                    </p>
                                <% } %>
                                <% if(md.getDescription() != null && !md.getDescription().isEmpty()) { %>
                                    <p class="card-text"><%= md.getDescription() %></p>
                                <% } %>
                            </div>
                            <div class="card-footer text-muted">
                                <small>등록일: <%= md.getCreatedAt() != null ? md.getCreatedAt().toString().substring(0, 10) : "" %></small>
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
                                <label for="clubName" class="form-label">클럽명 *</label>
                                <input type="text" class="form-control" id="clubName" name="clubName" required>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="region" class="form-label">지역 *</label>
                                <select class="form-select" id="region" name="region" required>
                                    <option value="">지역을 선택해주세요</option>
                                    <option value="강남">강남</option>
                                    <option value="홍대">홍대</option>
                                    <option value="신촌">신촌</option>
                                    <option value="이태원">이태원</option>
                                    <option value="건대">건대</option>
                                    <option value="잠실">잠실</option>
                                    <option value="강서">강서</option>
                                    <option value="기타">기타</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="contact" class="form-label">연락처</label>
                                <input type="text" class="form-control" id="contact" name="contact" 
                                       placeholder="인스타 아이디 또는 오픈채팅 링크">
                            </div>
                        </div>
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
function registerMd() {
    const form = document.getElementById('mdRegisterForm');
    const formData = new FormData(form);
    
    // 필수 필드 검증
    const mdName = formData.get('mdName');
    const clubName = formData.get('clubName');
    const region = formData.get('region');
    
    if (!mdName || !clubName || !region) {
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
        </div>
    </div>
</div>