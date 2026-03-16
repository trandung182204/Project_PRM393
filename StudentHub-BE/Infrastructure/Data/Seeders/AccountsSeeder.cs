using BCrypt.Net;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders
{
    public class AccountsSeeder : ISeeder
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<AccountsSeeder> _logger;

        public int Order => 1;

        public AccountsSeeder(
            ApplicationDbContext context,
            ILogger<AccountsSeeder> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task SeedAsync()
        {
            if (await _context.Accounts.AnyAsync())
            {
                _logger.LogInformation("Accounts already seeded, skipping...");
                return;
            }

            var studentPassword = BCrypt.Net.BCrypt.HashPassword("123456");
            var staffPassword = BCrypt.Net.BCrypt.HashPassword("123456");

            var studentRole = new Role { RoleName = "Student" };
            var adminRole = new Role { RoleName = "Admin" };
            var staffRole = new Role { RoleName = "Staff" };

            await _context.Roles.AddRangeAsync(studentRole, adminRole, staffRole);

            var accounts = new List<Account>
            {
                new Account
                {
                    PhoneNumber = "0900000001",
                    PasswordHash = studentPassword,
                    Roles = new List<Role> { studentRole }, // Seed multiple roles for this account
                    Email = "thangmoneo2542004@gmail.com"
                },
                new Account
                {
                    PhoneNumber = "0900000003",
                    PasswordHash = studentPassword,
                    Roles = new List<Role> { adminRole },
                    Email = "thangbachi2542004@gmail.com"
                },
                new Account
                {
                    PhoneNumber = "0900000002",
                    PasswordHash = staffPassword,
                    Roles = new List<Role> { staffRole , adminRole},
                    Email = "thangdqhe180102@fpt.edu.vn"
                }
            };

            await _context.Accounts.AddRangeAsync(accounts);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Seeded {Count} accounts", accounts.Count);
        }
    }
}
