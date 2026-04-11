namespace BeautyBookingSystem.Domain.Constants
{
    public static class SystemConfigKeys
    {
        public const string DefaultCommissionRate = "DefaultCommissionRate";
        public const string DefaultMonthlyAppFee = "DefaultMonthlyAppFee";
        public const string FreeTrialDays = "FreeTrialDays";
        public const string PenaltyCommissionPercent = "PENALTY_COMMISSION_PERCENT";
        public const string MaintenanceMode = "MAINTENANCE_MODE";
        public const string Hotline = "HOTLINE";
        public const string SupportEmail = "SUPPORT_EMAIL";

        // Nhóm Booking (Vận hành & Đặt lịch)
        public const string BookingMinHours = "BOOKING_MIN_HOURS";
        public const string CancelBeforeHours = "CANCEL_BEFORE_HOURS";
        public const string GracePeriodMinutes = "GRACE_PERIOD_MINUTES";
        // Nhóm Behavior (Hành vi)
        public const string MaxCancelPerDay = "MAX_CANCEL_PER_DAY";
        public const string NoShowLimit = "NOSHOW_LIMIT";
        public const string BlockUserIfNoShow = "BLOCK_USER_IF_NOSHOW";
        public const string RescheduleBeforeHours = "RESCHEDULE_BEFORE_HOURS";
    }
}