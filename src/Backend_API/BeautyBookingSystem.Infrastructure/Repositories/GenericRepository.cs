using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Org.BouncyCastle.Asn1;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class GenericRepository<T> : IGenericRepository<T> where T : class
    {
        protected readonly AppDbContext _context;
        internal DbSet<T> dbSet;

        public GenericRepository(AppDbContext context)
        {
            _context = context;
            this.dbSet = context.Set<T>(); 
        }
        public IQueryable<T> GetQueryable() => dbSet;

        public async Task<IEnumerable<T>> GetAllAsync() => await dbSet.ToListAsync();

        public async Task<T?> GetByIdAsync(int id) => await dbSet.FindAsync(id);

        public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> expression)
            => await dbSet.Where(expression).ToListAsync();
        public async Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> expression)
        {
            return await dbSet.FirstOrDefaultAsync(expression);
        }

        public async Task AddAsync(T entity) => await dbSet.AddAsync(entity);

        public void Update(T entity) => dbSet.Update(entity);

        public void Delete(T entity) => dbSet.Remove(entity);
    }
}
