namespace BeautyBookingSystem.Application.DTOs.StoreStatistics
{
public class StoreRevenueExcelDto
{
    public int BookingId { get; set; }          
    public string? AppointmentDate { get; set; } 
    public string? CustomerName { get; set; }     
    public string? CustomerPhone { get; set; }    
    public string? UsedServices { get; set; }    
    
    public decimal TotalPrice { get; set; }    
    public decimal DiscountAmount { get; set; } 
    public decimal FinalPrice { get; set; }      
    public decimal SystemFee { get; set; }      
    public decimal NetIncome { get; set; }     
    public decimal DepositAmount { get; set; }   
    public string? PaymentMethod { get; set; }   
    public string? BookingStatus { get; set; }  
}
}