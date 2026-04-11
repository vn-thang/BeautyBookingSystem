using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Interfaces.Repositories;
using BeautyBookingSystem.Application.Mappers;
using BeautyBookingSystem.Application.Services;
using BeautyBookingSystem.Domain.Entities;
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
using System.Security.Claims;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.ConfigureWarnings(warnings => 
        warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
});

builder.Services.AddDirectoryBrowser();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpClient();
builder.Services.AddHttpContextAccessor();
builder.Services.AddAutoMapper(typeof(MappingProfile).Assembly);

builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IStoreRepository, StoreRepository>();
builder.Services.AddScoped<IServiceRepository, ServiceRepository>();
builder.Services.AddScoped<IVoucherRepository, VoucherRepository>();
builder.Services.AddScoped<IBookingRepository, BookingRepository>();
builder.Services.AddScoped<IBookingDetailRepository, BookingDetailRepository>();
builder.Services.AddScoped<IPaymentRepository, PaymentRepository>();
builder.Services.AddScoped<IChatSessionRepository, ChatSessionRepository>();
builder.Services.AddScoped<ICustomerFavoriteRepository, CustomerFavoriteRepository>();
builder.Services.AddScoped<IReviewRepository, ReviewRepository>();
builder.Services.AddScoped<ISearchHistoryRepository, SearchHistoryRepository>();
builder.Services.AddScoped<ICustomerVnPayService, CustomerVnPayService>();
builder.Services.AddScoped<ICustomerPaymentService, CustomerPaymentService>();

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IFirebasePushNotificationService, FirebasePushNotificationService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<ISystemConfigService, SystemConfigService>();
builder.Services.AddScoped<ISystemContentService, SystemContentService>();
builder.Services.AddScoped<IExcelService, ExcelService>();
builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();

builder.Services.AddScoped<IHomeService, HomeService>();
builder.Services.AddScoped<IGlobalCategoryService, GlobalCategoryService>();
builder.Services.AddScoped<IServiceGroupService, ServiceGroupService>();
builder.Services.AddScoped<IServiceService, ServiceService>();
builder.Services.AddScoped<IVoucherService, VoucherService>();
builder.Services.AddScoped<IBookingService, BookingService>();
builder.Services.AddScoped<ISearchService, SearchService>();
builder.Services.AddScoped<ICustomerFavoriteService, CustomerFavoriteService>();
builder.Services.AddScoped<ISearchHistoryService, SearchHistoryService>();
builder.Services.AddScoped<IReviewService, ReviewService>(); 
builder.Services.AddScoped<ICustomerUserService, CustomerUserService>();
builder.Services.AddScoped<IPublicStoreService, PublicStoreService>();
builder.Services.AddScoped<IBookingCleanupService, BookingCleanupService>();

builder.Services.AddScoped<IChatKnowledgeProvider, ChatKnowledgeProvider>();
builder.Services.AddScoped<IChatAiClient, GeminiChatClient>();
builder.Services.AddScoped<IChatAssistantService, ChatAssistantService>();

builder.Services.AddScoped<IStoreUserService, StoreUserService>();
builder.Services.AddScoped<IMyStoreService, MyStoreService>();
builder.Services.AddScoped<IStoreStaffService, StoreStaffService>();
builder.Services.AddScoped<IStoreServiceGroupService, StoreServiceGroupService>();
builder.Services.AddScoped<IStoreServiceService, StoreServiceService>();
builder.Services.AddScoped<IStoreBookingService, StoreBookingService>();
builder.Services.AddScoped<IStorePaymentService, StorePaymentService>();
builder.Services.AddScoped<IStoreReviewService, StoreReviewService>();
builder.Services.AddScoped<IStoreVoucherService, StoreVoucherService>();
builder.Services.AddScoped<IStoreDashboardService, StoreDashboardService>();
builder.Services.AddScoped<IStoreCustomerService, StoreCustomerService>();
builder.Services.AddScoped<IStoreWalletService, StoreWalletService>();
builder.Services.AddScoped<IStoreVnPayService, StoreVnPayService>();
builder.Services.AddScoped<IWithdrawalService, WithdrawalService>();
builder.Services.AddScoped<IStoreStatisticsService, StoreStatisticsService>();
builder.Services.AddScoped<IStoreBillingService, StoreBillingService>();

builder.Services.AddScoped<IAdminCategoryService, AdminCategoryService>();
builder.Services.AddScoped<IAdminUserService, AdminUserService>();
builder.Services.AddScoped<IAdminStoreService, AdminStoreService>();
builder.Services.AddScoped<IAdminReviewService, AdminReviewService>();
builder.Services.AddScoped<IAdminDashboardService, AdminDashboardService>();
builder.Services.AddScoped<IAdminBookingService, AdminBookingService>();
builder.Services.AddScoped<IAdminWalletService, AdminWalletService>();

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
    if (FirebaseApp.DefaultInstance == null) 
    {
        FirebaseApp.Create(new AppOptions()
        {
            Credential = GoogleCredential.FromFile(firebaseKeyPath)
        });
        Console.WriteLine("Firebase Admin SDK initialized successfully.");
    }
}
else
{
    Console.WriteLine("CẢNH BÁO: Không tìm thấy file firebase-key.json");
}

builder.Services.AddCors(options =>
{
    options.AddPolicy("GlobalCorsPolicy", policy =>
    {
        policy.WithOrigins("http://localhost:5173")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials() 
              .SetIsOriginAllowed(origin => true); 
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

app.UseCors("GlobalCorsPolicy"); 

app.UseStaticFiles();

app.UseAuthentication(); 
app.UseAuthorization();
app.MapControllers();

RecurringJob.AddOrUpdate<IBookingCleanupService>(
    "auto-cancel-unpaid-bookings", 
    service => service.CancelExpiredPendingBookingsAsync(),
    "*/5 * * * *" // Biểu thức Cron: Mỗi 5 phút
);

RecurringJob.AddOrUpdate<IStoreWalletService>(
    "auto-monthly-fee-deduction", 
    walletService => walletService.ProcessMonthlyAppFeeAsync(), 
    "5 0 * * *", 
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Local } 
);

app.Run();