using Infrastructure.Data.Seeders;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data;

public class DatabaseInitializerHostedService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<DatabaseInitializerHostedService> _logger;

    public DatabaseInitializerHostedService(
        IServiceProvider serviceProvider,
        ILogger<DatabaseInitializerHostedService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var scope = _serviceProvider.CreateScope();

        var context = scope.ServiceProvider
            .GetRequiredService<ApplicationDbContext>();

        var seeders = scope.ServiceProvider
            .GetServices<ISeeder>()
            .OrderBy(s => s.Order);

        try
        {
            _logger.LogInformation("Migrating database...");
            await context.Database.MigrateAsync(stoppingToken);

            _logger.LogInformation("Running seeders...");
            foreach (var seeder in seeders)
            {
                await seeder.SeedAsync();
            }

            _logger.LogInformation("Database initialisation completed.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Database initialisation failed.");
            throw;
        }
    }
}
