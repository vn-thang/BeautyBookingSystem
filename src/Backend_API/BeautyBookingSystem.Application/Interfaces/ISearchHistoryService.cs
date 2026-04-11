using BeautyBookingSystem.Application.DTOs.SearchHistories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ISearchHistoryService
    {
        Task<List<SearchHistoryDto>> GetRecentAsync(int customerId);
        Task<List<SearchHistoryDto>> RecordAsync(int customerId, string keyword);
        Task<List<SearchHistoryDto>> DeleteAsync(int customerId, int id);
    }
}
