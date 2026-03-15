// BÍ KÍP: Dùng namespace này để Program.cs nhận diện tự động mà không cần using
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