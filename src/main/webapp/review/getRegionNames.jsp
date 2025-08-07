<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Map.MapDao, java.util.*" %>
<%
    MapDao mapDao = new MapDao();
    List<String> regionNameList = mapDao.getAllRegionNames();
    
    // JSON 형태로 응답
    out.print("[");
    for(int i = 0; i < regionNameList.size(); i++) {
        String regionName = regionNameList.get(i);
        out.print("\"" + regionName.replace("\"", "\\\"") + "\"");
        if(i < regionNameList.size() - 1) {
            out.print(",");
        }
    }
    out.print("]");
%>
