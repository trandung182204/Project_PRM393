using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class SubjectSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<SubjectSeeder> _logger;

    public int Order => 1;

    public SubjectSeeder(
        ApplicationDbContext context,
        ILogger<SubjectSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Subjects.AnyAsync())
        {
            _logger.LogInformation("Subjects already seeded, skipping...");
            return;
        }

        var subjects = new List<Subject>
        {
            new Subject { SubjectCode = "PRN211", SubjectName = "Basic Cross-Platform Application Programming with .NET", Credits = 3 },
            new Subject { SubjectCode = "SWE201", SubjectName = "Introduction to Software Engineering", Credits = 3 },
            new Subject { SubjectCode = "DBI202", SubjectName = "Database Systems", Credits = 3 },
            new Subject { SubjectCode = "MAS291", SubjectName = "Mathematics for Artificial Intelligence", Credits = 3 },
            new Subject { SubjectCode = "SWT301", SubjectName = "Software Testing", Credits = 3 }
        };

        await _context.Subjects.AddRangeAsync(subjects);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} subjects", subjects.Count);
    }
}
