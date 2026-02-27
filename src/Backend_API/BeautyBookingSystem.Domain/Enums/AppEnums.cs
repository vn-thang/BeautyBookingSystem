using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Enums
{
        public enum Role { Customer, StoreOwner, Admin }
        public enum UserStatus { Active, Locked }
        public enum ApprovalStatus { Pending, Approved, Locked }
        public enum DiscountType { Percent, Amount }
        public enum BookingStatus { Pending, Confirmed, Completed, Cancelled }
        public enum BookingDetailStatus { Pending, InProgress, Done, Cancelled }
        public enum PaymentMethod { MoMo, VNPAY, COD }
        public enum PaymentType { Deposit, Full }
        public enum PaymentStatus { Pending, Success, Failed, Refunded }
        public enum NotificationType { BookingUpdate, SystemAlert, Promotion }
        public enum SystemContentType { Banner, Policy, News }
    public enum CancelledByType{ None = 0, Customer = 1,Store = 2, Admin = 3}
}
