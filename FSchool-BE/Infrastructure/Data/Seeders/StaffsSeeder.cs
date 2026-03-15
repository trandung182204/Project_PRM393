using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Data.Seeders
{
    public class StaffsSeeder : ISeeder
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<StaffsSeeder> _logger;

        public int Order => 3;

        public StaffsSeeder(
            ApplicationDbContext context,
            ILogger<StaffsSeeder> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task SeedAsync()
        {
            if (await _context.Staffs.AnyAsync())
            {
                _logger.LogInformation("Staffs already seeded, skipping...");
                return;
            }

            // Tìm tài khoản Staff
            var staffAccount = await _context.Accounts
                .FirstOrDefaultAsync(a => a.PhoneNumber == "0900000002");

            // Tìm tài khoản Admin
            var adminAccount = await _context.Accounts
                .FirstOrDefaultAsync(a => a.PhoneNumber == "0900000003");

            var staffs = new List<Staff>();

            // Thêm Staff nếu tìm thấy tài khoản
            if (staffAccount != null)
            {
                staffs.Add(new Staff
                {
                    FullName = "Tran Thi B",
                    EmployeeId = "EMP001",
                    Department = "Information Technology",
                    AccountId = staffAccount.Id
                });
            }
            else
            {
                _logger.LogWarning("Staff account not found, skipping staff seeding for EMP001");
            }

            // Thêm Admin vào bảng Staff nếu tìm thấy tài khoản
            if (adminAccount != null)
            {
                staffs.Add(new Staff
                {
                    FullName = "Nguyen Van Admin", // Bạn có thể đổi tên tùy ý
                    EmployeeId = "ADM001",
                    Department = "Administration",
                    AccountId = adminAccount.Id
                });
            }
            else
            {
                _logger.LogWarning("Admin account not found, skipping staff seeding for ADM001");
            }

            // Nếu có ít nhất 1 staff được tạo ra thì lưu vào db
            if (staffs.Any())
            {
                await _context.Staffs.AddRangeAsync(staffs);
                await _context.SaveChangesAsync();
                _logger.LogInformation("Seeded {Count} staffs", staffs.Count);
            }
            else
            {
                _logger.LogWarning("No accounts found to seed into Staffs table.");
            }
        }
    }
}