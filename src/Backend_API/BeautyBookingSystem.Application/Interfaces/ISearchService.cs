using BeautyBookingSystem.Application.DTOs.Search;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ISearchService
    {
        Task<List<SearchStoreResponse>> SearchAsync(SearchRequest request);
    }
}
