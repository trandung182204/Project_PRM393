using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class RoomSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<RoomSeeder> _logger;

    public int Order => 1;

    public RoomSeeder(
        ApplicationDbContext context,
        ILogger<RoomSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Rooms.AnyAsync())
        {
            _logger.LogInformation("Rooms already seeded, skipping...");
            return;
        }

        var rooms = new List<Room>
        {
            new Room { RoomName = "BE-333", Capacity = 40 },
            new Room { RoomName = "BE-405", Capacity = 60 },
            new Room { RoomName = "AL-201", Capacity = 30 },
            new Room { RoomName = "BE-222", Capacity = 40 }
        };

        await _context.Rooms.AddRangeAsync(rooms);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} rooms", rooms.Count);
    }
}
