using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class ClubSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ClubSeeder> _logger;

    public int Order => 1;

    public ClubSeeder(
        ApplicationDbContext context,
        ILogger<ClubSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Clubs.AnyAsync())
        {
            _logger.LogInformation("Clubs already seeded, skipping...");
            return;
        }

        var clubs = new List<Club>
        {
            new Club 
            { 
                Name = "IT Club", 
                Category = "Academic",
                MembersCount = 120,
                Description = "A club for software engineering enthusiasts.",
                ImageUrl = ""
            },
            new Club 
            { 
                Name = "Music Club", 
                Category = "Arts",
                MembersCount = 50,
                Description = "A club for music lovers and performers.",
                ImageUrl = ""
            },
            new Club 
            { 
                Name = "Basketball Club", 
                Category = "Sports",
                MembersCount = 30,
                Description = "FPT University Basketball Team.",
                ImageUrl = ""
            }
        };

        await _context.Clubs.AddRangeAsync(clubs);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} clubs", clubs.Count);
    }
}
