// using FSchool.Application.Interfaces;
// using FSchool.Infrastructure.Repositories;

using Application.Interfaces.ExternalServices;
using Application.Interfaces.Repositories;
using Application.Interfaces.Services;
using Infrastructure.Data.Seeders;
using Infrastructure.ExternalServices;
using Infrastructure.Repositories;

namespace Microsoft.Extensions.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("MyCnn")));

        services.AddScoped<IAccountRepository, AccountRepository>();
        services.AddScoped<ITokenService, TokenService>();
        services.AddScoped<IEmailService, EmailService>();


        services.AddScoped<ISeeder, AccountsSeeder>();
        services.AddScoped<ISeeder, StudentsSeeder>();
        services.AddScoped<ISeeder, StaffsSeeder>();

        // Level 1 Seeders
        services.AddScoped<ISeeder, SemesterSeeder>();
        services.AddScoped<ISeeder, SubjectSeeder>();
        services.AddScoped<ISeeder, RoomSeeder>();
        services.AddScoped<ISeeder, SchoolClassSeeder>();
        services.AddScoped<ISeeder, ShiftSeeder>();
        services.AddScoped<ISeeder, ClubSeeder>();
        
        // Level 2 Seeders
        services.AddScoped<ISeeder, SlotSeeder>();
        services.AddScoped<ISeeder, EventSeeder>();
        
        // Level 3 Seeders
        services.AddScoped<ISeeder, ScheduleSeeder>();
        
        // Level 4 Seeders
        services.AddScoped<ISeeder, AttendanceSeeder>();
        services.AddScoped<ISeeder, GradeSeeder>();
        services.AddScoped<ISeeder, AbsenceRequestSeeder>();

        services.AddScoped<ApplicationDbContextInitialiser>();
        services.AddHostedService<DatabaseInitializerHostedService>();

        return services;
    }
}