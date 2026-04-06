namespace BeautyBookingSystem.Application.DTOs.AdminStore
{
public class StoreDropdownDto
{
    public int Id { get; set; } // Nếu DB của bạn dùng Guid thì đổi thành Guid
    public string? Name { get; set; }
}
}