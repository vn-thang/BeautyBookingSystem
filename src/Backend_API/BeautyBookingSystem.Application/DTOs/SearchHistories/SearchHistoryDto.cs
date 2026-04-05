using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.SearchHistories
{
    public class SearchHistoryDto
    {
        public int Id { get; set; }
        public string Keyword { get; set; } = string.Empty;
    }
}
