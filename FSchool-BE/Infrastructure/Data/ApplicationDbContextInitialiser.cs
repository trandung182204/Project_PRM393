using Infrastructure.Data.Seeders;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data;
public class ApplicationDbContextInitialiser
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ApplicationDbContextInitialiser> _logger;
    private readonly IEnumerable<ISeeder> _seeders;

    public ApplicationDbContextInitialiser(
        ApplicationDbContext context,
        ILogger<ApplicationDbContextInitialiser> logger,
        IEnumerable<ISeeder> seeders)
    {
        _context = context;
        _logger = logger;
        _seeders = seeders.OrderBy(s => s.Order);
    }

    public async Task InitialiseAsync()
    {
        try
        {
            await _context.Database.MigrateAsync();
            _logger.LogInformation("Database migrated successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Database migration failed");
            throw;
        }
    }

    public async Task SeedAsync()
    {
        foreach (var seeder in _seeders)
        {
            _logger.LogInformation("Running Seeder: {Seeder}", seeder.GetType().Name);
            await seeder.SeedAsync();
        }

        _logger.LogInformation("All seeders executed successfully");
    }
}
