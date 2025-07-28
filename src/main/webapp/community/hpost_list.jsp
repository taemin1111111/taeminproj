<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>

<%
    HpostDao dao = new HpostDao();
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
    int perPage = 10;
    int start = 0;
    List<HpostDto> posts = dao.getPostsByCategory(1, start, perPage);
%>
<div class="category-posts">
    <h3 class="posts-category-title">❤️ 헌팅썰</h3>
    <div class="posts-list">
        <% if(posts != null && !posts.isEmpty()) {
            for(HpostDto post : posts) { %>
                <div class="post-item">
                    <div class="post-title">
                        <a href="<%=request.getContextPath()%>/community/view.jsp?id=<%= post.getId() %>">
                            <%= post.getTitle() %>
                        </a>
                    </div>
                    <div class="post-meta">
                        <span class="post-author"><%= post.getUserid() %></span>
                        <span class="post-date"><%= post.getCreated_at() != null ? sdf.format(post.getCreated_at()) : "" %></span>
                        <span class="post-views">👁️ <%= post.getViews() %></span>
                        <span class="post-likes">👍 <%= post.getLikes() %></span>
                    </div>
                </div>
        <%  }
        } else { %>
            <div class="no-posts">
                <p>아직 글이 없습니다. 첫 번째 글을 작성해보세요!</p>
            </div>
        <% } %>
    </div>
    <div class="view-all-link">
        <a href="<%=request.getContextPath()%>/community/htalk.jsp" class="view-all-btn">헌팅썰 전체보기 →</a>
    </div>
</div> 