<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>
<%@ page import="java.sql.Timestamp" %>

<%
    String root = request.getContextPath();
    String loginid = (String)session.getAttribute("loginid");
    String nickname = (String)session.getAttribute("nickname");
    
    // 로그인 여부 확인
    boolean isLoggedIn = (loginid != null);
    
    // 아이디 설정 (로그인 시: userid에 loginid, 비로그인 시: userip에 IP)
    String userid = isLoggedIn ? loginid : null;
    String userip = isLoggedIn ? null : request.getRemoteAddr();
%>

<div class="write-container">
    <div class="write-container">
        <div class="write-header">
            <h2 class="write-title">❤️ 헌팅썰 글쓰기</h2>
            <button type="button" class="back-btn" onclick="loadCategoryPosts(1, '헌팅썰')">← 목록으로</button>
        </div>
        
        <form action="<%=root%>/community/hpost_insertaction.jsp" method="post" enctype="multipart/form-data" class="write-form" id="writeForm">
            <input type="hidden" name="category_id" value="1">
            <input type="hidden" name="userid" value="<%= userid %>">
            <input type="hidden" name="userip" value="<%= userip %>">
            
            <div class="form-group">
                <label for="nickname" class="form-label">닉네임 *</label>
                <input type="text" id="nickname" name="nickname" class="form-input" required 
                       value="<%= isLoggedIn ? nickname : "" %>" 
                       maxlength="<%= isLoggedIn ? "20" : "5" %>" 
                       <%= isLoggedIn ? "readonly" : "placeholder=\"닉네임을 입력하세요 (최대 5글자)\"" %>>
            </div>
            
            
            <div class="form-group">
                <label for="passwd" class="form-label">비밀번호 *</label>
                <input type="password" id="passwd" name="passwd" class="form-input" required 
                       placeholder="글 수정/삭제 시 필요합니다" maxlength="20">
            </div>
            
            <div class="form-group">
                <label class="form-label">사진 첨부 (선택)</label>
                <div class="photo-upload-container">
                    <div class="photo-upload-item">
                        <label for="photo1" class="photo-upload-label" id="photo1-label">
                            <span class="photo-upload-text" id="photo1-text">+</span>
                            <img id="photo1-preview" class="photo-preview" style="display: none;">
                        </label>
                        <input type="file" id="photo1" name="photo1" class="photo-input" accept="image/*" onchange="updatePhotoPreview(this, 'photo1')" style="display: none;">
                    </div>
                    <div class="photo-upload-item">
                        <label for="photo2" class="photo-upload-label" id="photo2-label">
                            <span class="photo-upload-text" id="photo2-text">+</span>
                            <img id="photo2-preview" class="photo-preview" style="display: none;">
                        </label>
                        <input type="file" id="photo2" name="photo2" class="photo-input" accept="image/*" onchange="updatePhotoPreview(this, 'photo2')" style="display: none;">
                    </div>
                    <div class="photo-upload-item">
                        <label for="photo3" class="photo-upload-label" id="photo3-label">
                            <span class="photo-upload-text" id="photo3-text">+</span>
                            <img id="photo3-preview" class="photo-preview" style="display: none;">
                        </label>
                        <input type="file" id="photo3" name="photo3" class="photo-input" accept="image/*" onchange="updatePhotoPreview(this, 'photo3')" style="display: none;">
                    </div>
                </div>
            </div>
            
            <div class="form-group">
                <label for="title" class="form-label">제목 *</label>
                <input type="text" id="title" name="title" class="form-input" required 
                       placeholder="제목을 입력해주세요" maxlength="100">
            </div>
            
            <div class="form-group">
                <label for="content" class="form-label">내용 *</label>
                <textarea id="content" name="content" class="form-textarea" required 
                          placeholder="헌팅 관련 이야기나 경험을 자유롭게 작성해주세요" rows="10"></textarea>
            </div>
            
            <div class="form-actions">
                <button type="submit" class="submit-btn">작성완료</button>
                <button type="button" class="cancel-btn" onclick="history.back()">취소</button>
            </div>
        </form>
    </div>
</div>

<script>
// 전역 함수로 정의 
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
</script>