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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Xử lý lỗi Cascade Delete của SQL Server (Khi xóa User/Store không bị lỗi vòng lặp)
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
        }
    }
}
