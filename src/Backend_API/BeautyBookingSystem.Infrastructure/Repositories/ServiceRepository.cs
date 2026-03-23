using BeautyBookingSystem.Application.DTOs.Service;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;

public class ServiceRepository : GenericRepository<Service>, IServiceRepository
{
    private readonly AppDbContext _context;

    public ServiceRepository(AppDbContext context) : base(context)
    {
        _context = context;
    }

    public async Task<List<Service>> GetByStoreAsync(int storeId)
    {
        return await _context.Services
            .Where(x => x.StoreId == storeId && x.IsActive)
            .OrderBy(x => x.SortOrder)
            .ToListAsync();
    }

    public async Task<List<Service>> GetByCategoryAsync(int categoryId)
    {
        return await _context.Services
            .Where(x => x.CategoryId == categoryId && x.IsActive)
            .OrderBy(x => x.SortOrder)
            .ToListAsync();
    }

    public async Task<List<Service>> GetByGroupAsync(int groupId)
    {
        return await _context.Services
            .Where(x => x.GroupId == groupId && x.IsActive)
            .OrderBy(x => x.SortOrder)
            .ToListAsync();
    }

    public async Task<List<Service>> GetFeaturedAsync()
    {
        return await _context.Services
            .Where(x => x.IsFeatured && x.IsActive)
            .OrderBy(x => x.SortOrder)
            .ToListAsync();
    }

    public async Task<List<Service>> GetAllActiveAsync()
    {
        return await _context.Services
            .Where(x => x.IsActive)
            .OrderBy(x => x.SortOrder)
            .ToListAsync();
    }
    public async Task<Service?> GetByIdAsync(int id)
    {
        return await _context.Services
            .Include(x => x.Store)
            .Include(x => x.Category)
            .Include(x => x.Group)
            .FirstOrDefaultAsync(x => x.Id == id && x.IsActive);
    }
  
}