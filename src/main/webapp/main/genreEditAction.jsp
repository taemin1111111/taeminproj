<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="ClubGenre.*" %>
<%
request.setCharacterEncoding("UTF-8");
response.setContentType("application/json; charset=UTF-8");

String loginId = (String)session.getAttribute("loginid");
String provider = (String)session.getAttribute("provider");

// 관리자 권한 확인
if(loginId == null || !"admin".equals(provider)) {
    out.print("{\"success\":false,\"message\":\"관리자만 장르를 편집할 수 있습니다.\"}");
    return;
}

String action = request.getParameter("action");
String placeIdStr = request.getParameter("placeId");
String genreIdStr = request.getParameter("genreId");
String genreName = request.getParameter("genreName");

if(placeIdStr == null || placeIdStr.trim().isEmpty()) {
    out.print("{\"success\":false,\"message\":\"장소 ID가 필요합니다.\"}");
    return;
}

try {
    int placeId = Integer.parseInt(placeIdStr);
    ClubGenreDao clubGenreDao = new ClubGenreDao();
    
    if("add".equals(action)) {
        // 장르 추가
        if(genreIdStr == null || genreIdStr.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"장르 ID가 필요합니다.\"}");
            return;
        }
        
        int genreId = Integer.parseInt(genreIdStr);
        try {
            clubGenreDao.addGenreToPlace(placeId, genreId);
            
            // 업데이트된 장르 목록 반환
            List<ClubGenreDto> genres = clubGenreDao.getGenresByPlaceId(placeId);
            String genreNames = "";
            if(genres != null && !genres.isEmpty()) {
                genreNames = genres.stream()
                    .map(genre -> genre.getGenreName())
                    .reduce((a, b) -> a + ", " + b)
                    .orElse("");
            }
            
            out.print("{\"success\":true,\"message\":\"장르가 추가되었습니다.\",\"genres\":\"" + genreNames + "\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"장르 추가에 실패했습니다.\"}");
        }
        
    } else if("remove".equals(action)) {
        // 장르 제거
        if(genreIdStr == null || genreIdStr.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"장르 ID가 필요합니다.\"}");
            return;
        }
        
        int genreId = Integer.parseInt(genreIdStr);
        try {
            clubGenreDao.removeGenreFromPlace(placeId, genreId);
            
            // 업데이트된 장르 목록 반환
            List<ClubGenreDto> genres = clubGenreDao.getGenresByPlaceId(placeId);
            String genreNames = "";
            if(genres != null && !genres.isEmpty()) {
                genreNames = genres.stream()
                    .map(genre -> genre.getGenreName())
                    .reduce((a, b) -> a + ", " + b)
                    .orElse("");
            }
            
            out.print("{\"success\":true,\"message\":\"장르가 제거되었습니다.\",\"genres\":\"" + genreNames + "\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"장르 제거에 실패했습니다.\"}");
        }
        
    } else if("getGenres".equals(action)) {
        // 장르 목록 조회
        List<ClubGenreDto> allGenres = clubGenreDao.getAllGenres();
        List<ClubGenreDto> placeGenres = clubGenreDao.getGenresByPlaceId(placeId);
        
        StringBuilder allGenresJson = new StringBuilder("[");
        for(int i = 0; i < allGenres.size(); i++) {
            ClubGenreDto genre = allGenres.get(i);
            boolean isSelected = placeGenres.stream().anyMatch(pg -> pg.getGenreId() == genre.getGenreId());
            
            allGenresJson.append("{\"genreId\":").append(genre.getGenreId())
                        .append(",\"genreName\":\"").append(genre.getGenreName())
                        .append("\",\"isSelected\":").append(isSelected).append("}");
            
            if(i < allGenres.size() - 1) {
                allGenresJson.append(",");
            }
        }
        allGenresJson.append("]");
        
        out.print("{\"success\":true,\"genres\":" + allGenresJson.toString() + "}");
        
    } else {
        out.print("{\"success\":false,\"message\":\"잘못된 액션입니다.\"}");
    }
    
} catch (NumberFormatException e) {
    out.print("{\"success\":false,\"message\":\"잘못된 숫자 형식입니다.\"}");
} catch (Exception e) {
    e.printStackTrace();
    out.print("{\"success\":false,\"message\":\"장르 편집 중 오류가 발생했습니다.\"}");
}
%>
