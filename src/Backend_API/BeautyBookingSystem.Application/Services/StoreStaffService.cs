using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.StoreStaff;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreStaffService : IStoreStaffService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;

        public StoreStaffService(IUnitOfWork unitOfWork, IMapper mapper, ICurrentUserService currentUserService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _currentUserService = currentUserService;
        }

        public async Task<List<StaffDtos>> GetAllByCurrentStoreAsync(bool onlyActive = true)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.StaffRepository.GetQueryable()
                                   .Where(s => s.StoreId == storeId);

            if (onlyActive) query = query.Where(s => s.IsActive);

            var staffs = await query.ToListAsync();
            return _mapper.Map<List<StaffDtos>>(staffs);
        }

        public async Task<StaffDtos> GetByIdAsync(int id)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var staff = await _unitOfWork.StaffRepository.GetByIdAsync(id);

            if (staff == null || staff.StoreId != storeId)
                throw new NotFoundException("Không tìm thấy nhân viên!");

            return _mapper.Map<StaffDtos>(staff);
        }

        public async Task<StaffDtos> CreateAsync(CreateStaffRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var newStaff = _mapper.Map<Staff>(request);
            newStaff.StoreId = storeId;
            newStaff.IsActive = true;

            await _unitOfWork.StaffRepository.AddAsync(newStaff);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<StaffDtos>(newStaff);
        }

        public async Task<bool> UpdateAsync(int id, UpdateStaffRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var staff = await _unitOfWork.StaffRepository.GetByIdAsync(id);

            if (staff == null || staff.StoreId != storeId)
                throw new NotFoundException("Nhân viên không tồn tại!");

            _mapper.Map(request, staff);

            _unitOfWork.StaffRepository.Update(staff);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var staff = await _unitOfWork.StaffRepository.GetByIdAsync(id);

            if (staff == null || staff.StoreId != storeId)
                throw new NotFoundException("Nhân viên không tồn tại!");

            staff.IsActive = false;
            _unitOfWork.StaffRepository.Update(staff);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }
    }
}
