using Application.Interfaces.ExternalServices;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using MimeKit;
using MimeKit.Text;

namespace Infrastructure.ExternalServices
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task<bool> SendEmailAsync(string email, string message)
        {
            try
            {
                var emailSettings = _configuration.GetSection("EmailSettings");

                var mimeMessage = new MimeMessage();
                mimeMessage.From.Add(new MailboxAddress("FSchool System", emailSettings["Email"]));
                mimeMessage.To.Add(MailboxAddress.Parse(email));
                mimeMessage.Subject = "FSchool - Mã xác thực OTP";
                mimeMessage.Body = new TextPart(TextFormat.Html) { Text = $@"
                    <div style='font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px; max-width: 500px; margin: auto;'>
                        <h2 style='color: #FF9800; text-align: center;'>Xác thực OTP - FSchool</h2>
                        <p>Chào bạn,</p>
                        <p>Bạn đang thực hiện thao tác yêu cầu mã OTP. Mã của bạn là:</p>
                        <div style='background: #f4f4f4; padding: 15px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 5px; color: #333;'>
                            {message}
                        </div>
                        <p style='color: #777; font-size: 12px; margin-top: 20px;'>Mã này có hiệu lực trong vòng 5 phút. Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email.</p>
                        <hr style='border: 0; border-top: 1px solid #eee;' />
                        <p style='text-align: center; color: #999; font-size: 11px;'>Đây là email tự động, vui lòng không phản hồi.</p>
                    </div>" 
                };

                using var smtp = new SmtpClient();
                await smtp.ConnectAsync(emailSettings["Host"], int.Parse(emailSettings["Port"]!), SecureSocketOptions.StartTls);
                await smtp.AuthenticateAsync(emailSettings["Email"], emailSettings["Password"]);
                await smtp.SendAsync(mimeMessage);
                await smtp.DisconnectAsync(true);

                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"--- LỖI GỬI EMAIL: {ex.Message} ---");
                return false;
            }
        }
    }
}
