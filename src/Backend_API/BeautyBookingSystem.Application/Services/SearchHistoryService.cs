using BeautyBookingSystem.Application.DTOs.SearchHistories;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class SearchHistoryService : ISearchHistoryService
    {
        private readonly IUnitOfWork _unitOfWork;

        public SearchHistoryService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<List<SearchHistoryDto>> GetRecentAsync(int customerId)
        {
            var histories = await _unitOfWork.SearchHistories.GetByCustomerIdAsync(customerId);

            return histories
                .OrderByDescending(x => x.Id)
                .Take(5)
                .Select(x => new SearchHistoryDto
                {
                    Id = x.Id,
                    Keyword = x.Keyword
                })
                .ToList();
        }

        public async Task<List<SearchHistoryDto>> RecordAsync(int customerId, string keyword)
        {
            var normalized = keyword?.Trim();

            if (string.IsNullOrWhiteSpace(normalized))
                throw new ArgumentException("Keyword is required.");

            var histories = await _unitOfWork.SearchHistories.GetByCustomerIdAsync(customerId);

            // Xóa keyword cũ nếu đã tồn tại để nó lên đầu
            var duplicate = histories.FirstOrDefault(x => x.Keyword == normalized);
            if (duplicate != null)
            {
                _unitOfWork.SearchHistories.Remove(duplicate);
                histories.Remove(duplicate);
            }

            // Thêm mới
            var newEntity = new SearchHistory
            {
                CustomerId = customerId,
                Keyword = normalized
            };

            await _unitOfWork.SearchHistories.AddAsync(newEntity);
            histories.Insert(0, newEntity);

            // Chỉ giữ lại 5 lịch sử gần nhất
            var excess = histories.Skip(5).ToList();
            if (excess.Count > 0)
            {
                _unitOfWork.SearchHistories.RemoveRange(excess);
            }

            await _unitOfWork.SaveChangesAsync();

            return histories
                .Take(5)
                .Select(x => new SearchHistoryDto
                {
                    Id = x.Id,
                    Keyword = x.Keyword
                })
                .ToList();
        }

        public async Task<List<SearchHistoryDto>> DeleteAsync(int customerId, int id)
        {
            var histories = await _unitOfWork.SearchHistories.GetByCustomerIdAsync(customerId);

            var entity = histories.FirstOrDefault(x => x.Id == id);
            if (entity != null)
            {
                _unitOfWork.SearchHistories.Remove(entity);
                await _unitOfWork.SaveChangesAsync();
            }

            return histories
                .Where(x => x.Id != id)
                .OrderByDescending(x => x.Id)
                .Take(5)
                .Select(x => new SearchHistoryDto
                {
                    Id = x.Id,
                    Keyword = x.Keyword
                })
                .ToList();
        }
    }
}