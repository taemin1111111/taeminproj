<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hpost.HpostDto" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");
    String root = request.getContextPath();
    
 // 파일 업로드 설정 - 경로를 /hpostsave로 통일
    String uploadPath = application.getRealPath("/hpostsave");
    System.out.println("Upload Path: " + uploadPath); // 디버깅용
    
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        boolean created = uploadDir.mkdirs();
        System.out.println("Directory created: " + created); // 디버깅용
    }
    
    int maxSize = 10 * 1024 * 1024; // 10MB
    MultipartRequest multi = new MultipartRequest(request, uploadPath, maxSize, "UTF-8", new DefaultFileRenamePolicy());
    
    try {
        // 폼 데이터 받기
        int category_id = Integer.parseInt(multi.getParameter("category_id"));
        String userid = multi.getParameter("userid");
        String userip = multi.getParameter("userip");
        String nickname = multi.getParameter("nickname");
        String passwd = multi.getParameter("passwd");
        String title = multi.getParameter("title");
        String content = multi.getParameter("content");
        
        // 파일명 받기
        String photo1 = multi.getFilesystemName("photo1");
        String photo2 = multi.getFilesystemName("photo2");
        String photo3 = multi.getFilesystemName("photo3");
        
        // DTO에 데이터 설정
        HpostDto dto = new HpostDto();
        dto.setCategory_id(category_id);
        dto.setUserid(userid);
        dto.setUserip(userip);
        dto.setNickname(nickname);
        dto.setPasswd(passwd);
        dto.setTitle(title);
        dto.setContent(content);
        dto.setPhoto1(photo1);
        dto.setPhoto2(photo2);
        dto.setPhoto3(photo3);
        
        // DAO로 데이터베이스에 저장
        HpostDao dao = new HpostDao();
        int newId = dao.insertPost(dto);
        if(newId > 0) {
            // 최신순에서 몇 번째 글인지 구함
            int rowNum = dao.getRowNumberById(newId, dto.getCategory_id());
            int perPage = 30;
            int targetPage = (rowNum - 1) / perPage + 1;
            %>
            <script>
                alert('글이 성공적으로 작성되었습니다!');
                // 해당 글이 있는 페이지로 이동 (헌팅썰 목록)
                window.location.href = '<%=root%>/index.jsp?main=community/cumain.jsp&page=<%=targetPage%>#post<%=newId%>';
            </script>
            <%
        } else {
            // 실패 시 에러 메시지
            %>
            <script>
                alert('글쓰기에 실패했습니다. 다시 시도해주세요.');
                history.back();
            </script>
            <%
        }
        
    } catch(Exception e) {
        // 로그 기록 (개발 환경에서만)
        if(application.getInitParameter("debug") != null) {
            e.printStackTrace();
        }
        %>
        <script>
            alert('오류가 발생했습니다.');
            history.back();
        </script>
        <%
    }
%>
