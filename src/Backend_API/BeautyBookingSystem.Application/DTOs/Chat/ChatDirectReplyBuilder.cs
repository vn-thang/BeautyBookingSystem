using System.Globalization;
using System.Text;
using BeautyBookingSystem.Application.DTOs.Search;

namespace BeautyBookingSystem.Application.DTOs.Chat
{
    public static class ChatDirectReplyBuilder
    {
        public static string BuildServiceReply(IReadOnlyList<SearchStoreResponse>? stores, string? keyword)
        {
            if (stores == null || stores.Count == 0)
                return "Mình chưa tìm thấy dịch vụ phù hợp gần bạn.";

            var candidates = stores
                .SelectMany(store =>
                {
                    var services = store.Services ?? new List<SearchServiceResponse>();

                    return services.Select(service => new
                    {
                        Store = store,
                        Service = service,
                        Score = Score(store, service, keyword)
                    });
                })
                .Where(x => x.Score > 0)
                .OrderByDescending(x => x.Score)
                .ThenByDescending(x => SafeDouble(x.Store.Rating))
                .ThenBy(x => SafeDistance(x.Store.DistanceKm) < 0 ? double.MaxValue : SafeDistance(x.Store.DistanceKm))
                .Take(3)
                .ToList();

            if (candidates.Count == 0)
                return "Mình đã tìm thấy vài cửa hàng gần bạn, nhưng chưa xác định rõ dịch vụ phù hợp nhất.";

            var best = candidates[0];
            var sb = new StringBuilder();

            sb.AppendLine("Mình tìm thấy dịch vụ phù hợp gần bạn:");
            sb.AppendLine($"- **Dịch vụ:** [{best.Service.Name}](beautybooking://service/{best.Service.Id}) - **{FormatMoney(best.Service.Price)}**");
            sb.AppendLine($"- **Cửa hàng:** [{best.Store.Name}](beautybooking://store/{best.Store.Id})");
            sb.AppendLine($"- **Địa chỉ:** {best.Store.Address}");

            var rating = SafeDouble(best.Store.Rating);
            if (rating > 0)
                sb.AppendLine($"- **Đánh giá:** {rating:0.0} ⭐");

            var distance = SafeDistance(best.Store.DistanceKm);
            if (distance >= 0)
                sb.AppendLine($"- **Khoảng cách:** {distance:0.0} km");

            if (candidates.Count > 1)
            {
                sb.AppendLine();
                sb.AppendLine("Một vài lựa chọn khác:");
                foreach (var item in candidates.Skip(1))
                {
                    sb.AppendLine($"- [{item.Service.Name}](beautybooking://service/{item.Service.Id}) tại [{item.Store.Name}](beautybooking://store/{item.Store.Id}) - {FormatMoney(item.Service.Price)}");
                }
            }

            return sb.ToString().Trim();
        }

        public static string BuildStoreReply(IReadOnlyList<SearchStoreResponse>? stores)
        {
            if (stores == null || stores.Count == 0)
                return "Mình chưa tìm thấy cửa hàng phù hợp gần bạn.";

            var topStores = stores
                .OrderByDescending(x => SafeDouble(x.Rating))
                .ThenBy(x => SafeDistance(x.DistanceKm) < 0 ? double.MaxValue : SafeDistance(x.DistanceKm))
                .Take(3)
                .ToList();

            var best = topStores[0];
            var sb = new StringBuilder();

            sb.AppendLine("Mình tìm thấy một số cửa hàng gần bạn:");
            sb.AppendLine($"- **[{best.Name}](beautybooking://store/{best.Id})**");
            sb.AppendLine($"  - Địa chỉ: {best.Address}");

            var rating = SafeDouble(best.Rating);
            if (rating > 0)
                sb.AppendLine($"  - Đánh giá: {rating:0.0} ⭐");

            var distance = SafeDistance(best.DistanceKm);
            if (distance >= 0)
                sb.AppendLine($"  - Khoảng cách: {distance:0.0} km");

            if (topStores.Count > 1)
            {
                sb.AppendLine();
                sb.AppendLine("Lựa chọn khác:");
                foreach (var store in topStores.Skip(1))
                {
                    sb.AppendLine($"- [{store.Name}](beautybooking://store/{store.Id}) — {store.Address}");
                }
            }

            return sb.ToString().Trim();
        }

