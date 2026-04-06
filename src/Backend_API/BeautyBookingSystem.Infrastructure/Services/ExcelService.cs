using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.DTOs.StoreStatistics;
using ClosedXML.Excel;
using System.IO;
using System.Collections.Generic;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class ExcelService : IExcelService
    {
       public byte[] GenerateStoreRevenueExcel(List<StoreRevenueExcelDto> data)

{
    using var workbook = new XLWorkbook();
    var worksheet = workbook.Worksheets.Add("Bao_Cao_Doanh_Thu");
    worksheet.Cell(1, 1).Value = "Mã Đơn";
    worksheet.Cell(1, 2).Value = "Ngày Phục Vụ";
    worksheet.Cell(1, 3).Value = "Tên Khách";
    worksheet.Cell(1, 4).Value = "SĐT";             
    worksheet.Cell(1, 5).Value = "Dịch Vụ";
    worksheet.Cell(1, 6).Value = "Giá Gốc (VNĐ)";
    worksheet.Cell(1, 7).Value = "Giảm Giá (VNĐ)";   
    worksheet.Cell(1, 8).Value = "Tổng Hóa Đơn (VNĐ)";
    worksheet.Cell(1, 9).Value = "Đã Đặt Cọc (VNĐ)";   
    worksheet.Cell(1, 10).Value = "Phí Nền Tảng (VNĐ)";
    worksheet.Cell(1, 11).Value = "Thực Nhận (VNĐ)";
    worksheet.Cell(1, 12).Value = "Thanh Toán";
    worksheet.Cell(1, 13).Value = "Trạng Thái";     
    var headerRow = worksheet.Range("A1:M1");
    headerRow.Style.Font.Bold = true;
    headerRow.Style.Fill.BackgroundColor = XLColor.LightGray;
    int row = 2;
    foreach (var item in data)
    {
        worksheet.Cell(row, 1).Value = item.BookingId;
        worksheet.Cell(row, 2).Value = item.AppointmentDate;
        worksheet.Cell(row, 3).Value = item.CustomerName;
        worksheet.Cell(row, 4).Value = item.CustomerPhone; 
        worksheet.Cell(row, 5).Value = item.UsedServices;
        worksheet.Cell(row, 6).Value = item.TotalPrice;    
        worksheet.Cell(row, 7).Value = item.DiscountAmount;
        worksheet.Cell(row, 8).Value = item.FinalPrice;
        worksheet.Cell(row, 9).Value = item.DepositAmount; 
        worksheet.Cell(row, 10).Value = item.SystemFee;
        worksheet.Cell(row, 11).Value = item.NetIncome;
        worksheet.Cell(row, 12).Value = item.PaymentMethod;
        worksheet.Cell(row, 13).Value = item.BookingStatus;
        worksheet.Cell(row, 6).Style.NumberFormat.Format = "#,##0";
        worksheet.Cell(row, 7).Style.NumberFormat.Format = "#,##0";
        worksheet.Cell(row, 8).Style.NumberFormat.Format = "#,##0";
        worksheet.Cell(row, 9).Style.NumberFormat.Format = "#,##0";
        worksheet.Cell(row, 10).Style.NumberFormat.Format = "#,##0";
        worksheet.Cell(row, 11).Style.NumberFormat.Format = "#,##0";
        row++;
    }
    worksheet.Columns().AdjustToContents();
    worksheet.SheetView.FreezeRows(1);
    worksheet.SheetView.FreezeColumns(1); 
    var dataRange = worksheet.Range(1, 1, row - 1, 13); 
    dataRange.SetAutoFilter();
    using var stream = new MemoryStream();
    workbook.SaveAs(stream);
    return stream.ToArray();
}
    }
}