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

      public async Task<List<StaffScheduleDto>> GetSchedulesAsync(int staffId)
        {
            await ValidateStaffBelongsToStoreAsync(staffId);

            var schedules = await _unitOfWork.StaffScheduleRepository.GetQueryable()
                .Where(s => s.StaffId == staffId)
                .OrderBy(s => s.DayOfWeek)
                .ToListAsync();

            return _mapper.Map<List<StaffScheduleDto>>(schedules);
        }

        public async Task<bool> UpdateSchedulesAsync(int staffId, List<UpdateStaffScheduleRequest> requests)
        {
            await ValidateStaffBelongsToStoreAsync(staffId);
            var existingSchedules = await _unitOfWork.StaffScheduleRepository.GetQueryable()
                .Where(s => s.StaffId == staffId)
                .ToListAsync();
            
            if (existingSchedules.Any())
            {
                foreach (var schedule in existingSchedules)
                {
                    _unitOfWork.StaffScheduleRepository.Delete(schedule);
                }
            }

            var newSchedules = requests.Select(req => new StaffSchedule
            {
                StaffId = staffId,
                DayOfWeek = req.DayOfWeek,
                StartTime = req.StartTime,
                EndTime = req.EndTime,
                IsWorking = req.IsWorking
            }).ToList();

            foreach (var newSchedule in newSchedules)
            {
                await _unitOfWork.StaffScheduleRepository.AddAsync(newSchedule);
            }
            
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        public async Task<List<StaffLeaveDto>> GetLeavesAsync(int staffId)
        {
            await ValidateStaffBelongsToStoreAsync(staffId);

            var leaves = await _unitOfWork.StaffLeaveRepository.GetQueryable()
                .Where(l => l.StaffId == staffId)
                .OrderByDescending(l => l.FromDate)
                .ToListAsync();

            return _mapper.Map<List<StaffLeaveDto>>(leaves);
        }

        public async Task<bool> CreateLeaveAsync(int staffId, CreateStaffLeaveRequest request)
        {
            if (request.FromDate >= request.ToDate)
                throw new BadRequestException("Thời gian kết thúc phải lớn hơn thời gian bắt đầu.");

            await ValidateStaffBelongsToStoreAsync(staffId);
            var activeBookings = await _unitOfWork.BookingDetailRepository.GetQueryable()
                .Where(b => b.StaffId == staffId && 
                            b.Status != Domain.Enums.BookingDetailStatus.Cancelled)
                .ToListAsync();

            var overlappingBookings = activeBookings.Where(b => 
            {
                DateTime appointmentDate = DateTime.Today; 
                DateTime bookingStartDateTime = appointmentDate.Date.Add(b.StartTime);
                DateTime bookingEndDateTime = appointmentDate.Date.Add(b.EndTime);
                return bookingStartDateTime < request.ToDate && bookingEndDateTime > request.FromDate;
            }).ToList();

            if (overlappingBookings.Any())
            {
                var bookingIds = string.Join(", ", overlappingBookings.Select(b => $"#{b.Id}"));
                throw new BadRequestException(
                    $"Không thể duyệt nghỉ phép! Nhân viên đang có lịch hẹn với khách (Mã đơn: {bookingIds}) trong khung giờ này. " +
                    $"Vui lòng dời lịch hoặc chuyển nhân viên khác trước.");
            }

            var newLeave = new StaffLeave
            {
                StaffId = staffId,
                FromDate = request.FromDate,
                ToDate = request.ToDate,
                Reason = request.Reason
            };

            await _unitOfWork.StaffLeaveRepository.AddAsync(newLeave);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        public async Task<bool> DeleteLeaveAsync(int staffId, int leaveId)
        {
            await ValidateStaffBelongsToStoreAsync(staffId);

            var leave = await _unitOfWork.StaffLeaveRepository.GetByIdAsync(leaveId);
            if (leave == null || leave.StaffId != staffId)
                throw new NotFoundException("Không tìm thấy đơn xin nghỉ này.");
            _unitOfWork.StaffLeaveRepository.Delete(leave);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        private async Task ValidateStaffBelongsToStoreAsync(int staffId)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var staff = await _unitOfWork.StaffRepository.GetByIdAsync(staffId);

            if (staff == null || staff.StoreId != storeId)
                throw new NotFoundException("Không tìm thấy nhân viên hoặc nhân viên không thuộc cửa hàng này!");
        }
    }
}