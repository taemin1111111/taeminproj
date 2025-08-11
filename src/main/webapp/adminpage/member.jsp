<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Member.MemberDAO, Member.MemberDTO, java.util.*" %>
<%
    String root = request.getContextPath();
    String loginId = (String)session.getAttribute("loginid");
    String provider = (String)session.getAttribute("provider");
    
    // 관리자 권한 확인
    if(loginId == null || !"admin".equals(provider)) {
        response.sendRedirect(root + "/index.jsp");
        return;
    }
    
    // 페이징 파라미터 처리
    int currentPage = 1;
    int pageSize = 20; // 페이지당 20명
    
    try {
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            currentPage = Integer.parseInt(pageParam);
        }
    } catch (NumberFormatException e) {
        currentPage = 1;
    }
    
    MemberDAO memberDAO = new MemberDAO();
    List<MemberDTO> allMembers = memberDAO.getAllMembers();
    
    // 전체 페이지 수 계산
    int totalMembers = allMembers.size();
    int totalPages = (int) Math.ceil((double) totalMembers / pageSize);
    
    // 현재 페이지 유효성 검사
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages) currentPage = totalPages;
    
    // 현재 페이지에 해당하는 회원 목록 추출
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalMembers);
    
    List<MemberDTO> memberList = new ArrayList<>();
    if (startIndex < totalMembers) {
        memberList = allMembers.subList(startIndex, endIndex);
    }
%>

