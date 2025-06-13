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

}
