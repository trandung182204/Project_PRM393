using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class SlotSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<SlotSeeder> _logger;

    public int Order => 2; // Depends on Shift

    public SlotSeeder(
        ApplicationDbContext context,
        ILogger<SlotSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Slots.AnyAsync())
        {
            _logger.LogInformation("Slots already seeded, skipping...");
            return;
        }

        var shiftSang = await _context.Shifts.FirstOrDefaultAsync(s => s.ShiftName == "Sáng");
        var shiftChieu = await _context.Shifts.FirstOrDefaultAsync(s => s.ShiftName == "Chiều");

        if (shiftSang == null || shiftChieu == null)
        {
            _logger.LogWarning("Required Shifts not found. Skipping Slot seeded...");
            return;
        }

        var slots = new List<Slot>
        {
            // Morning Shift
            new Slot { SlotName = "Slot 1", StartTime = new TimeSpan(7, 30, 0), EndTime = new TimeSpan(9, 50, 0), ShiftId = shiftSang.Id },
            new Slot { SlotName = "Slot 2", StartTime = new TimeSpan(10, 0, 0), EndTime = new TimeSpan(12, 20, 0), ShiftId = shiftSang.Id },
            // Afternoon Shift
            new Slot { SlotName = "Slot 3", StartTime = new TimeSpan(12, 50, 0), EndTime = new TimeSpan(15, 10, 0), ShiftId = shiftChieu.Id },
            new Slot { SlotName = "Slot 4", StartTime = new TimeSpan(15, 20, 0), EndTime = new TimeSpan(17, 40, 0), ShiftId = shiftChieu.Id }
        };

        await _context.Slots.AddRangeAsync(slots);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} slots", slots.Count);
    }
}
