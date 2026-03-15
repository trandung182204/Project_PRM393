using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class SchoolClassSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<SchoolClassSeeder> _logger;

    public int Order => 1;

    public SchoolClassSeeder(
        ApplicationDbContext context,
        ILogger<SchoolClassSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Classes.AnyAsync())
        {
            _logger.LogInformation("SchoolClasses already seeded, skipping...");
            return;
        }

        var classes = new List<SchoolClass>
        {
            new SchoolClass { ClassName = "SE1701", AcademicYear = "2024-2027" },
            new SchoolClass { ClassName = "SE1702", AcademicYear = "2024-2027" },
            new SchoolClass { ClassName = "IA1701", AcademicYear = "2023-2026" },
            new SchoolClass { ClassName = "SS1701", AcademicYear = "2023-2026" }
        };

        await _context.Classes.AddRangeAsync(classes);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} school classes", classes.Count);
    }
}
