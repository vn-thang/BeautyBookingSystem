using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Services;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.API.Extensions;

public static class ServiceExtensions
{
    public static IServiceCollection AddApplicationServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<AppDbContext>(options =>
            options.UseSqlServer(
                configuration.GetConnectionString("DefaultConnection")));

        services.AddScoped<IUnitOfWork, UnitOfWork>();

        services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));

        services.AddScoped<IVoucherRepository, VoucherRepository>();
        services.AddScoped<VoucherService>();

        services.AddScoped<IGlobalCategoryRepository, GlobalCategoryRepository>();
        services.AddScoped<GlobalCategoryService>();

        services.AddScoped<IServiceGroupRepository, ServiceGroupRepository>();
        services.AddScoped<ServiceGroupService>();

        services.AddScoped<IStoreRepository, StoreRepository>();
        services.AddScoped<StoreService>();

        services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

        return services;
    }
}