        public static string BuildComparisonReply(IReadOnlyList<SearchStoreResponse>? stores, string? message)
        {
            if (stores == null || stores.Count == 0)
                return "Mình chưa tìm thấy đủ dữ liệu để so sánh.";

            var ranked = stores
                .Select(s => new
                {
                    Store = s,
                    Rating = SafeDouble(s.Rating),
                    Distance = SafeDistance(s.DistanceKm),
                    Price = SafeDecimal(s.MinServicePrice, decimal.MaxValue)
                })
                .OrderByDescending(x => x.Rating)
                .ThenBy(x => x.Distance < 0 ? double.MaxValue : x.Distance)
                .ThenBy(x => x.Price)
                .Take(2)
                .ToList();

            if (ranked.Count == 1)
            {
                var only = ranked[0].Store;
                return $"Mình chỉ tìm thấy một nơi phù hợp gần bạn: [{only.Name}](beautybooking://store/{only.Id}).";
            }

            var a = ranked[0];
            var b = ranked[1];

            var sb = new StringBuilder();
            sb.AppendLine("So sánh nhanh:");
            sb.AppendLine($"- **[{a.Store.Name}](beautybooking://store/{a.Store.Id})**");
            sb.AppendLine($"  - Đánh giá: {a.Rating:0.0} ⭐");
            if (a.Distance >= 0)
                sb.AppendLine($"  - Khoảng cách: {a.Distance:0.0} km");
            if (a.Price < decimal.MaxValue)
                sb.AppendLine($"  - Giá dịch vụ từ: {FormatMoney(a.Price)}");

            sb.AppendLine($"- **[{b.Store.Name}](beautybooking://store/{b.Store.Id})**");
            sb.AppendLine($"  - Đánh giá: {b.Rating:0.0} ⭐");
            if (b.Distance >= 0)
                sb.AppendLine($"  - Khoảng cách: {b.Distance:0.0} km");
            if (b.Price < decimal.MaxValue)
                sb.AppendLine($"  - Giá dịch vụ từ: {FormatMoney(b.Price)}");

            sb.AppendLine();

            if (a.Rating != b.Rating)
            {
                sb.AppendLine(a.Rating > b.Rating
                    ? $"Nếu ưu tiên **chất lượng/đánh giá**, [{a.Store.Name}](beautybooking://store/{a.Store.Id}) đang nhỉnh hơn."
                    : $"Nếu ưu tiên **chất lượng/đánh giá**, [{b.Store.Name}](beautybooking://store/{b.Store.Id}) đang nhỉnh hơn.");
            }

            if (a.Distance >= 0 && b.Distance >= 0 && a.Distance != b.Distance)
            {
                sb.AppendLine(a.Distance < b.Distance
                    ? $"Nếu ưu tiên **gần bạn hơn**, [{a.Store.Name}](beautybooking://store/{a.Store.Id}) thuận tiện hơn."
                    : $"Nếu ưu tiên **gần bạn hơn**, [{b.Store.Name}](beautybooking://store/{b.Store.Id}) thuận tiện hơn.");
            }

            if (a.Price != b.Price && a.Price < decimal.MaxValue && b.Price < decimal.MaxValue)
            {
                sb.AppendLine(a.Price < b.Price
                    ? $"Nếu ưu tiên **giá mềm hơn**, [{a.Store.Name}](beautybooking://store/{a.Store.Id}) lợi hơn."
                    : $"Nếu ưu tiên **giá mềm hơn**, [{b.Store.Name}](beautybooking://store/{b.Store.Id}) lợi hơn.");
            }

            return sb.ToString().Trim();
        }

        private static int Score(SearchStoreResponse store, SearchServiceResponse service, string? keyword)
        {
            var score = 0;
            var k = ChatIntentClassifier.NormalizeText(keyword);

            var serviceName = ChatIntentClassifier.NormalizeText(service.Name);
            var storeName = ChatIntentClassifier.NormalizeText(store.Name);
            var address = ChatIntentClassifier.NormalizeText(store.Address);

            if (!string.IsNullOrWhiteSpace(k))
            {
                if (serviceName == k)
                    score += 100;
                else if (serviceName.Contains(k, StringComparison.Ordinal))
                    score += 70;

                if (storeName.Contains(k, StringComparison.Ordinal))
                    score += 20;

                if (address.Contains(k, StringComparison.Ordinal))
                    score += 5;
            }

            score += (int)Math.Clamp(SafeDouble(store.Rating) * 10, 0, 50);

            var distance = SafeDistance(store.DistanceKm);
            if (distance >= 0)
                score += Math.Max(0, 20 - (int)Math.Round(distance));

            return score;
        }

        private static string FormatMoney(object? value)
        {
            if (value == null)
                return "không rõ";

            try
            {
                var amount = Convert.ToDecimal(value, CultureInfo.InvariantCulture);
                return string.Format(CultureInfo.GetCultureInfo("vi-VN"), "{0:N0}đ", amount);
            }
            catch
            {
                return "không rõ";
            }
        }

        private static double SafeDouble(object? value, double fallback = 0)
        {
            if (value == null)
                return fallback;

            try
            {
                return Convert.ToDouble(value, CultureInfo.InvariantCulture);
            }
            catch
            {
                return fallback;
            }
        }

        private static double SafeDistance(object? value)
        {
            if (value == null)
                return -1;

            try
            {
                var distance = Convert.ToDouble(value, CultureInfo.InvariantCulture);

                if (double.IsNaN(distance) || double.IsInfinity(distance) || distance < 0 || distance >= 1000)
                    return -1;

                return distance;
            }
            catch
            {
                return -1;
            }
        }

        private static decimal SafeDecimal(object? value, decimal fallback = decimal.MaxValue)
        {
            if (value == null)
                return fallback;

            try
            {
                return Convert.ToDecimal(value, CultureInfo.InvariantCulture);
            }
            catch
            {
                return fallback;
            }
        }
    }
}