<div class="admin-container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="page-title"><i class="bi bi-people-fill me-2"></i>회원 관리</h2>
        <a href="<%=root%>/index.jsp?main=main/main.jsp" class="btn btn-secondary">
            <i class="bi bi-arrow-left me-2"></i>메인으로
        </a>
    </div>

        <!-- 통계 카드 -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card text-center stat-card" data-filter="all" style="cursor: pointer;">
                    <div class="card-body">
                        <h3 class="text-primary"><%=totalMembers%></h3>
                        <p class="card-text">전체 회원</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center stat-card" data-filter="naver" style="cursor: pointer;">
                    <div class="card-body">
                        <h3 class="text-info"><%=allMembers.stream().filter(m -> "naver".equals(m.getProvider())).count()%></h3>
                        <p class="card-text">네이버 가입</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center stat-card" data-filter="general" style="cursor: pointer;">
                    <div class="card-body">
                        <h3 class="text-secondary"><%=allMembers.stream().filter(m -> !"admin".equals(m.getProvider()) && !"naver".equals(m.getProvider())).count()%></h3>
                        <p class="card-text">일반 가입</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card text-center stat-card" data-filter="admin" style="cursor: pointer;">
                    <div class="card-body">
                        <h3 class="text-warning"><%=allMembers.stream().filter(m -> "admin".equals(m.getProvider())).count()%></h3>
                        <p class="card-text">관리자</p>
                    </div>
                </div>
            </div>
        </div>
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card text-center stat-card" data-filter="status-C" style="cursor: pointer;">
                    <div class="card-body">
                        <h3 class="text-danger"><%=allMembers.stream().filter(m -> "C".equals(m.getStatus())).count()%></h3>
                        <p class="card-text">정지 회원</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center stat-card" data-filter="status-B" style="cursor: pointer;">
                    <div class="card-body">
                        <h3 class="text-warning"><%=allMembers.stream().filter(m -> "B".equals(m.getStatus())).count()%></h3>
                        <p class="card-text">경고 회원</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center stat-card" data-filter="status-A" style="cursor: pointer;">
                    <div class="card-body">
                        <h3 class="text-success"><%=allMembers.stream().filter(m -> "A".equals(m.getStatus())).count()%></h3>
                        <p class="card-text">활성 회원</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 검색 -->
        <div class="card mb-4">
            <div class="card-body">
                <div class="row align-items-center">
                    <div class="col-md-10">
                        <input type="text" class="form-control" id="searchInput" placeholder="아이디, 이름, 닉네임, 이메일로 검색...">
                    </div>
                    <div class="col-md-2">
                        <button class="btn btn-primary" onclick="searchMembers()">
                            <i class="bi bi-search me-2"></i>검색
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 회원 목록 -->
        <div class="card member-table">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>아이디</th>
                                <th>닉네임</th>
                                <th>이름</th>
                                <th>이메일</th>
                                <th>가입경로</th>
                                <th>상태</th>
                                <th>가입일</th>
                                <th>작업</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for(MemberDTO member : memberList) { %>
                                <tr class="member-row">
                                    <td><%=member.getUserid()%></td>
                                    <td><%=member.getNickname()%></td>
                                    <td><%=member.getName()%></td>
                                    <td><%=member.getEmail()%></td>
                                    <td>
                                        <span class="<%=member.getProvider().equals("admin") ? "provider-admin" : (member.getProvider().equals("naver") ? "provider-naver" : "")%>">
                                            <%=member.getProvider().equals("admin") ? "관리자" : (member.getProvider().equals("naver") ? "네이버" : "일반")%>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="<%=member.getStatus().equals("A") ? "status-active" : (member.getStatus().equals("B") ? "status-warning" : (member.getStatus().equals("C") ? "status-banned" : ""))%>">
                                            <%=member.getStatus().equals("A") ? "활성" : (member.getStatus().equals("B") ? "경고" : (member.getStatus().equals("C") ? "정지" : "비활성"))%>
                                        </span>
                                    </td>
                                    <td><%=member.getRegdate() != null ? member.getRegdate() : "-"%></td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary me-1" onclick="editMemberStatus('<%=member.getUserid()%>', '<%=member.getNickname()%>', '<%=member.getStatus()%>')">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <% if(!member.getUserid().equals("admin")) { %>
                                            <button class="btn btn-sm btn-outline-danger" onclick="deleteMember('<%=member.getUserid()%>', '<%=member.getNickname()%>')">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                                 <!-- 페이징 네비게이션 -->
                 <% if (totalPages > 1) { %>
                     <div class="d-flex justify-content-center mt-4">
                         <nav aria-label="회원 목록 페이지 네비게이션">
                             <ul class="pagination pagination-sm mb-0">
                                 <% for (int i = 1; i <= totalPages; i++) { %>
                                     <li class="page-item <%= (i == currentPage) ? "active" : "" %>">
                                         <a class="page-link" href="?main=adminpage/member.jsp&page=<%=i%>"><%=i%></a>
                                     </li>
                                 <% } %>
                             </ul>
                         </nav>
                     </div>
                 <% } %>
            </div>
        </div>
    </div>

    <script>
        // 현재 활성 필터
        let currentFilter = 'all';
        
        // 통계 카드 클릭 이벤트
        document.addEventListener('DOMContentLoaded', function() {
            const statCards = document.querySelectorAll('.stat-card');
            statCards.forEach(card => {
                card.addEventListener('click', function() {
                    const filter = this.getAttribute('data-filter');
                    filterMembers(filter);
                    
                    // 활성 카드 스타일 변경
                    statCards.forEach(c => c.classList.remove('active-filter'));
                    this.classList.add('active-filter');
                });
            });
        });
        
        // 회원 필터링 함수
        function filterMembers(filter) {
            currentFilter = filter;
            const rows = document.querySelectorAll('.member-row');
            let visibleCount = 0;
            
            rows.forEach(row => {
                let shouldShow = false;
                
                switch(filter) {
                    case 'all':
                        shouldShow = true;
                        break;
                    case 'naver':
                        shouldShow = row.querySelector('td:nth-child(5)').textContent.includes('네이버');
                        break;
                    case 'general':
                        const provider = row.querySelector('td:nth-child(5)').textContent;
                        shouldShow = !provider.includes('네이버') && !provider.includes('관리자');
                        break;
                    case 'admin':
                        shouldShow = row.querySelector('td:nth-child(5)').textContent.includes('관리자');
                        break;
                    case 'status-A':
                        shouldShow = row.querySelector('td:nth-child(6)').textContent.includes('활성');
                        break;
                    case 'status-B':
                        shouldShow = row.querySelector('td:nth-child(6)').textContent.includes('경고');
                        break;
                    case 'status-C':
                        shouldShow = row.querySelector('td:nth-child(6)').textContent.includes('정지');
                        break;
                }
                
                row.style.display = shouldShow ? '' : 'none';
                if (shouldShow) visibleCount++;
            });
            
            // 검색창 초기화
            document.getElementById('searchInput').value = '';
            
            // 필터 정보 표시
            updateFilterInfo(filter, visibleCount);
        }
        
        // 필터 정보 업데이트
        function updateFilterInfo(filter, count) {
            let filterText = '';
            switch(filter) {
                case 'all': filterText = '전체 회원'; break;
                case 'naver': filterText = '네이버 가입'; break;
                case 'general': filterText = '일반 가입'; break;
                case 'admin': filterText = '관리자'; break;
                case 'status-A': filterText = '활성 회원'; break;
                case 'status-B': filterText = '경고 회원'; break;
                case 'status-C': filterText = '정지 회원'; break;
            }
            
            // 필터 정보를 표시할 요소가 있다면 업데이트
            const filterInfo = document.getElementById('filterInfo');
            if (filterInfo) {
                filterInfo.textContent = `${filterText} (${count}명)`;
            }
        }
        
        // 검색 기능 (기존 필터와 함께 작동)
        function searchMembers() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const rows = document.querySelectorAll('.member-row');
            let visibleCount = 0;
            
            rows.forEach(row => {
                // 먼저 현재 필터 조건 확인
                let passesFilter = true;
                if (currentFilter !== 'all') {
                    switch(currentFilter) {
                        case 'naver':
                            passesFilter = row.querySelector('td:nth-child(5)').textContent.includes('네이버');
                            break;
                        case 'general':
                            const provider = row.querySelector('td:nth-child(5)').textContent;
                            passesFilter = !provider.includes('네이버') && !provider.includes('관리자');
                            break;
                        case 'admin':
                            passesFilter = row.querySelector('td:nth-child(5)').textContent.includes('관리자');
                            break;
                        case 'status-A':
                            passesFilter = row.querySelector('td:nth-child(6)').textContent.includes('활성');
                            break;
                        case 'status-B':
                            passesFilter = row.querySelector('td:nth-child(6)').textContent.includes('경고');
                            break;
                        case 'status-C':
                            passesFilter = row.querySelector('td:nth-child(6)').textContent.includes('정지');
                            break;
                    }
                }
                
                // 필터 조건을 통과한 경우에만 검색어 확인
                if (passesFilter) {
                    const text = row.textContent.toLowerCase();
                    const matchesSearch = text.includes(searchTerm);
                    row.style.display = matchesSearch ? '' : 'none';
                    if (matchesSearch) visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });
            
            // 검색 결과 정보 업데이트
            updateFilterInfo(currentFilter, visibleCount);
        }

        // 실시간 검색 (디바운싱)
        let searchTimeout;
        document.getElementById('searchInput').addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(searchMembers, 300);
        });

        // 회원 상태 수정
        function editMemberStatus(userid, nickname, currentStatus) {
            // 모달 생성
            const modal = document.createElement('div');
            modal.className = 'modal fade show';
            modal.style.display = 'block';
            modal.style.backgroundColor = 'rgba(0,0,0,0.5)';
            
                         modal.innerHTML = 
                 '<div class="modal-dialog">' +
                     '<div class="modal-content">' +
                         '<div class="modal-header">' +
                             '<h5 class="modal-title" style="color: #000;">회원 상태 수정</h5>' +
                             '<button type="button" class="btn-close" onclick="this.closest(\'.modal\').remove()"></button>' +
                         '</div>' +
                         '<div class="modal-body">' +
                             '<p style="color: #000;"><strong>' + nickname + '</strong> 회원의 상태를 변경합니다.</p>' +
                            '<div class="mb-3">' +
                                '<label for="newStatus" class="form-label">새로운 상태:</label>' +
                                '<select class="form-select" id="newStatus">' +
                                    '<option value="A" ' + (currentStatus === 'A' ? 'selected' : '') + '>A - 활성</option>' +
                                    '<option value="B" ' + (currentStatus === 'B' ? 'selected' : '') + '>B - 경고</option>' +
                                    '<option value="C" ' + (currentStatus === 'C' ? 'selected' : '') + '>C - 정지</option>' +
                                '</select>' +
                            '</div>' +
                        '</div>' +
                        '<div class="modal-footer">' +
                            '<button type="button" class="btn btn-secondary" onclick="this.closest(\'.modal\').remove()">취소</button>' +
                            '<button type="button" class="btn btn-primary" onclick="confirmStatusChange(\'' + userid + '\', \'' + nickname + '\')">상태 변경</button>' +
                        '</div>' +
                    '</div>' +
                '</div>';
            
            document.body.appendChild(modal);
        }

        // 상태 변경 확인 및 실행
        function confirmStatusChange(userid, nickname) {
            const newStatus = document.getElementById('newStatus').value;
            const statusText = newStatus === 'A' ? '활성' : newStatus === 'B' ? '경고' : '정지';
            
            if (confirm(`정말로 ${nickname} 회원의 상태를 '${statusText}'로 변경하시겠습니까?`)) {
                // 상태 변경 요청
                fetch('<%=root%>/adminpage/changeMemberStatusAction.jsp', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'userid=' + encodeURIComponent(userid) + '&status=' + encodeURIComponent(newStatus)
                })
                .then(response => response.text())
                .then(text => {
                    try {
                        const data = JSON.parse(text);
                        if (data.success) {
                            alert('상태가 변경되었습니다.');
                            location.reload();
                        } else {
                            alert('오류: ' + data.message);
                        }
                    } catch (e) {
                        alert('서버 응답 오류');
                    }
                })
                .catch(error => alert('오류: ' + error.message));
                
                // 모달 닫기
                document.querySelector('.modal').remove();
            }
        }

        // 회원 삭제
        function deleteMember(userid, nickname) {
            if (confirm('정말로 ' + nickname + ' 회원을 삭제하시겠습니까?')) {
                fetch('<%=root%>/adminpage/deleteMemberAction.jsp', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'userid=' + encodeURIComponent(userid)
                })
                .then(response => response.text())
                .then(text => {
                    try {
                        const data = JSON.parse(text);
                        if (data.success) {
                            alert('회원이 삭제되었습니다.');
                            location.reload();
                        } else {
                            alert('오류: ' + data.message);
                        }
                    } catch (e) {
                        alert('서버 응답 오류');
                    }
                })
                .catch(error => alert('오류: ' + error.message));
            }
        }
        
        // 페이지 로드 시 초기화
        document.addEventListener('DOMContentLoaded', function() {
            // 초기 필터 정보 설정
            updateFilterInfo('all', '<%=totalMembers%>');
        });
    </script>
    

