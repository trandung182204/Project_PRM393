using Application.DTOs.Admin;
using Application.DTOs.Auth;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto> LoginAsync(LoginRequestDto request);
        Task SendOtpAsync(string phoneNumber);
        Task ResetPasswordAsync(VerifyOtpRequest request);
        Task LogoutAsync();
        Task CreateAccountAsync(CreateAccountDto request);
        Task<AuthResponseDto> GoogleLoginAsync(string idToken);
    }
}
