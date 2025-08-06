<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="MD.MdWishDao" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json; charset=UTF-8");
    
    String loginId = (String)session.getAttribute("loginid");
    
    // 로그인 체크
    if (loginId == null) {
        out.print("{\"success\":false,\"message\":\"로그인이 필요합니다.\"}");
        return;
    }
    
    String action = request.getParameter("action");
    String mdIdParam = request.getParameter("mdId");
    

    
    if (action == null || mdIdParam == null) {
        out.print("{\"success\":false,\"message\":\"필수 파라미터가 누락되었습니다. action=" + action + ", mdId=" + mdIdParam + "\"}");
        return;
    }
    
    try {
        int mdId = Integer.parseInt(mdIdParam);
        
        // MD ID가 0이거나 음수인 경우 체크
        if (mdId <= 0) {
            out.print("{\"success\":false,\"message\":\"잘못된 MD ID입니다. (ID: " + mdId + ")\"}");
            return;
        }
        
        MdWishDao wishDao = new MdWishDao();
        
        if ("add".equals(action)) {
            // 찜 추가
            if (wishDao.addMdWish(mdId, loginId)) {
                out.print("{\"success\":true,\"message\":\"찜이 추가되었습니다.\",\"action\":\"added\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"찜 추가에 실패했습니다.\"}");
            }
        } else if ("remove".equals(action)) {
            // 찜 삭제
            if (wishDao.removeMdWish(mdId, loginId)) {
                out.print("{\"success\":true,\"message\":\"찜이 삭제되었습니다.\",\"action\":\"removed\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"찜 삭제에 실패했습니다.\"}");
            }
        } else {
            out.print("{\"success\":false,\"message\":\"잘못된 액션입니다.\"}");
        }
        
    } catch (NumberFormatException e) {
        out.print("{\"success\":false,\"message\":\"잘못된 MD ID입니다.\"}");
    } catch (Exception e) {
        out.print("{\"success\":false,\"message\":\"오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
    }
%> 