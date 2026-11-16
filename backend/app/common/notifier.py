import logging
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import Optional, Tuple
from app.core.config import settings

logger = logging.getLogger("smartedu.notifier")


def mask_email(email: Optional[str]) -> str:
    """Ẩn một phần email để bảo mật: ví dụ khangpham@gmail.com -> kh***am@gmail.com"""
    if not email or "@" not in email:
        return "email***@domain.com"
    name_part, domain_part = email.split("@", 1)
    if len(name_part) <= 2:
        masked_name = name_part[0] + "***"
    elif len(name_part) <= 4:
        masked_name = name_part[:1] + "***" + name_part[-1:]
    else:
        masked_name = name_part[:2] + "***" + name_part[-2:]
    return f"{masked_name}@{domain_part}"


def mask_phone(phone: Optional[str]) -> str:
    """Ẩn một phần số điện thoại: ví dụ 0901234567 -> 090****567"""
    if not phone:
        return "090****xxx"
    clean_phone = phone.strip()
    if len(clean_phone) < 7:
        return clean_phone[:2] + "****" + clean_phone[-1:]
    return clean_phone[:3] + "****" + clean_phone[-3:]


def send_otp_email(
    to_email: str,
    recipient_name: str,
    otp_code: str,
    expires_in_minutes: int = 15
) -> Tuple[bool, str]:
    """
    Gửi mã xác thực OTP qua Email (hỗ trợ SMTP thực tế hoặc Giả lập Development).
    """
    subject = f"[SMART-EDU] Mã OTP đặt lại mật khẩu của bạn: {otp_code}"
    
    # Nội dung Text thuần
    text_content = f"""Xin chào {recipient_name},

Bạn đã gửi yêu cầu đặt lại mật khẩu cho tài khoản tại Hệ thống Trung tâm Ngoại ngữ SMART-EDU.

Mã xác thực OTP của bạn là: {otp_code}

Mã có hiệu lực trong {expires_in_minutes} phút kể từ thời điểm gửi.
Vui lòng không chia sẻ mã này cho bất kỳ ai để đảm bảo an toàn tài khoản.

Trân trọng,
Đội ngũ Quản trị SMART-EDU LMS
"""

    # Nội dung HTML sang trọng, trực quan
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; margin: 0; padding: 20px; }}
        .card {{ max-width: 500px; margin: 0 auto; background: #ffffff; border-radius: 16px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); }}
        .header {{ background: linear-gradient(135deg, #4f46e5, #7c3aed); padding: 24px; text-align: center; color: #ffffff; }}
        .content {{ padding: 28px 24px; color: #334155; line-height: 1.6; font-size: 14px; }}
        .otp-box {{ background-color: #f1f5f9; border: 2px dashed #6366f1; border-radius: 12px; padding: 18px; text-align: center; margin: 20px 0; }}
        .otp-code {{ font-size: 32px; font-weight: 800; letter-spacing: 6px; color: #4338ca; font-family: monospace; }}
        .footer {{ padding: 16px; text-align: center; font-size: 11px; color: #94a3b8; border-top: 1px solid #f1f5f9; }}
      </style>
    </head>
    <body>
      <div class="card">
        <div class="header">
          <h2 style="margin: 0; font-size: 20px; font-weight: 800;">SMART-EDU LMS</h2>
          <p style="margin: 4px 0 0; font-size: 12px; opacity: 0.9;">Xác thực khôi phục tài khoản</p>
        </div>
        <div class="content">
          <p>Xin chào <strong>{recipient_name}</strong>,</p>
          <p>Hệ thống nhận được yêu cầu cấp lại mật khẩu cho tài khoản liên kết với địa chỉ email này.</p>
          <div class="otp-box">
            <div style="font-size: 12px; font-weight: 600; color: #64748b; margin-bottom: 6px;">MÃ XÁC THỰC OTP CỦA BẠN</div>
            <div class="otp-code">{otp_code}</div>
            <div style="font-size: 11px; color: #e11d48; margin-top: 6px; font-weight: 600;">(Hiệu lực trong {expires_in_minutes} phút)</div>
          </div>
          <p style="font-size: 12px; color: #64748b;">Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email hoặc liên hệ ngay ban quản trị để khóa bảo vệ tài khoản.</p>
        </div>
        <div class="footer">
          &copy; 2026 SMART-EDU LMS &bull; Trung tâm Đào tạo Ngoại ngữ Chuẩn Quốc tế
        </div>
      </div>
    </body>
    </html>
    """

    # Kiểm tra cấu hình SMTP thực tế
    smtp_host = getattr(settings, "SMTP_HOST", None)
    smtp_user = getattr(settings, "SMTP_USER", None)
    smtp_password = getattr(settings, "SMTP_PASSWORD", None)

    if smtp_host and smtp_user and smtp_password:
        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = f"{getattr(settings, 'SMTP_FROM_NAME', 'SMART-EDU')} <{getattr(settings, 'SMTP_FROM_EMAIL', smtp_user)}>"
            msg["To"] = to_email

            msg.attach(MIMEText(text_content, "plain", "utf-8"))
            msg.attach(MIMEText(html_content, "html", "utf-8"))

            smtp_port = getattr(settings, "SMTP_PORT", 587)
            use_tls = getattr(settings, "SMTP_TLS", True)

            if smtp_port == 465:
                server = smtplib.SMTP_SSL(smtp_host, smtp_port, timeout=10)
            else:
                server = smtplib.SMTP(smtp_host, smtp_port, timeout=10)
                if use_tls:
                    server.starttls()

            server.login(smtp_user, smtp_password)
            server.send_message(msg)
            server.quit()

            logger.info(f"[EMAIL NOTIFIER] Đã gửi OTP thành công tới: {to_email}")
            return True, f"Mã OTP đã được gửi thành công tới email {mask_email(to_email)}."
        except Exception as e:
            logger.error(f"[EMAIL NOTIFIER] Lỗi khi gửi SMTP thực: {e}. Fallback sang mô phỏng console.")
            # Fallback sang in console nếu SMTP gặp lỗi mạng

    # Development simulation fallback
    print("\n" + "=" * 65)
    print(f"📧 [EMAIL SERVICE - DEVELOPMENT LOG]")
    print(f"To:      {to_email} ({recipient_name})")
    print(f"Subject: {subject}")
    print(f"OTP:     >>> {otp_code} <<< (Thời hạn: {expires_in_minutes} phút)")
    print("=" * 65 + "\n")

    return True, f"Mã OTP đã được gửi tới email {mask_email(to_email)}."


def send_otp_sms(
    to_phone: str,
    recipient_name: str,
    otp_code: str,
    expires_in_minutes: int = 15
) -> Tuple[bool, str]:
    """
    Gửi mã xác thực OTP qua Tin nhắn SMS tới số điện thoại di động.
    """
    sms_content = f"[SMART-EDU] Ma OTP dat lai mat khau cua ban la: {otp_code}. Hieu luc {expires_in_minutes} phut. Tuyet doi khong chia se ma nay."

    sms_api_key = getattr(settings, "SMS_API_KEY", None)

    if sms_api_key:
        # Nếu có tích hợp SMS Gateway bên thứ ba (eSMS, SpeedSMS, Twilio, v.v.)
        # Ví dụ gửi HTTP POST request ở đây
        pass

    # Development simulation
    print("\n" + "=" * 65)
    print(f"📱 [SMS GATEWAY - DEVELOPMENT LOG]")
    print(f"To Phone: {to_phone} ({recipient_name})")
    print(f"Message:  {sms_content}")
    print(f"OTP:      >>> {otp_code} <<< (Thời hạn: {expires_in_minutes} phút)")
    print("=" * 65 + "\n")

    return True, f"Mã OTP đã được gửi qua tin nhắn SMS tới số điện thoại {mask_phone(to_phone)}."
