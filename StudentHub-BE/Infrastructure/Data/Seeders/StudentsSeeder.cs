using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Data.Seeders
{
    public class StudentsSeeder : ISeeder
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<StudentsSeeder> _logger;

        public int Order => 2;

        public StudentsSeeder(
            ApplicationDbContext context,
            ILogger<StudentsSeeder> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task SeedAsync()
        {
            if (await _context.Students.AnyAsync())
            {
                _logger.LogInformation("Students already seeded, skipping...");
                return;
            }

            var studentAccounts = await _context.Accounts
                .Where(a => a.PhoneNumber == "0900000001")
                .OrderBy(a => a.PhoneNumber)
                .ToListAsync();

            var schoolClasses = await _context.Classes.OrderBy(c => c.Id).ToListAsync();

            if (!studentAccounts.Any())
            {
                _logger.LogWarning("No student accounts found, skipping student seeding");
                return;
            }

            var students = new List<Student>();

            // Student 1 -> Class 1
            if (studentAccounts.Count > 0)
            {
                students.Add(new Student
                {
                    FullName = "Nguyen Van A",
                    RollNumber = "SE001",
                    AvatarUrl = "https://example.com/avatar1.jpg",
                    AccountId = studentAccounts[0].Id,
                    SchoolClasses = schoolClasses.Take(1).ToList()
                });
            }

            // Student 2 -> Class 2
            if (studentAccounts.Count > 1)
            {
                students.Add(new Student
                {
                    FullName = "Tran Thi B",
                    RollNumber = "SE002",
                    AvatarUrl = "https://example.com/avatar2.jpg",
                    AccountId = studentAccounts[1].Id,
                    SchoolClasses = schoolClasses.Skip(1).Take(1).ToList()
                });
            }

            await _context.Students.AddRangeAsync(students);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Seeded {Count} students linked to classes", students.Count);
        }
    }
}
