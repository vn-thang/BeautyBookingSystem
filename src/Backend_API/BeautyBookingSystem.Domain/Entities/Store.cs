using BeautyBookingSystem.Domain.Common;
using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class Store : BaseEntity
    {
        public int OwnerId { get; set; }
        public virtual User Owner { get; set; } = null!;

        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? LogoUrl { get; set; }
        public string? CoverImageUrl { get; set; }

        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public bool IsOpen { get; set; }
        public decimal AverageRating { get; set; } = 0; 
        public int TotalReviews { get; set; } = 0;
        public int DepositPercent { get; set; } = 0;
        [Column(TypeName = "decimal(18,2)")]
        public decimal DepositThreshold { get; set; } = 0m;
        public ApprovalStatus ApprovalStatus { get; set; }
        public decimal WalletBalance { get; set; } = 0; 
        public decimal MinimumBalance { get; set; } = 0; 
        public int? CommissionRate { get; set; } 
       [Column(TypeName = "decimal(18,2)")]
        public decimal MonthlyAppFee { get; set; } = 50000m; 
        public DateTime? NextBillingDate { get; set; }
        public string? BankName { get; set; } 
        public string? BankAccountNumber { get; set; }
        public string? BankAccountName { get; set; }
        public string? ZaloPhone { get; set; } 
        public string? FacebookUrl { get; set; }

        public virtual ICollection<WalletTransaction> WalletTransactions { get; set; } = new List<WalletTransaction>();

        public virtual ICollection<StoreOperatingHour> OperatingHours { get; set; } = new List<StoreOperatingHour>();
        public virtual ICollection<Staff> Staffs { get; set; } = new List<Staff>();
        public virtual ICollection<ServiceGroup> ServiceGroups { get; set; } = new List<ServiceGroup>();
        public virtual ICollection<Service> Services { get; set; } = new List<Service>();
        public virtual ICollection<Voucher> Vouchers { get; set; } = new List<Voucher>();
        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
        public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
        public ICollection<StoreBanner> Banners { get; set; } = new List<StoreBanner>();
    }
}
