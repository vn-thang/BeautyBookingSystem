using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Enums
{
    public enum Role { Customer, StoreOwner, Admin }
    public enum UserStatus { Active, Locked }
    
    public enum ApprovalStatus { Incomplete = -1, Pending, Approved, Locked }
    
    public enum DiscountType { Percent, Amount }
    
    public enum BookingStatus { Pending, DepositPaid, Confirmed, Completed, Cancelled }
    public enum BookingDetailStatus { Pending, InProgress, Done, Cancelled }
    public enum PaymentMethod { MoMo, VNPAY, COD }
    public enum PaymentType { Deposit, Full, Remaining }
    public enum PaymentStatus { Pending, Success, Failed, Refunded }
    public enum NotificationType { BookingUpdate, SystemAlert, Promotion }
    public enum SystemContentType { TermsOfUse = 1, PrivacyPolicy = 2, AboutUs = 3, Instruction = 4, Banner = 5, Policy = 6, News = 7 }
    public enum CancelledByType { None = 0, Customer = 1, Store = 2, Admin = 3 }
    public enum TransactionType { TopUp = 1, Commission = 2, MonthlyFee = 3, Refund = 4, Withdrawal = 5, WithdrawalRefund = 6, ReceiveDeposit = 7, ClawbackDeposit = 8 }
    public enum WithdrawalStatus { Pending = 1, Approved = 2, Rejected = 3 }
    public enum TransactionStatus { Pending = 0, Completed = 1, Failed = 2, Cancelled = 3 }
    public enum BookingSource { CustomerApp = 1, StoreAdmin = 2 }
    public enum AuthProvider { Local, Google, Facebook}
}