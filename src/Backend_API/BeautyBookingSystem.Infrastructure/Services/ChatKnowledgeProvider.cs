
using BeautyBookingSystem.Application.DTOs.Chat;
using BeautyBookingSystem.Application.DTOs.Search;
using BeautyBookingSystem.Application.Interfaces;
using System.Globalization;
using System.Text;
using System.Text.Json;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class ChatKnowledgeProvider : IChatKnowledgeProvider
    {
        private readonly IHomeService _homeService;
        private readonly ISearchService _searchService;
        private readonly IBookingService _bookingService;
        private readonly IPublicStoreService _storeService;
        private readonly IServiceService _serviceService;
        private readonly IVoucherRepository _voucherRepository;

        public ChatKnowledgeProvider(
            IHomeService homeService,
            ISearchService searchService,
            IBookingService bookingService,
            IPublicStoreService storeService,
            IServiceService serviceService,
            IVoucherRepository voucherRepository)
        {
            _homeService = homeService;
            _searchService = searchService;
            _bookingService = bookingService;
            _storeService = storeService;
            _serviceService = serviceService;
            _voucherRepository = voucherRepository;
        }

        public async Task<string> BuildContextAsync(
            int userId,
            string message,
            double? lat = null,
            double? lon = null,
            CancellationToken cancellationToken = default)
        {
            var rawMessage = message ?? string.Empty;
            var normalizedMessage = ChatIntentClassifier.NormalizeText(rawMessage);
            var intent = ChatIntentClassifier.Classify(rawMessage);
            var searchKeyword = ChatKeywordExtractor.Extract(rawMessage);

            var effectiveKeyword = string.IsNullOrWhiteSpace(searchKeyword)
                ? rawMessage.Trim()
                : searchKeyword.Trim();

            var sb = new StringBuilder();

            AppendTextSection(sb, "CHAT_RULES", """
            Bạn là trợ lý tư vấn BeautyBookingSystem.
            Chỉ dùng dữ liệu thật trong CONTEXT.
            Không bịa, không suy đoán quá mức.
            Ưu tiên exact match, rồi contains match, rồi gần đúng.
            Nếu có nhiều kết quả, chọn kết quả phù hợp nhất hoặc liệt kê ngắn gọn.
            Nếu context có dữ liệu phù hợp thì không nói không tìm thấy.
            Trả lời gọn, chuyên nghiệp, có thể kèm link bấm được.
            """);

            try
            {
                if (intent == ChatIntent.GeneralInfo ||
                    intent == ChatIntent.SmallTalk ||
                    intent == ChatIntent.Ambiguous)
                {
                    var home = await _homeService.GetHomeDataAsync(null, lat, lon);

                    AppendJsonSection(sb, "HOME_SUMMARY", new
                    {
                        Categories = home.Categories
                            .Take(4)
                            .Select(x => new { x.Id, x.Name, x.IconUrl })
                            .ToList(),
                        ServiceGroups = home.ServiceGroups
                            .Take(4)
                            .Select(x => new { x.Id, x.Name })
                            .ToList(),
                        TopRatedStores = home.TopRatedStores?
                            .Take(4)
                            .Select(x => new
                            {
                                x.Id,
                                x.Name,
                                x.Address,
                                x.DistanceKm,
                                Rating = x.AverageRating,
                                x.TotalReviews,
                                Link = BuildDeepLink("store", x.Id)
                            })
                            .ToList(),
                        NearbyStores = home.NearbyStores
                            .Take(4)
                            .Select(x => new
                            {
                                x.Id,
                                x.Name,
                                x.Address,
                                x.DistanceKm,
                                Rating = x.AverageRating,
                                x.TotalReviews,
                                Link = BuildDeepLink("store", x.Id)
                            })
                            .ToList()
                    });
                }

                if (intent == ChatIntent.BookingStatus)
                {
                    var bookings = await _bookingService.GetBookingsByCustomerAsync(userId);

                    AppendJsonSection(sb, "BOOKINGS", bookings
                        .Take(5)
                        .Select(x => new
                        {
                            x.Id,
                            x.CreatedAt,
                            x.FinalPrice,
                            x.DepositAmount,
                            x.StoreName,
                            x.Status
                        })
                        .ToList());
                }

                if (intent == ChatIntent.VoucherQuery)
                {
                    var vouchers = await _voucherRepository.GetAllActiveAsync();

                    AppendJsonSection(sb, "ACTIVE_VOUCHERS", vouchers
                        .Take(5)
                        .Select(x => new
                        {
                            x.Id,
                            x.StoreId,
                            x.ServiceId,
                            x.Code,
                            x.ImageUrl,
                            x.DiscountType,
                            x.DiscountValue,
                            x.MinOrderValue,
                            x.MaxDiscount,
                            x.StartDate,
                            x.EndDate
                        })
                        .ToList());
                }

                if (intent == ChatIntent.StoreDetail || intent == ChatIntent.ServiceDetail)
                {
                    if (intent == ChatIntent.StoreDetail)
                    {
                        var stores = await SearchStoresAsync(effectiveKeyword, lat, lon, cancellationToken);

                        AppendJsonSection(sb, "STORE_DETAILS", stores
                            .Take(5)
                            .Select(x => new
                            {
                                x.Id,
                                x.Name,
                                x.Address,
                                x.ImageUrl,
                                x.Rating,
                                x.DistanceKm,
                                x.Lat,
                                x.Lng,
                                x.MinServicePrice,
                                Link = BuildDeepLink("store", x.Id)
                            })
                            .ToList());
                    }
                    else
                    {
                        var stores = await SearchStoresAsync(effectiveKeyword, lat, lon, cancellationToken);
                        var serviceCandidates = BuildMatchedServices(stores, effectiveKeyword).Take(6).ToList();

                        AppendJsonSection(sb, "SERVICE_DETAILS", serviceCandidates);
                    }
                }

                if (intent is ChatIntent.ServiceSearch
                    or ChatIntent.StoreSearch
                    or ChatIntent.CompareStore
                    or ChatIntent.CompareService
                    or ChatIntent.Ambiguous
                    or ChatIntent.GeneralInfo)
                {
                    var searchResults = await SearchStoresAsync(effectiveKeyword, lat, lon, cancellationToken);

                    AppendJsonSection(sb, "SEARCH_STORES", searchResults
                        .Take(5)
                        .Select(x => new
                        {
                            x.Id,
                            x.Name,
                            x.Address,
                            x.ImageUrl,
                            x.Rating,
                            x.DistanceKm,
                            x.Lat,
                            x.Lng,
                            x.MinServicePrice,
                            Link = BuildDeepLink("store", x.Id)
                        })
                        .ToList());

                    var matchedServices = BuildMatchedServices(searchResults, effectiveKeyword)
                        .Take(8)
                        .ToList();

                    AppendJsonSection(sb, "MATCHED_SERVICES", matchedServices);
                }
            }
            catch
            {
                AppendTextSection(sb, "CONTEXT_ERROR", "Không thể lấy đầy đủ dữ liệu hệ thống lúc này.");
            }

            // AppendJsonSection(sb, "INPUT_INFO", new
            // {
            //     RawMessage = rawMessage,
            //     NormalizedMessage = normalizedMessage,
            //     SearchKeyword = searchKeyword,
            //     EffectiveKeyword = effectiveKeyword,
            //     Intent = intent.ToString(),
            //     Lat = lat,
            //     Lon = lon
            // });

            return sb.ToString().Trim();
        }

        private async Task<List<SearchStoreResponse>> SearchStoresAsync(
            string keyword,
            double? lat,
            double? lon,
            CancellationToken cancellationToken)
        {
            var effectiveKeyword = string.IsNullOrWhiteSpace(keyword) ? null : keyword.Trim();

            var results = await _searchService.SearchAsync(new SearchRequest
            {
                Keyword = effectiveKeyword,
                UserLat = lat,
                UserLng = lon,
                SortBy = "nearest",
                MinPrice = null,
                MaxPrice = null,
                MinRating = null,
                Location = null
            });

            results ??= new List<SearchStoreResponse>();

            if (results.Count == 0 && !string.IsNullOrWhiteSpace(effectiveKeyword))
            {
                results = await _searchService.SearchAsync(new SearchRequest
                {
                    Keyword = null,
                    UserLat = lat,
                    UserLng = lon,
                    SortBy = "nearest",
                    MinPrice = null,
                    MaxPrice = null,
                    MinRating = null,
                    Location = null
                });

                results ??= new List<SearchStoreResponse>();

                results = results
                    .Select(store => new
                    {
                        Store = store,
                        Score = CalculateStoreScore(store.Name, store.Address, effectiveKeyword)
                    })
                    .Where(x => x.Score > 0)
                    .OrderByDescending(x => x.Score)
                    .ThenBy(x => x.Store.DistanceKm)
                    .Select(x => x.Store)
                    .ToList();
            }

            return results;
        }

        private static List<object> BuildMatchedServices(
            IEnumerable<SearchStoreResponse> searchResults,
            string keyword)
        {
            var candidates = new List<MatchedServiceCandidate>();

            foreach (var store in searchResults.Take(6))
            {
                var services = store.Services ?? new List<SearchServiceResponse>();

                foreach (var service in services)
                {
                    var score = CalculateServiceScore(
                        service.Name,
                        store.Name,
                        store.Address,
                        keyword);

                    if (score <= 0)
                        continue;

                    candidates.Add(new MatchedServiceCandidate(
                        store.Id,
                        store.Name,
                        store.Address,
                        store.Rating,
                        store.DistanceKm,
                        service.Id,
                        service.Name,
                        service.Price,
                        score,
                        BuildDeepLink("service", service.Id)));
                }
            }

            if (candidates.Count == 0)
            {
                foreach (var store in searchResults.Take(4))
                {
                    var services = store.Services ?? new List<SearchServiceResponse>();

                    foreach (var service in services.Take(2))
                    {
                        candidates.Add(new MatchedServiceCandidate(
                            store.Id,
                            store.Name,
                            store.Address,
                            store.Rating,
                            store.DistanceKm,
                            service.Id,
                            service.Name,
                            service.Price,
                            1,
                            BuildDeepLink("service", service.Id)));
                    }
                }
            }

            return candidates
                .OrderByDescending(x => x.Score)
                .ThenByDescending(x => x.StoreRating)
                .ThenBy(x => x.StoreDistanceKm)
                .Select(x => new
                {
                    x.StoreId,
                    x.StoreName,
                    x.StoreAddress,
                    x.StoreRating,
                    x.StoreDistanceKm,
                    x.ServiceId,
                    x.ServiceName,
                    x.ServicePrice,
                    x.Score,
                    x.Link
                })
                .Cast<object>()
                .ToList();
        }

        private static void AppendJsonSection<T>(StringBuilder sb, string title, T data)
        {
            sb.AppendLine($"=== {title} ===");
            sb.AppendLine(JsonSerializer.Serialize(data));
            sb.AppendLine();
        }

        private static void AppendTextSection(StringBuilder sb, string title, string text)
        {
            sb.AppendLine($"=== {title} ===");
            sb.AppendLine(text);
            sb.AppendLine();
        }

        private static int CalculateServiceScore(
            string? serviceName,
            string? storeName,
            string? storeAddress,
            string? query)
        {
            if (string.IsNullOrWhiteSpace(query))
                return 0;

            var score = 0;
            score += ScoreField(serviceName, query, exact: 100, contains: 70, allTokens: 55, anyToken: 20);
            score += ScoreField(storeName, query, exact: 40, contains: 28, allTokens: 18, anyToken: 8);
            score += ScoreField(storeAddress, query, exact: 18, contains: 12, allTokens: 8, anyToken: 4);

            return score;
        }

        private static int CalculateStoreScore(
            string? storeName,
            string? storeAddress,
            string? query)
        {
            if (string.IsNullOrWhiteSpace(query))
                return 0;

            var score = 0;
            score += ScoreField(storeName, query, exact: 100, contains: 70, allTokens: 50, anyToken: 18);
            score += ScoreField(storeAddress, query, exact: 25, contains: 18, allTokens: 10, anyToken: 5);

            return score;
        }

        private static int ScoreField(
            string? source,
            string query,
            int exact,
            int contains,
            int allTokens,
            int anyToken)
        {
            if (string.IsNullOrWhiteSpace(source) || string.IsNullOrWhiteSpace(query))
                return 0;

            var src = NormalizeText(source);
            var q = NormalizeText(query);

            if (string.IsNullOrWhiteSpace(src) || string.IsNullOrWhiteSpace(q))
                return 0;

            if (src == q)
                return exact;

            if (src.Contains(q, StringComparison.Ordinal))
                return contains;

            var tokens = q.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
            if (tokens.Length == 0)
                return 0;

            if (tokens.All(t => src.Contains(t, StringComparison.Ordinal)))
                return allTokens;

            if (tokens.Any(t => src.Contains(t, StringComparison.Ordinal)))
                return anyToken;

            return 0;
        }

        private static string NormalizeText(string? input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return string.Empty;

            var normalized = input.Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD);
            var sb = new StringBuilder();

            foreach (var c in normalized)
            {
                var category = CharUnicodeInfo.GetUnicodeCategory(c);
                if (category == UnicodeCategory.NonSpacingMark)
                    continue;

                if (char.IsLetterOrDigit(c))
                    sb.Append(c);
                else
                    sb.Append(' ');
            }

            return CollapseSpaces(sb.ToString().Normalize(NormalizationForm.FormC));
        }

        private static string CollapseSpaces(string input)
        {
            var result = input;
            while (result.Contains("  ", StringComparison.Ordinal))
                result = result.Replace("  ", " ");

            return result.Trim();
        }

        private static string BuildDeepLink(string type, object id)
        {
            return $"beautybooking://{type}/{id}";
        }

        private sealed record MatchedServiceCandidate(
            int StoreId,
            string StoreName,
            string StoreAddress,
            decimal? StoreRating,
            double? StoreDistanceKm,
            int ServiceId,
            string ServiceName,
            decimal ServicePrice,
            int Score,
            string Link);
    }
}