<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@ page import="java.net.*, java.io.*" %>

<%
request.setCharacterEncoding("UTF-8");    
String root = request.getContextPath();

    // 네이버에서 발급받은 내 ClientID/Secret
    String clientId = "Uhipu8CFRcKrmTNw5xie";
    String clientSecret = "32CliACoQi";

    String code = request.getParameter("code");
    String state = request.getParameter("state");

    String callbackUrl = "http://localhost:8083" + root + "/login/naverCallback.jsp";
    String redirectURI = URLEncoder.encode(callbackUrl, "UTF-8");

    // 토큰 요청 URL
    String tokenUrl = "https://nid.naver.com/oauth2.0/token"
        + "?grant_type=authorization_code"
        + "&client_id=" + clientId
        + "&client_secret=" + clientSecret
        + "&redirect_uri=" + redirectURI
        + "&code=" + code
        + "&state=" + state;

    URL url = new URL(tokenUrl);
    HttpURLConnection con = (HttpURLConnection)url.openConnection();
    con.setRequestMethod("GET");

    BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
    StringBuffer sb = new StringBuffer();
    String line;
    while ((line = br.readLine()) != null) sb.append(line);
    br.close();

    JSONObject tokenJson = new JSONObject(sb.toString());
    String access_token = tokenJson.getString("access_token");

    // 사용자 프로필 요청
    String apiURL2 = "https://openapi.naver.com/v1/nid/me";
    URL url2 = new URL(apiURL2);
    HttpURLConnection con2 = (HttpURLConnection)url2.openConnection();
    con2.setRequestMethod("GET");
    con2.setRequestProperty("Authorization", "Bearer " + access_token);

    BufferedReader br2 = new BufferedReader(new InputStreamReader(con2.getInputStream(), "UTF-8"));
    StringBuffer sb2 = new StringBuffer();
    while ((line = br2.readLine()) != null) sb2.append(line);
    br2.close();

    JSONObject userJson = new JSONObject(sb2.toString());
    JSONObject responseJson = userJson.getJSONObject("response");

    // 네이버 정보 세션에 저장
    session.setAttribute("naverId", responseJson.optString("id"));
    session.setAttribute("name", responseJson.optString("name"));
    session.setAttribute("email", responseJson.optString("email"));
    session.setAttribute("gender", responseJson.optString("gender"));
    session.setAttribute("birthyear", responseJson.optString("birthyear"));
    session.setAttribute("birthday", responseJson.optString("birthday"));

    // 다음 페이지로 이동
    response.sendRedirect(root + "/login/naverJoin.jsp");
%>
