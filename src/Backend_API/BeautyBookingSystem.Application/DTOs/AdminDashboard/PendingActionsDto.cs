using System;

namespace BeautyBookingSystem.Application.DTOs.AdminDashboard
{
    public class PendingActionsDto
    {
        public int PendingStores { get; set; }
        public int PendingPayouts { get; set; }
        public int ReportedReviews { get; set; }
    }
}