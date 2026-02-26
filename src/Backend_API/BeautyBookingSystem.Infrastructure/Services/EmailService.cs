using BeautyBookingSystem.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using MimeKit;
using MailKit.Net.Smtp;
using MailKit.Security;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _config;

        // Inject IConfiguration để đọc file appsettings.json
        public EmailService(IConfiguration config)
        {
            _config = config;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            // 1. Lấy thông tin từ appsettings.json
            var emailHost = _config["EmailSettings:Host"];
            var emailPort = int.Parse(_config["EmailSettings:Port"] ?? "587");
            var fromEmail = _config["EmailSettings:Email"] ?? throw new ArgumentNullException("Thiếu EmailSettings:Email trong appsettings.json");
            var appPassword = _config["EmailSettings:Password"];

           
            // 2. Tạo nội dung Email (Dùng MimeKit)
            var email = new MimeMessage();
            email.Sender = MailboxAddress.Parse(fromEmail);
            email.To.Add(MailboxAddress.Parse(toEmail));
            email.Subject = subject;

            var builder = new BodyBuilder
            {
                HtmlBody = body // Truyền HTML body vào đây
            };
            email.Body = builder.ToMessageBody();

            // 3. Cấu hình gửi Mail (Dùng MailKit SmtpClient)
            // Lưu ý: SmtpClient này của MailKit, KHÔNG PHẢI của System.Net.Mail
            using var smtp = new SmtpClient();

            try
            {
                // Kết nối tới Server Gmail (Dùng StartTls cho Port 587)
                await smtp.ConnectAsync(emailHost, emailPort, SecureSocketOptions.StartTls);

                // Xác thực tài khoản
                await smtp.AuthenticateAsync(fromEmail, appPassword);

                // Gửi Mail
                await smtp.SendAsync(email);
            }
            catch (Exception ex)
            {
                // Log lỗi ra đây nếu cần thiết
                Console.WriteLine($"Lỗi gửi mail: {ex.Message}");
                throw;
            }
            finally
            {
                // Ngắt kết nối một cách an toàn
                await smtp.DisconnectAsync(true);
            }
        }
    }
}
