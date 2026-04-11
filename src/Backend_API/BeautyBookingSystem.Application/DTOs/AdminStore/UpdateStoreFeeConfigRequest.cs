using BeautyBookingSystem.Domain.Enums;
namespace BeautyBookingSystem.Application.DTOs.AdminStore
{
public class UpdateStoreFeeConfigRequest
{
    public int? CommissionRate { get; set; }
    public decimal MonthlyAppFee { get; set; } 
}
}