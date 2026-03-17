using Application.DTOs.Auth;
using Application.DTOs.Admin;
using Application.Interfaces.ExternalServices;
using Application.Interfaces.Repositories;
using Application.Interfaces.Services;
using Domain.Entities;
using Domain.Exceptions;
using Microsoft.Extensions.Caching.Memory;
using System.Linq;

namespace Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAccountRepository _accountRepository;
        private readonly ITokenService _tokenService;
        private readonly IMemoryCache _cache;
        private readonly IEmailService _emailService;

        public AuthService(IAccountRepository accountRepository, IEmailService emailService, IMemoryCache cache , ITokenService tokenService)
        {
            _accountRepository = accountRepository;
            _emailService = emailService;
            _cache = cache;
            _tokenService = tokenService;
        }

        public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request)
        {
            var account = await _accountRepository.GetByPhoneNumberAsync(request.Phone);

           
            if (account == null || !BCrypt.Net.BCrypt.Verify(request.Password, account.PasswordHash))
            {
                throw new UnauthorizedException("Tài khoản hoặc mật khẩu không chính xác.");
            }

            var token = _tokenService.GenerateJwtToken(account);

            return new AuthResponseDto
            {
                AccessToken = token,
                Id = account.Id,
                RollNumber = account.Student?.RollNumber,
                EmployeeId = account.Staff?.EmployeeId,
                Department = account.Staff?.Department,
                FullName = account.Student?.FullName ?? account.Staff?.FullName,
                Role = account.Roles != null && account.Roles.Any() ? string.Join(",", account.Roles.Select(r => r.RoleName)) : "Unknown",
                ClassId = account.Student?.SchoolClasses?.FirstOrDefault()?.Id,
                StudentId = account.Student?.Id,
                StaffId = account.Staff?.Id
            };
        }

        public async Task ResetPasswordAsync(VerifyOtpRequest request)
        {
            // 1. Lấy mã OTP từ Cache dựa vào số điện thoại
            if (!_cache.TryGetValue($"OTP_{request.PhoneNumber}", out string? savedOtp))
            {
                throw new BadRequestException("Mã OTP đã hết hạn hoặc không tồn tại.");
            }

            // 2. So sánh mã người dùng nhập với mã trong cache
            if (savedOtp != request.OtpCode)
            {
                throw new BadRequestException("Mã OTP không chính xác.");
            }

            // 3. Nếu đúng, tiến hành cập nhật mật khẩu
            var account = await _accountRepository.GetByPhoneAsync(request.PhoneNumber);
            if (account == null) throw new NotFoundException("Tài khoản không còn tồn tại.");

            account.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            await _accountRepository.UpdateAsync(account);

            // 4. Xóa OTP khỏi cache sau khi đổi mật khẩu thành công
            _cache.Remove($"OTP_{request.PhoneNumber}");
        }

        public async Task SendOtpAsync(string phoneNumber)
        {
            var account = await _accountRepository.GetByPhoneAsync(phoneNumber);
            if (account == null) throw new NotFoundException("Số điện thoại chưa được đăng ký.");

            // 1. Tạo mã OTP
            string otp = new Random().Next(100000, 999999).ToString();

            // 2. Lưu OTP vào Cache với Key là số điện thoại
            // Thời gian sống (SlidingExpiration): 5 phút
            var cacheOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromSeconds(20));

            _cache.Set($"OTP_{phoneNumber}", otp, cacheOptions);

            var email = account.Email;

            if (email == null)
            {
                throw new NotFoundException("Tài khoản không có email để gửi OTP.");
            }

            // 3. Gửi SMS
            await _emailService.SendEmailAsync(email, $"Ma OTP cua ban la: {otp}");
            
        }

        public async Task LogoutAsync()
        {
            // Logic for logout
            await Task.CompletedTask;
        }

        public async Task CreateAccountAsync(CreateAccountDto request)
        {
            var existing = await _accountRepository.GetByPhoneAsync(request.PhoneNumber);
            if (existing != null)
            {
                throw new BadRequestException("Số điện thoại đã tồn tại.");
            }

            var account = new Account
            {
                PhoneNumber = request.PhoneNumber,
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password)
            };

            // Assuming we must attach existing roles or at least create one for the new account
            // This would normally be handled safely via a RoleRepository.
            account.Roles = new List<Role> { new Role { RoleName = request.Role } };

            if (request.Role == "Student")
            {
                account.Student = new Student
                {
                    FullName = request.FullName,
                    RollNumber = request.RollNumber ?? "N/A"
                };
            }
            else if (request.Role == "Staff")
            {
                account.Staff = new Staff
                {
                    FullName = request.FullName,
                    EmployeeId = request.EmployeeId ?? "N/A",
                    Department = request.Department ?? "N/A"
                };
            }

            await _accountRepository.AddAsync(account);
        }

        public async Task<AuthResponseDto> GoogleLoginAsync(string idToken)
        {
            // Validate Google ID Token
            var settings = new Google.Apis.Auth.GoogleJsonWebSignature.ValidationSettings
            {
                // Note: Configure Client ID here if needed in production
            };

            Google.Apis.Auth.GoogleJsonWebSignature.Payload payload;
            try
            {
                payload = await Google.Apis.Auth.GoogleJsonWebSignature.ValidateAsync(idToken, settings);
            }
            catch (Exception ex)
            {
                throw new UnauthorizedException("Google Token không hợp lệ: " + ex.Message);
            }

            var email = payload.Email;
            if (string.IsNullOrEmpty(email))
            {
                throw new UnauthorizedException("Không thể lấy email từ Google.");
            }

            var account = await _accountRepository.GetByEmailAsync(email);

            // Auto-register if not found
            if (account == null)
            {
                var randomPhone = "G" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString(); // Temporary unique phone
                var newAccount = new Account
                {
                    Email = email,
                    PhoneNumber = randomPhone,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(Guid.NewGuid().ToString()) // random password
                };

                newAccount.Roles = new List<Role> { new Role { RoleName = "Student" } };
                newAccount.Student = new Student
                {
                    FullName = payload.Name ?? "Google User",
                    RollNumber = "G" + Guid.NewGuid().ToString().Substring(0, 6).ToUpper(),
                    AvatarUrl = payload.Picture ?? ""
                };

                await _accountRepository.AddAsync(newAccount);
                account = await _accountRepository.GetByEmailAsync(email); // load with includes
            }

            var token = _tokenService.GenerateJwtToken(account);

            return new AuthResponseDto
            {
                AccessToken = token,
                Id = account.Id,
                RollNumber = account.Student?.RollNumber,
                EmployeeId = account.Staff?.EmployeeId,
                Department = account.Staff?.Department,
                FullName = account.Student?.FullName ?? account.Staff?.FullName,
                Role = account.Roles != null && account.Roles.Any() ? string.Join(",", account.Roles.Select(r => r.RoleName)) : "Unknown",
                ClassId = account.Student?.SchoolClasses?.FirstOrDefault()?.Id,
                StudentId = account.Student?.Id,
                StaffId = account.Staff?.Id
            };
        }
        public async Task ChangePasswordAsync(int accountId, ChangePasswordRequestDto request)
        {
            var account = await _accountRepository.GetByIdAsync(accountId);
            if (account == null) throw new NotFoundException("Tài khoản không tồn tại.");

            if (!BCrypt.Net.BCrypt.Verify(request.OldPassword, account.PasswordHash))
            {
                throw new BadRequestException("Mật khẩu cũ không chính xác.");
            }

            if (request.NewPassword != request.ConfirmPassword)
            {
                throw new BadRequestException("Mật khẩu xác nhận không khớp.");
            }

            account.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            await _accountRepository.UpdateAsync(account);
        }
    }
    
}
