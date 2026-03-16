using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class AbsenceRequestSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AbsenceRequestSeeder> _logger;

    public int Order => 4; // Depends on Student and Slot

    public AbsenceRequestSeeder(
        ApplicationDbContext context,
        ILogger<AbsenceRequestSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.AbsenceRequests.AnyAsync())
        {
            _logger.LogInformation("AbsenceRequests already seeded, skipping...");
            return;
        }

        var student = await _context.Students.FirstOrDefaultAsync();
        var slot = await _context.Slots.FirstOrDefaultAsync();

        if (student == null || slot == null)
        {
            _logger.LogWarning("Missing dependencies for AbsenceRequest seeding. Skipping...");
            return;
        }

        var requests = new List<AbsenceRequest>
        {
            new AbsenceRequest
            {
                Date = DateTime.Now.Date,
                Reason = "Sick leave",
                Status = "Pending",
                StudentId = student.Id,
                Slots = new List<Slot> { slot }
            }
        };

        await _context.AbsenceRequests.AddRangeAsync(requests);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} absence requests", requests.Count);
    }
}
