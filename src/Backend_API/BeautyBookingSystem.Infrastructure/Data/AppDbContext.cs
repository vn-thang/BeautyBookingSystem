using BeautyBookingSystem.Domain.Common;
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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<Store>()
            .HasMany(s => s.OperatingHours)
            .WithOne(h => h.Store)
            .HasForeignKey(h => h.StoreId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Cascade);

            foreach (var relationship in modelBuilder.Model.GetEntityTypes().SelectMany(e => e.GetForeignKeys()))
            {
                relationship.DeleteBehavior = DeleteBehavior.Restrict;
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
