using BeautyBookingSystem.Application.DTOs.StoreStatistics;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IExcelService
    {
        byte[] GenerateStoreRevenueExcel(List<StoreRevenueExcelDto> data);
    }
}