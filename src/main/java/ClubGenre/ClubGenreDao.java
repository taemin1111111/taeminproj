package ClubGenre;

import DB.DbConnect;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClubGenreDao {
    private DbConnect db = new DbConnect();
    
    // 모든 장르 조회
    public List<ClubGenreDto> getAllGenres() {
        List<ClubGenreDto> list = new ArrayList<>();
        String sql = "SELECT * FROM club_genre ORDER BY genre_name";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ClubGenreDto dto = new ClubGenreDto();
                dto.setGenreId(rs.getInt("genre_id"));
                dto.setGenreName(rs.getString("genre_name"));
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return list;
    }
    
    // 장르 ID로 조회
    public ClubGenreDto getGenreById(int genreId) {
        String sql = "SELECT * FROM club_genre WHERE genre_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, genreId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                ClubGenreDto dto = new ClubGenreDto();
                dto.setGenreId(rs.getInt("genre_id"));
                dto.setGenreName(rs.getString("genre_name"));
                return dto;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return null;
    }
    
    // 장르 추가
    public void insertGenre(ClubGenreDto dto) {
        String sql = "INSERT INTO club_genre (genre_name) VALUES (?)";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getGenreName());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 장르 수정
    public void updateGenre(ClubGenreDto dto) {
        String sql = "UPDATE club_genre SET genre_name = ? WHERE genre_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getGenreName());
            pstmt.setInt(2, dto.getGenreId());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 장르 삭제
    public void deleteGenre(int genreId) {
        String sql = "DELETE FROM club_genre WHERE genre_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, genreId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 특정 클럽의 장르들 조회
    public List<ClubGenreDto> getGenresByPlaceId(int placeId) {
        List<ClubGenreDto> list = new ArrayList<>();
        String sql = "SELECT cg.* FROM club_genre cg " +
                    "INNER JOIN hotplace_genre_map hgm ON cg.genre_id = hgm.genre_id " +
                    "WHERE hgm.place_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, placeId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ClubGenreDto dto = new ClubGenreDto();
                dto.setGenreId(rs.getInt("genre_id"));
                dto.setGenreName(rs.getString("genre_name"));
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return list;
    }
    
    // 클럽에 장르 매핑 추가
    public void addGenreToPlace(int placeId, int genreId) {
        String sql = "INSERT INTO hotplace_genre_map (place_id, genre_id) VALUES (?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, placeId);
            pstmt.setInt(2, genreId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 클럽에서 장르 매핑 제거
    public void removeGenreFromPlace(int placeId, int genreId) {
        String sql = "DELETE FROM hotplace_genre_map WHERE place_id = ? AND genre_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, placeId);
            pstmt.setInt(2, genreId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 클럽의 모든 장르 매핑 제거
    public void removeAllGenresFromPlace(int placeId) {
        String sql = "DELETE FROM hotplace_genre_map WHERE place_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, placeId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(pstmt, conn);
        }
    }
    
    // 특정 장르를 가진 클럽들 조회
    public List<Integer> getPlaceIdsByGenre(int genreId) {
        List<Integer> placeIds = new ArrayList<>();
        String sql = "SELECT place_id FROM hotplace_genre_map WHERE genre_id = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, genreId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                placeIds.add(rs.getInt("place_id"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return placeIds;
    }
    
    // 장르 이름으로 검색
    public List<ClubGenreDto> searchGenresByName(String keyword) {
        List<ClubGenreDto> list = new ArrayList<>();
        String sql = "SELECT * FROM club_genre WHERE genre_name LIKE ? ORDER BY genre_name";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ClubGenreDto dto = new ClubGenreDto();
                dto.setGenreId(rs.getInt("genre_id"));
                dto.setGenreName(rs.getString("genre_name"));
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        
        return list;
    }
}
