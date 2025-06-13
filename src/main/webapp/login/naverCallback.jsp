<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.json.JSONObject"%>
<%@ page import="java.net.*, java.io.*, Member.MemberDAO, DB.DbConnect" %>

<%
request.setCharacterEncoding("UTF-8");    
String root = request.getContextPath();

String clientId = "Uhipu8CFRcKrmTNw5xie";
String clientSecret = "32CliACoQi";

String code = request.getParameter("code");
String state = request.getParameter("state");

String callbackUrl = "http://localhost:8083" + root + "/login/naverCallback.jsp";
String redirectURI = URLEncoder.encode(callbackUrl, "UTF-8");

// ① access token 발급
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

// ② 사용자 프로필 요청
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

String naverId = responseJson.optString("id");
String name = responseJson.optString("name");
String email = responseJson.optString("email");
String gender = responseJson.optString("gender");
String birthyear = responseJson.optString("birthyear");
String birthday = responseJson.optString("birthday");

// ③ DB에서 이미 회원인지 확인
MemberDAO dao = new MemberDAO();
boolean exists = dao.isDuplicateId(naverId);

if (exists) {
    // 👉 이미 회원이면 로그인
    session.setAttribute("loginid", naverId);
   
    response.sendRedirect(root + "/index.jsp");
} else {
    // 👉 아직 회원가입 안했으면 네이버 정보 세션저장 → 회원가입 폼으로 이동
    session.setAttribute("naverId", naverId);
    session.setAttribute("name", name);
    session.setAttribute("email", email);
    session.setAttribute("gender", gender);
    session.setAttribute("birthyear", birthyear);
    session.setAttribute("birthday", birthday);

    response.sendRedirect(root + "/login/naverJoin.jsp");
}
%>
