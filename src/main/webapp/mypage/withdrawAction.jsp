<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="Member.MemberDAO" %>
<%@ page import="Member.MemberDTO" %>
<%@ page import="wishList.WishListDao" %>
<%@ page import="hpost.HpostDao" %>
<%@ page import="hottalk_comment.Hottalk_CommentDao" %>
<%@ page import="hottalk_vote.HottalkVoteDao" %>
<%@ page import="hottalk_comment_vote.HottalkCommentVoteDao" %>
<%@ page import="hottalk_report.Hottalk_ReportDao" %>


<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String loginId = (String)session.getAttribute("loginid");
String password = request.getParameter("password");

// 로그인하지 않은 경우
if(loginId == null) {
    out.print("{\"result\":false,\"message\":\"로그인이 필요합니다.\"}");
    return;
}

// 비밀번호가 입력되지 않은 경우
if(password == null || password.trim().isEmpty()) {
    out.print("{\"result\":false,\"message\":\"비밀번호를 입력해주세요.\"}");
    return;
}

try {
    MemberDAO memberDao = new MemberDAO();
    MemberDTO member = memberDao.getMember(loginId);
    
    if(member == null) {
        out.print("{\"result\":false,\"message\":\"회원 정보를 찾을 수 없습니다.\"}");
        return;
    }
    
    // 비밀번호 확인 (평문 비교)
    if(!password.equals(member.getPasswd())) {
        out.print("{\"result\":false,\"message\":\"비밀번호가 일치하지 않습니다.\"}");
        return;
    }
    
    // 네이버 로그인 사용자는 탈퇴 불가
    if("naver".equals(member.getProvider())) {
        out.print("{\"result\":false,\"message\":\"네이버 로그인 사용자는 회원 탈퇴가 불가능합니다.\"}");
        return;
    }
    
    // 트랜잭션 시작
    Connection conn = null;
    try {
        System.out.println("데이터베이스 연결 시도 중...");
        conn = memberDao.getConnection();
        if(conn == null) {
            System.out.println("데이터베이스 연결 실패: conn이 null입니다.");
            out.print("{\"result\":false,\"message\":\"데이터베이스 연결에 실패했습니다.\"}");
            return;
        }
        System.out.println("데이터베이스 연결 성공");
        
        conn.setAutoCommit(false);
        
        // 1. 위시리스트 삭제
        try {
            System.out.println("위시리스트 삭제 시작...");
            WishListDao wishDao = new WishListDao();
            boolean wishResult = wishDao.deleteAllWishListByUserid(loginId, conn);
            System.out.println("위시리스트 삭제 결과: " + wishResult);
        } catch (Exception e) {
            System.out.println("위시리스트 삭제 중 오류: " + e.getMessage());
            throw e;
        }
        
        // 2. 게시글 관련 데이터 삭제
        try {
            System.out.println("게시글 삭제 시작...");
            HpostDao postDao = new HpostDao();
            boolean postResult = postDao.deleteAllPostsByUserid(loginId, conn);
            System.out.println("게시글 삭제 결과: " + postResult);
        } catch (Exception e) {
            System.out.println("게시글 삭제 중 오류: " + e.getMessage());
            throw e;
        }
        
        // 3. 댓글 관련 데이터 삭제
        try {
            System.out.println("댓글 삭제 시작...");
            Hottalk_CommentDao commentDao = new Hottalk_CommentDao();
            boolean commentResult = commentDao.deleteAllCommentsByUserid(loginId, conn);
            System.out.println("댓글 삭제 결과: " + commentResult);
        } catch (Exception e) {
            System.out.println("댓글 삭제 중 오류: " + e.getMessage());
            throw e;
        }
        
        // 4. 투표 관련 데이터 삭제 (나중에 구현)
        // HottalkVoteDao voteDao = new HottalkVoteDao();
        // voteDao.deleteAllVotesByUserid(loginId, conn);
        
        // 5. 댓글 투표 관련 데이터 삭제 (나중에 구현)
        // HottalkCommentVoteDao commentVoteDao = new HottalkCommentVoteDao();
        // commentVoteDao.deleteAllCommentVotesByUserid(loginId, conn);
        
        // 6. 신고 관련 데이터 삭제 (나중에 구현)
        // Hottalk_ReportDao reportDao = new Hottalk_ReportDao();
        // reportDao.deleteAllReportsByUserid(loginId, conn);
        
        // 7. 회원 정보 삭제
        boolean deleteResult = false;
        try {
            System.out.println("회원 정보 삭제 시작...");
            deleteResult = memberDao.deleteMember(loginId, conn);
            System.out.println("회원 정보 삭제 결과: " + deleteResult);
        } catch (Exception e) {
            System.out.println("회원 정보 삭제 중 오류: " + e.getMessage());
            throw e;
        }
        
        if(deleteResult) {
            conn.commit();
            session.invalidate(); // 세션 무효화
            System.out.println("회원 탈퇴 완료");
            out.print("{\"result\":true,\"message\":\"회원 탈퇴가 완료되었습니다.\"}");
        } else {
            conn.rollback();
            System.out.println("회원 정보 삭제 실패로 롤백");
            out.print("{\"result\":false,\"message\":\"회원 탈퇴 처리 중 오류가 발생했습니다.\"}");
        }
        
    } catch (Exception e) {
        if(conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.out.println("롤백 중 오류: " + ex.getMessage());
            }
        }
        System.out.println("회원 탈퇴 처리 중 오류: " + e.getMessage());
        e.printStackTrace();
        out.print("{\"result\":false,\"message\":\"회원 탈퇴 처리 중 오류가 발생했습니다.\"}");
    } finally {
        if(conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
                System.out.println("데이터베이스 연결 종료");
            } catch (SQLException e) {
                System.out.println("연결 종료 중 오류: " + e.getMessage());
            }
        }
    }
    
} catch (Exception e) {
    System.out.println("전체 처리 중 오류: " + e.getMessage());
    e.printStackTrace();
    out.print("{\"result\":false,\"message\":\"회원 탈퇴 처리 중 오류가 발생했습니다.\"}");
}
%> 