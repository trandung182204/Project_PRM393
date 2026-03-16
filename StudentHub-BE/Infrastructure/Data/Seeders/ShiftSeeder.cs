using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class ShiftSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ShiftSeeder> _logger;

    public int Order => 1;

    public ShiftSeeder(
        ApplicationDbContext context,
        ILogger<ShiftSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Shifts.AnyAsync())
        {
            _logger.LogInformation("Shifts already seeded, skipping...");
            return;
        }

        var shifts = new List<Shift>
        {
            new Shift { ShiftName = "Sáng" },
            new Shift { ShiftName = "Chiều" },
            new Shift { ShiftName = "Tối" }
        };

        await _context.Shifts.AddRangeAsync(shifts);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} shifts", shifts.Count);
    }
}
