namespace BeautyBookingSystem.Application.DTOs.StoreStaff
{
    public class StaffLeaveDto
    {
        public int Id { get; set; }
        public int StaffId { get; set; }
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }
        public string? Reason { get; set; }
    }
}