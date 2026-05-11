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

        public EmailService(IConfiguration config)
        {
            _config = config;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            var emailHost = _config["EmailSettings:Host"];
            var emailPort = int.Parse(_config["EmailSettings:Port"] ?? "587");
            var fromEmail = _config["EmailSettings:Email"] ?? throw new ArgumentNullException("Thiếu EmailSettings:Email trong appsettings.json");
            var appPassword = _config["EmailSettings:Password"];

           
            var email = new MimeMessage();
            email.Sender = MailboxAddress.Parse(fromEmail);
            email.To.Add(MailboxAddress.Parse(toEmail));
            email.Subject = subject;

            var builder = new BodyBuilder
            {
                HtmlBody = body 
            };
            email.Body = builder.ToMessageBody();

            using var smtp = new SmtpClient();

            try
            {
                await smtp.ConnectAsync(emailHost!, emailPort, SecureSocketOptions.StartTls);

                await smtp.AuthenticateAsync(fromEmail, appPassword!);

                await smtp.SendAsync(email);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi gửi mail: {ex.Message}");
                throw;
            }
            finally
            {
                await smtp.DisconnectAsync(true);
            }
        }
    }
}
