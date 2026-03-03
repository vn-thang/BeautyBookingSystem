using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IUnitOfWork _unitOfWork;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor, IUnitOfWork unitOfWork)
        {
            _httpContextAccessor = httpContextAccessor;
            _unitOfWork = unitOfWork;
        }
        public int GetUserId()
        {
            var userIdString = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(userIdString) || !int.TryParse(userIdString, out int userId))
                throw new UnauthorizedException("Phiên đăng nhập hết hạn hoặc không hợp lệ!");

            return userId;
        }
        public async Task<int> GetCurrentStoreIdAsync()
        {
            int userId = GetUserId();

            var store = await _unitOfWork.StoreRepository.GetQueryable()
                .FirstOrDefaultAsync(s => s.OwnerId == userId);

            if (store == null)
                throw new BadRequestException("Bạn chưa có cửa hàng!");

            return store.Id;
        }
    }
}
