using BeautyBookingSystem.Domain.Common;
using BeautyBookingSystem.Domain.Constants;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Infrastructure.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }

        public DbSet<Store> Stores { get; set; }
        public DbSet<StoreBanner> StoreBanners { get; set; }

        public DbSet<StoreOperatingHour> StoreOperatingHours { get; set; }
        public DbSet<Staff> Staffs { get; set; }

        public DbSet<GlobalCategory> GlobalCategories { get; set; }
        public DbSet<ServiceGroup> ServiceGroups { get; set; }
        public DbSet<Service> Services { get; set; }

        public DbSet<Voucher> Vouchers { get; set; }
        public DbSet<UserVoucher> UserVouchers { get; set; }

        public DbSet<Booking> Bookings { get; set; }
        public DbSet<BookingDetail> BookingDetails { get; set; }
        public DbSet<Payment> Payments { get; set; }

        public DbSet<CustomerFavorite> CustomerFavorites { get; set; }
        public DbSet<SearchHistory> SearchHistories { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Notification> Notifications { get; set; }
        public DbSet<SystemContent> SystemContents { get; set; }
        public DbSet<ChatSession> ChatSessions { get; set; }
        public DbSet<ChatMessage> ChatMessages { get; set; }
        public DbSet<WalletTransaction> WalletTransactions { get; set; }
        public DbSet<SystemConfig> SystemConfigs { get; set; }
        public DbSet<WithdrawalRequest> WithdrawalRequests { get; set; }
        public DbSet<StaffSchedule> StaffSchedules { get; set; }
        public DbSet<StaffLeave> StaffLeaves { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            foreach (var relationship in modelBuilder.Model.GetEntityTypes().SelectMany(e => e.GetForeignKeys()))
            {
                relationship.DeleteBehavior = DeleteBehavior.Restrict;
            }
            modelBuilder.Entity<ChatSession>(entity =>
            {
                entity.HasIndex(x => new { x.UserId, x.SessionKey }).IsUnique();

                entity.HasOne(x => x.User)
                    .WithMany(u => u.ChatSessions)
                    .HasForeignKey(x => x.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasMany(x => x.Messages)
                    .WithOne(x => x.ChatSession)
                    .HasForeignKey(x => x.ChatSessionId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<ChatMessage>(entity =>
            {
                entity.Property(x => x.Content).HasColumnType("nvarchar(max)");
                entity.Property(x => x.MetadataJson).HasColumnType("nvarchar(max)");
                entity.Property(x => x.ToolName).HasMaxLength(100);
            });
            modelBuilder.Entity<Store>()
                .HasMany(s => s.OperatingHours)
                .WithOne(h => h.Store)
                .HasForeignKey(h => h.StoreId)
                .IsRequired()
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<SystemConfig>(entity =>
            {
                entity.HasIndex(e => e.Key).IsUnique(); 
                entity.HasData(
                    new SystemConfig { Id = 1, Key = SystemConfigKeys.DefaultCommissionRate, Value = "10", Type = "number", Group = "Finance", Description = "Tỷ lệ hoa hồng mặc định (%)" },
                    new SystemConfig { Id = 2, Key = SystemConfigKeys.DefaultMonthlyAppFee, Value = "50000", Type = "number", Group = "Finance", Description = "Phí duy trì mặc định hàng tháng (VNĐ)" },
                    new SystemConfig { Id = 7, Key = SystemConfigKeys.PenaltyCommissionPercent, Value = "15", Type = "number", Group = "Finance", Description = "Tỷ lệ phí Admin thu trên tiền cọc khi khách bùng lịch (%)" },
                    new SystemConfig { Id = 3, Key = SystemConfigKeys.FreeTrialDays, Value = "30", Type = "number", Group = "General", Description = "Số ngày dùng thử miễn phí cho Cửa hàng mới duyệt" },
                    new SystemConfig { Id = 4, Key = SystemConfigKeys.MaintenanceMode, Value = "false", Type = "boolean", Group = "General", Description = "Bật/tắt chế độ bảo trì toàn hệ thống" },
                    new SystemConfig { Id = 5, Key = SystemConfigKeys.Hotline, Value = "1900 1234", Type = "string", Group = "General", Description = "Số điện thoại tổng đài hỗ trợ" },
                    new SystemConfig { Id = 6, Key = SystemConfigKeys.SupportEmail, Value = "support@beautybooking.com", Type = "string", Group = "General", Description = "Email hỗ trợ khách hàng" },
                    new SystemConfig { Id = 8, Key = SystemConfigKeys.BookingMinHours, Value = "1", Type = "number", Group = "Booking", Description = "Khách hàng phải đặt trước tối thiểu bao nhiêu giờ" },
                    new SystemConfig { Id = 9, Key = SystemConfigKeys.CancelBeforeHours, Value = "2", Type = "number", Group = "Booking", Description = "Số giờ tối thiểu để hủy lịch mà không bị phạt (mất cọc)" },
                    new SystemConfig { Id = 10, Key = SystemConfigKeys.GracePeriodMinutes, Value = "15", Type = "number", Group = "Booking", Description = "Thời gian giữ chỗ (phút) cho phép khách hàng đến trễ" },
                    new SystemConfig { Id = 11, Key = SystemConfigKeys.MaxCancelPerDay, Value = "5", Type = "number", Group = "Behavior", Description = "Số lần tối đa khách hàng được phép hủy lịch trong 1 ngày" },
                    new SystemConfig { Id = 12, Key = SystemConfigKeys.NoShowLimit, Value = "5", Type = "number", Group = "Behavior", Description = "Số lần 'Boom hàng' (No-show) tối đa trước khi bị khóa" },
                    new SystemConfig { Id = 13, Key = SystemConfigKeys.BlockUserIfNoShow, Value = "true", Type = "boolean", Group = "Behavior", Description = "Tự động khóa tài khoản khách hàng nếu vượt giới hạn Boom hàng" },
                    new SystemConfig { Id = 14, Key = SystemConfigKeys.RescheduleBeforeHours, Value = "2", Type = "number", Group = "Booking", Description = "Số giờ tối thiểu để khách hàng được phép dời lịch (Reschedule)" }
);
            });

            var decimalProperties = modelBuilder.Model.GetEntityTypes()
                .SelectMany(t => t.GetProperties())
                .Where(p => p.ClrType == typeof(decimal) || p.ClrType == typeof(decimal?));

            foreach (var property in decimalProperties)
            {
                property.SetColumnType("decimal(18,2)");
            }
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            var entries = ChangeTracker
                .Entries()
                .Where(e => e.Entity is BaseEntity && (
                        e.State == EntityState.Added ||
                        e.State == EntityState.Modified))
                .ToList();

            foreach (var entityEntry in entries)
            {
                if (entityEntry.Entity is BaseEntity entity)
                {
                    if (entityEntry.State == EntityState.Added)
                    {
                        entity.CreatedAt = DateTime.UtcNow;
                        entity.UpdatedAt = DateTime.UtcNow;
                    }
                    else if (entityEntry.State == EntityState.Modified)
                    {
                        entity.UpdatedAt = DateTime.UtcNow;
                        entityEntry.Property(nameof(BaseEntity.CreatedAt)).IsModified = false;
                    }
                }
            }

            return base.SaveChangesAsync(cancellationToken);
        }
    }
}