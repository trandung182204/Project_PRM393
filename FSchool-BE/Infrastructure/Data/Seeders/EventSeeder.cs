using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class EventSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<EventSeeder> _logger;

    public int Order => 2; // Depends on Club

    public EventSeeder(
        ApplicationDbContext context,
        ILogger<EventSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Events.AnyAsync())
        {
            _logger.LogInformation("Events already seeded, skipping...");
            return;
        }

        var itClub = await _context.Clubs.FirstOrDefaultAsync(c => c.Name == "IT Club");
        var musicClub = await _context.Clubs.FirstOrDefaultAsync(c => c.Name == "Music Club");

        if (itClub == null || musicClub == null)
        {
            _logger.LogWarning("Required Clubs not found. Skipping Event seeded...");
            return;
        }

        var events = new List<Event>
        {
            new Event
            {
                Title = "Annual Hackathon 2026",
                EventDate = DateTime.Now.AddDays(15),
                Location = "Hall A",
                ImageUrl = "",
                Description = "24-hour coding challenge.",
                IsNews = true,
                Club = itClub
            },
            new Event
            {
                Title = "Spring Concert",
                EventDate = DateTime.Now.AddDays(20),
                Location = "Main Stage",
                ImageUrl = "",
                Description = "Live music performances by students.",
                IsNews = true,
                Club = musicClub
            }
        };

        await _context.Events.AddRangeAsync(events);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} events", events.Count);
    }
}
