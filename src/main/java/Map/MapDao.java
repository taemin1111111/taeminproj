package Map;

import java.sql.*;
import java.util.*;
import DB.DbConnect;

public class MapDao {
    DbConnect db = new DbConnect();

    // ✅ 시도 → 시군구 → 동 리스트
    public Map<String, Map<String, List<String>>> getDeepRegionMap() {
        Map<String, Map<String, List<String>>> regionMap = new LinkedHashMap<>();

        String sql = "SELECT sido, sigungu, dong FROM place_info ORDER BY sido, sigungu, dong";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                String sido = rs.getString("sido");
                String sigungu = rs.getString("sigungu");
                String dong = rs.getString("dong");

                // 시도 없으면 넣고
                regionMap.putIfAbsent(sido, new LinkedHashMap<>());

                // 시군구 없으면 넣고
                Map<String, List<String>> sigunguMap = regionMap.get(sido);
                sigunguMap.putIfAbsent(sigungu, new ArrayList<>());

                // 동 추가
                sigunguMap.get(sigungu).add(dong);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }

        return regionMap;
    }
 // ✅ 특정 시군구(sigungu)에 포함된 모든 동 리스트 가져오기
    public List<String> getDongsBySigungu(String sigungu) {
        List<String> dongs = new ArrayList<>();
        String sql = "SELECT dong FROM place_info WHERE sigungu = ? ORDER BY dong";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sigungu);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                dongs.add(rs.getString("dong"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }

        return dongs;
    }

    // ✅ 모든 시군구의 중심좌표와 이름 반환
    public List<Map<String, Object>> getAllSigunguCenters() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT sido, sigungu, AVG(lat) AS lat, AVG(lng) AS lng FROM place_info GROUP BY sido, sigungu";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("sido", rs.getString("sido"));
                map.put("sigungu", rs.getString("sigungu"));
                map.put("lat", rs.getDouble("lat"));
                map.put("lng", rs.getDouble("lng"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        return list;
    }

    // ✅ 시군구별 카테고리별 핫플레이스 개수 반환
    public List<Map<String, Object>> getSigunguCategoryCounts() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.sigungu, p.lat, p.lng, " +
                "SUM(CASE WHEN h.category_id = 1 THEN 1 ELSE 0 END) AS clubCount, " +
                "SUM(CASE WHEN h.category_id = 2 THEN 1 ELSE 0 END) AS huntingCount, " +
                "SUM(CASE WHEN h.category_id = 3 THEN 1 ELSE 0 END) AS loungeCount, " +
                "SUM(CASE WHEN h.category_id = 4 THEN 1 ELSE 0 END) AS pochaCount " +
                "FROM place_info p " +
                "LEFT JOIN hotplace_info h ON p.id = h.region_id " +
                "GROUP BY p.sigungu, p.lat, p.lng";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("sigungu", rs.getString("sigungu"));
                map.put("lat", rs.getDouble("lat"));
                map.put("lng", rs.getDouble("lng"));
                map.put("clubCount", rs.getInt("clubCount"));
                map.put("huntingCount", rs.getInt("huntingCount"));
                map.put("loungeCount", rs.getInt("loungeCount"));
                map.put("pochaCount", rs.getInt("pochaCount"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        return list;
    }

    // ✅ 모든 동/구의 id, sido, sigungu, dong, lat, lng 반환
    public List<Map<String, Object>> getAllRegionCenters() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, sido, sigungu, dong, lat, lng FROM place_info";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("sido", rs.getString("sido"));
                map.put("sigungu", rs.getString("sigungu"));
                map.put("dong", rs.getString("dong"));
                map.put("lat", rs.getDouble("lat"));
                map.put("lng", rs.getDouble("lng"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        return list;
    }

    // ✅ region_id(동/구 id)별 카테고리별 핫플 개수 반환
    public List<Map<String, Object>> getRegionCategoryCounts() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT h.region_id, " +
                "SUM(CASE WHEN h.category_id = 1 THEN 1 ELSE 0 END) AS clubCount, " +
                "SUM(CASE WHEN h.category_id = 2 THEN 1 ELSE 0 END) AS huntingCount, " +
                "SUM(CASE WHEN h.category_id = 3 THEN 1 ELSE 0 END) AS loungeCount, " +
                "SUM(CASE WHEN h.category_id = 4 THEN 1 ELSE 0 END) AS pochaCount " +
                "FROM hotplace_info h GROUP BY h.region_id";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("region_id", rs.getInt("region_id"));
                map.put("clubCount", rs.getInt("clubCount"));
                map.put("huntingCount", rs.getInt("huntingCount"));
                map.put("loungeCount", rs.getInt("loungeCount"));
                map.put("pochaCount", rs.getInt("pochaCount"));
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        return list;
    }

    // 모든 지역명(동/구/시 등) 리스트 반환 (자동완성용)
    public List<String> getAllRegionNames() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT dong FROM place_info ORDER BY dong";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = db.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(rs.getString(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.dbClose(rs, pstmt, conn);
        }
        return list;
    }
}
