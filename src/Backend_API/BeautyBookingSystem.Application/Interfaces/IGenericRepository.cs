using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IGenericRepository<T> where T : class
    {
        Task<IEnumerable<T>> GetAllAsync();
        Task<T?> GetByIdAsync(int id);
        Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> expression);
        Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> expression);
        Task AddAsync(T entity);
        void Update(T entity);
        void Delete(T entity);
    }
}
