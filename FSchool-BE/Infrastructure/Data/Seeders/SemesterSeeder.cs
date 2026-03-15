using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class SemesterSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<SemesterSeeder> _logger;

    public int Order => 1;

    public SemesterSeeder(
        ApplicationDbContext context,
        ILogger<SemesterSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Semesters.AnyAsync())
        {
            _logger.LogInformation("Semesters already seeded, skipping...");
            return;
        }

        var semesters = new List<Semester>
        {
            new Semester
            {
                Name = "Spring 2026",
                StartDate = new DateTime(2026, 1, 1),
                EndDate = new DateTime(2026, 4, 30)
            },
            new Semester
            {
                Name = "Summer 2026",
                StartDate = new DateTime(2026, 5, 1),
                EndDate = new DateTime(2026, 8, 31)
            },
            new Semester
            {
                Name = "Fall 2026",
                StartDate = new DateTime(2026, 9, 1),
                EndDate = new DateTime(2026, 12, 31)
            }
        };

        await _context.Semesters.AddRangeAsync(semesters);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} semesters", semesters.Count);
    }
}
