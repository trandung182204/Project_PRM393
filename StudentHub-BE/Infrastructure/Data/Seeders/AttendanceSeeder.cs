using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class AttendanceSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AttendanceSeeder> _logger;

    public int Order => 4; // Depends on Schedule and Student

    public AttendanceSeeder(
        ApplicationDbContext context,
        ILogger<AttendanceSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Attendances.AnyAsync())
        {
            _logger.LogInformation("Attendances already seeded, skipping...");
            return;
        }

        var schedule = await _context.Schedules.FirstOrDefaultAsync();
        var student = await _context.Students.FirstOrDefaultAsync();

        if (schedule == null || student == null)
        {
            _logger.LogWarning("Missing dependencies for Attendance seeding. Skipping...");
            return;
        }

        var attendances = new List<Attendance>
        {
            new Attendance
            {
                Status = "Present",
                StudentId = student.Id,
                ScheduleId = schedule.Id
            }
        };

        await _context.Attendances.AddRangeAsync(attendances);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} attendances", attendances.Count);
    }
}
