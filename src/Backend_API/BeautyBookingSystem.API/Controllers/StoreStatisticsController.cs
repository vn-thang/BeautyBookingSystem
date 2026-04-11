using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace BeautyBookingSystem.API.Controllers 
{
    [Route("api/store-statistics")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")]
    public class StoreStatisticsController : ControllerBase
    {
        private readonly IStoreStatisticsService _storeStatisticsService;
        private readonly IExcelService _excelService;

        public StoreStatisticsController(IStoreStatisticsService storeStatisticsService, IExcelService excelService)
        {
            _storeStatisticsService = storeStatisticsService;
            _excelService = excelService;
        }
        [HttpGet("revenue-chart")]
        public async Task<IActionResult> GetRevenueChart([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var result = await _storeStatisticsService.GetRevenueChartAsync(startDate, endDate);
            return Ok(result);
        }

        [HttpGet("top-services")]
        public async Task<IActionResult> GetTopServices([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate, [FromQuery] int top = 5)
        {
            var result = await _storeStatisticsService.GetTopServicesAsync(startDate, endDate, top);
            return Ok(result);
        }

        [HttpGet("top-staffs")]
        public async Task<IActionResult> GetTopStaffs([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate, [FromQuery] int top = 5)
        {
            var result = await _storeStatisticsService.GetTopStaffsAsync(startDate, endDate, top);
            return Ok(result);
        }

        [HttpGet("reviews")]
        public async Task<IActionResult> GetReviewStatistics([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            var result = await _storeStatisticsService.GetReviewStatisticsAsync(startDate, endDate);
            return Ok(result);
        }
        [HttpGet("top-customers")]
        public async Task<IActionResult> GetTopCustomers([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate, [FromQuery] int top = 5)
        {
            var result = await _storeStatisticsService.GetTopCustomersAsync(startDate, endDate, top);
            return Ok(result);
        }
        [HttpGet("export-revenue")]
        public async Task<IActionResult> ExportRevenue(
            [FromQuery] DateTime? startDate, 
            [FromQuery] DateTime? endDate)
        {
            var data = await _storeStatisticsService.GetRevenueDataForExportAsync(startDate, endDate);

            if (data == null || data.Count == 0)
            {
                return BadRequest("Không có dữ liệu trong khoảng thời gian này.");
            }

            var fileBytes = _excelService.GenerateStoreRevenueExcel(data);

            string fileName = $"DoanhThu_{DateTime.Now:dd_MM_yyyy}.xlsx";
            string contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

            return File(fileBytes, contentType, fileName);
        }
    }
}