import smtplib
from email.mime.text import MIMEText
from app.core.config import EMAIL_HOST, EMAIL_PORT, EMAIL_USERNAME, EMAIL_PASSWORD, EMAIL_FROM


def send_email(to_email: str, subject: str, body: str):
    msg = MIMEText(body, "html")
    msg["Subject"] = subject
    msg["From"] = EMAIL_FROM
    msg["To"] = to_email

    try:
        with smtplib.SMTP(EMAIL_HOST, EMAIL_PORT) as server:
            server.starttls()
            server.login(EMAIL_USERNAME, EMAIL_PASSWORD)
            server.send_message(msg)

    except Exception as e:
        print("Email error:", e)
        raise Exception("Cannot send email")

def send_otp_email(to_email: str, otp: str):
    subject = "Mã OTP đặt lại mật khẩu - AI Algebra Chatbot"

    body = f"""
    <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f7f6; padding: 40px 20px; text-align: center;">

        <div style="max-width: 500px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #eaeaea;">

            <div style="background-color: #2E86C1; padding: 24px; color: #ffffff;">
                <h2 style="margin: 0; font-size: 22px; font-weight: 600;">AI Algebra Chatbot</h2>
            </div>

            <div style="padding: 32px 24px;">
                <h3 style="color: #333333; margin-top: 0; font-size: 20px;">Khôi phục mật khẩu 🔐</h3>
                <p style="color: #555555; font-size: 16px; line-height: 1.6; margin-bottom: 24px;">
                    Chào bạn,<br>
                    Bạn vừa yêu cầu đặt lại mật khẩu cho tài khoản của mình. Vui lòng sử dụng mã xác nhận dưới đây để tiếp tục quá trình:
                </p>

                <div style="background-color: #f0f8ff; border: 2px dashed #2E86C1; border-radius: 8px; padding: 20px; margin: 0 auto; max-width: 250px;">
                    <h1 style="color: #2E86C1; font-size: 38px; margin: 0; letter-spacing: 10px; text-align: center;">{otp}</h1>
                </div>

                <p style="color: #e74c3c; font-size: 14px; margin-top: 24px;">
                    ⏳ Mã này chỉ có hiệu lực trong vòng <strong>5 phút</strong>.
                </p>
            </div>

            <div style="background-color: #fcfcfc; padding: 20px; border-top: 1px solid #eeeeee;">
                <p style="color: #888888; font-size: 12px; line-height: 1.5; margin: 0;">
                    Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này. Tài khoản của bạn vẫn an toàn.
                </p>
                <p style="color: #aaaaaa; font-size: 12px; margin: 10px 0 0 0;">
                    &copy; 2026 AI Algebra Support Team
                </p>
            </div>

        </div>
    </div>
    """

    send_email(to_email, subject, body)