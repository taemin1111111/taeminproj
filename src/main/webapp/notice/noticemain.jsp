<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="Notice.*" %>
<%
  request.setCharacterEncoding("UTF-8");
  String root = request.getContextPath();
  String loginProvider = (String)session.getAttribute("provider");

  NoticeDao dao = new NoticeDao();

  // 페이징 설정
  int perPage = 10;
  int pageNum = 1;
  try { 
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.trim().isEmpty()) {
      pageNum = Integer.parseInt(pageParam);
    }
  } catch(Exception ignore) {}
  if (pageNum < 1) pageNum = 1;
  int start = (pageNum - 1) * perPage;

  int totalCount = dao.getTotalCount();
  int totalPage = (int)Math.ceil(totalCount / (double)perPage);
  if (totalPage == 0) totalPage = 1;
  if (pageNum > totalPage) pageNum = totalPage;

  List<NoticeDto> list = dao.getNoticesWithPaging(start, perPage);
%>

<div class="notice-container">
  <div class="notice-header">
    <div class="d-flex justify-content-between align-items-center">
      <h3>📢 공지사항</h3>
      <% if ("admin".equals(loginProvider)) { %>
        <a class="btn btn-primary" href="<%=root%>/index.jsp?main=notice/noticeinset.jsp">✏️ 공지 등록</a>
      <% } %>
    </div>
  </div>

  <% if (list == null || list.size() == 0) { %>
    <div class="notice-empty">
      <div class="empty-icon">📝</div>
      <h4>등록된 공지사항이 없습니다</h4>
      <p>새로운 공지사항을 등록해보세요.</p>
    </div>
  <% } else { %>
    <div class="notice-list">
      <% for (int i = 0; i < list.size(); i++) { 
           NoticeDto n = list.get(i);
      %>
        <div class="notice-item <%= n.isPinned() ? "pinned" : "" %>">
          <a href="<%=root%>/index.jsp?main=notice/noticeDetail.jsp&id=<%=n.getNoticeId()%>" class="notice-content">
            <div class="notice-title">
              <% if (n.isPinned()) { %>
                <span class="pinned-badge">고정</span>
              <% } %>
              <%= n.getTitle() %>
            </div>
            <div class="notice-meta">
              <span>👤 <%= n.getWriter() %></span>
              <span>👁️ <%= n.getViewCount() %></span>
              <span>📅 <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(n.getCreatedAt()) %></span>
            </div>
          </a>
          <% if ("admin".equals(loginProvider)) { %>
            <div class="notice-actions">
              <a class="btn btn-outline-secondary" href="<%=root%>/notice/togglePinned.jsp?id=<%=n.getNoticeId()%>">🔗 고정 토글</a>
              <a class="btn btn-outline-danger" href="<%=root%>/notice/delete.jsp?id=<%=n.getNoticeId()%>&return=noticemain.jsp" onclick="return confirm('삭제하시겠습니까?');">🗑️ 삭제</a>
            </div>
          <% } %>
        </div>
      <% } %>
    </div>

    <!-- 페이징 -->
    <div class="notice-pagination">
      <nav>
        <ul class="pagination">
          <li class="page-item <%= (pageNum==1?"disabled":"") %>"><a class="page-link" href="<%=root%>/index.jsp?main=notice/noticemain.jsp&page=<%=pageNum-1%>">◀ 이전</a></li>
          <% for(int p=1; p<=totalPage; p++){ %>
            <li class="page-item <%= (p==pageNum?"active":"") %>"><a class="page-link" href="<%=root%>/index.jsp?main=notice/noticemain.jsp&page=<%=p%>"><%=p%></a></li>
          <% } %>
          <li class="page-item <%= (pageNum==totalPage?"disabled":"") %>"><a class="page-link" href="<%=root%>/index.jsp?main=notice/noticemain.jsp&page=<%=pageNum+1%>">다음 ▶</a></li>
        </ul>
      </nav>
    </div>
  <% } %>
</div>

<!-- Bootstrap JS 필요 (사이트 전역에서 이미 포함되어 있으면 생략 가능) -->
<script>
// 빈 영역
</script>