using Application.Interfaces.Services;
using Application.DTOs.Admin;
using Microsoft.AspNetCore.Mvc;

namespace StudentHub.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AdminController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("create-account")]
        public async Task<IActionResult> CreateAccount([FromBody] CreateAccountDto request)
        {
            await _authService.CreateAccountAsync(request);
            return Ok(new { message = "Tạo tài khoản thành công." });
        }
    }
}
