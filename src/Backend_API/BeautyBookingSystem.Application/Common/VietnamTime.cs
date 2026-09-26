namespace BeautyBookingSystem.Application.Common
{
    public static class VietnamTime
    {
        private static readonly TimeZoneInfo Zone =
            TimeZoneInfo.FindSystemTimeZoneById(
                OperatingSystem.IsWindows()
                    ? "SE Asia Standard Time"
                    : "Asia/Ho_Chi_Minh");

        public static DateTime Now =>
            TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, Zone);

        public static DateTime FromUtc(DateTime utcTime)
        {
            return TimeZoneInfo.ConvertTimeFromUtc(
                DateTime.SpecifyKind(utcTime, DateTimeKind.Utc),
                Zone);
        }

        public static DateTime TodayStartUtc =>
            ToUtc(Now.Date);

        public static DateTime ToUtc(DateTime vietnamTime)
        {
            if (vietnamTime.Kind == DateTimeKind.Utc)
                return vietnamTime;

            return TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(vietnamTime, DateTimeKind.Unspecified),
                Zone);
        }
    }
}