using Application.DTOs.Auth;
using Application.Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace FSchool.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
        {
            var response = await _authService.LoginAsync(request);
            return Ok(response);
        }

        [HttpPost("forgot-password/send-otp")]
        public async Task<IActionResult> SendOtp([FromBody] SendOtpRequest request)
        {
            await _authService.SendOtpAsync(request.PhoneNumber);
            return Ok(new { message = "Mã OTP đã được gửi." });
        }

        [HttpPost("forgot-password/reset")]
        public async Task<IActionResult> ResetPassword([FromBody] VerifyOtpRequest request)
        {
            await _authService.ResetPasswordAsync(request);
            return Ok(new { message = "Đổi mật khẩu thành công." });
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            await _authService.LogoutAsync();
            return Ok(new { message = "Đăng xuất thành công." });
        }

        [HttpPost("google")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequestDto request)
        {
            var response = await _authService.GoogleLoginAsync(request.IdToken);
            return Ok(response);
        }
    }
}
