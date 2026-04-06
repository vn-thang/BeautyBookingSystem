using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Mappers;
using BeautyBookingSystem.Application.Services;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using BeautyBookingSystem.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using System.IO;
using Hangfire;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<AppDbContext>(options =>
{
    
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.ConfigureWarnings(warnings => 
        warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
        });
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IStoreUserService, StoreUserService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IMyStoreService, MyStoreService>();
builder.Services.AddScoped<IAdminCategoryService, AdminCategoryService>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IStoreStaffService, StoreStaffService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IStoreServiceGroupService, StoreServiceGroupService>();
builder.Services.AddScoped<IStoreServiceService, StoreServiceService>();
builder.Services.AddScoped<IStoreBookingService, StoreBookingService>();
builder.Services.AddScoped<IStorePaymentService, StorePaymentService>();
builder.Services.AddScoped<IStoreReviewService, StoreReviewService>();
builder.Services.AddScoped<IStoreVoucherService, StoreVoucherService>();
builder.Services.AddScoped<IFirebasePushNotificationService, FirebasePushNotificationService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IStoreDashboardService, StoreDashboardService>();
builder.Services.AddScoped<IAdminUserService, AdminUserService>();
builder.Services.AddScoped<IAdminStoreService, AdminStoreService>();
builder.Services.AddScoped<IAdminReviewService, AdminReviewService>();
builder.Services.AddScoped<IAdminDashboardService, AdminDashboardService>();
builder.Services.AddScoped<IStoreCustomerService, StoreCustomerService>();
builder.Services.AddScoped<IAdminBookingService, AdminBookingService>();
builder.Services.AddScoped<IStoreWalletService, StoreWalletService>();
builder.Services.AddScoped<IStoreVnPayService, StoreVnPayService>();
builder.Services.AddScoped<ISystemConfigService, SystemConfigService>();
builder.Services.AddScoped<IAdminWalletService, AdminWalletService>();
builder.Services.AddScoped<ISystemContentService, SystemContentService>();
builder.Services.AddScoped<IWithdrawalService, WithdrawalService>();
builder.Services.AddScoped<IStoreStatisticsService, StoreStatisticsService>();
builder.Services.AddScoped<IExcelService, ExcelService>();
builder.Services.AddScoped<IStoreBillingService, StoreBillingService>();
builder.Services.AddHttpClient();


var jwtKey = builder.Configuration["Jwt:Key"];
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey!)),
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});
builder.Services.AddAutoMapper(typeof(MappingProfile).Assembly);

var connectionStrings = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddHangfire(configuration => configuration
.SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
.UseSimpleAssemblyNameTypeSerializer()
.UseRecommendedSerializerSettings()
.UseSqlServerStorage(connectionStrings));
builder.Services.AddHangfireServer();

var firebaseKeyPath = Path.Combine(Directory.GetCurrentDirectory(), "firebase-key.json"); 
if (File.Exists(firebaseKeyPath))
{
    FirebaseApp.Create(new AppOptions()
    {
        Credential = GoogleCredential.FromFile(firebaseKeyPath)
    });
    Console.WriteLine("Firebase Admin SDK initialized successfully.");
}
else
{
    Console.WriteLine("CẢNH BÁO: Không tìm thấy file firebase-key.json");
}
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp", policy =>
    {
        policy.WithOrigins("http://localhost:5173") 
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials(); 
    });
});

var app = builder.Build();
app.UseMiddleware<BeautyBookingSystem.API.Middleware.ExceptionMiddleware>();
app.UseHangfireDashboard("/hangfire");
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseCors("AllowReactApp");
app.UseAuthentication(); 
app.UseAuthorization();
app.MapControllers();

RecurringJob.AddOrUpdate<IStoreWalletService>(
    "auto-monthly-fee-deduction", 
    walletService => walletService.ProcessMonthlyAppFeeAsync(), 
    "5 0 * * *", // Mã Cron: Chạy vào đúng 00:05 mỗi ngày
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Local } 
);

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
