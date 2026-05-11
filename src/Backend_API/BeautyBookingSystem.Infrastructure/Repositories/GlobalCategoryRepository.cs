
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class GlobalCategoryRepository : GenericRepository<GlobalCategory>, IGlobalCategoryRepository
{
    public GlobalCategoryRepository(AppDbContext context) : base(context)
    {
    }

    public async Task<List<GlobalCategory>> GetActiveAsync()
    {
        return await _context.Set<GlobalCategory>()
            .Where(gc => gc.IsActive)
            .OrderBy(gc => gc.SortOrder)
            .ToListAsync();
    }

}