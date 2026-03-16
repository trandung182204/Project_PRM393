// BÍ KÍP: Dùng namespace này ð? Program.cs nh?n di?n t? ð?ng mà không c?n using
using Application.Interfaces.Services;
using Application.Services;

namespace Microsoft.Extensions.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddAutoMapper(Assembly.GetExecutingAssembly());

        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

      
        services.AddScoped<IAuthService, AuthService>();

        return services;
    }
}
