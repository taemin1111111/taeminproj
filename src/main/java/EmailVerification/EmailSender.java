
package EmailVerification;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailSender {
    
	// Brevo SMTP 설정
	private static final String SMTP_HOST = "smtp-relay.brevo.com";
	private static final String SMTP_PORT = "587";
	private static final String SMTP_USERNAME = "93959a002@smtp-brevo.com";   // 인증된 이메일
	private static final String SMTP_PASSWORD = "gyEmT1QbCR5XjwaN";          // Master Password (SMTP Key)
	private static final String FROM_EMAIL = "chotaemin0920@gmail.com";     // 보내는 사람 주소
	private static final String FROM_NAME = "어디핫?";                        // 보내는 사람 이름

    // 이메일 발송 메서드
    public static boolean sendVerificationEmail(String toEmail, String verificationCode) {
        try {
            // SMTP 설정
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            
            // 인증 정보
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USERNAME, SMTP_PASSWORD);
                }
            });
            
            // 메시지 생성
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("[어디핫?] 이메일 인증번호");
            message.setText(createEmailContent(verificationCode));
            
            // 이메일 발송
            Transport.send(message);
            System.out.println("이메일 발송 성공: " + toEmail);
            return true;
            
        } catch (Exception e) {
            System.out.println("이메일 발송 오류: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 이메일 내용 생성
    private static String createEmailContent(String verificationCode) {
        return "안녕하세요! 어디핫? 회원가입을 위한 인증번호입니다.\n\n" +
               "인증번호: " + verificationCode + "\n" +
               "만료시간: 10분 후\n\n" +
               "본인이 요청하지 않은 경우 무시하세요.\n\n" +
               "감사합니다.\n" +
               "어디핫? 팀";
    }
    
    // 테스트용 메서드 - 이메일 발송 없이 성공 반환
    public static boolean sendVerificationEmailTest(String toEmail, String verificationCode) {
        try {
            // 실제 이메일 발송 대신 로그만 출력
            System.out.println("이메일 발송 테스트:");
            System.out.println("받는 사람: " + toEmail);
            System.out.println("인증번호: " + verificationCode);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
} 