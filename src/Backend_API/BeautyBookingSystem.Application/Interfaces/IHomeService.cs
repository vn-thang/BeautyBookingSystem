using BeautyBookingSystem.Application.DTOs.Home;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IHomeService
    {
        Task<HomeResponseDto> GetHomeDataAsync(
            Guid? userId,
            double? lat,
            double? lon
        );
    }
}
