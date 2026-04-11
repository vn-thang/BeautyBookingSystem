namespace BeautyBookingSystem.Application.DTOs.Chat
{
    public static class ChatKeywordExtractor
    {
        private static readonly HashSet<string> StopWords = new(StringComparer.OrdinalIgnoreCase)
        {
            "cho", "toi", "mình", "ban", "giup", "hay", "xin", "vui", "long",
            "tìm", "tim", "xem", "o", "ở", "tai", "tại", "gan", "gần",
            "nhé", "nhe", "voi", "với", "va", "và", "theo", "khu", "vuc", "khuvuc",
            "nao", "nào", "dau", "đâu", "nay", "nay", "lam", "làm", "thử", "thu",
            "dich", "vu", "dịch", "dịch vụ", "service", "store", "cua", "hang", "cửa", "hàng",
            "so", "sanh", "so sánh", "so sanh", "dat", "đặt", "lich", "lịch"
        };

        public static string? Extract(string? message)
        {
            if (string.IsNullOrWhiteSpace(message))
                return null;

            var normalized = ChatIntentClassifier.NormalizeText(message);
            if (string.IsNullOrWhiteSpace(normalized))
                return null;

            var tokens = normalized
                .Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Where(t => !StopWords.Contains(t))
                .ToList();

            if (tokens.Count == 0)
                return null;

            var keyword = string.Join(' ', tokens).Trim();
            return string.IsNullOrWhiteSpace(keyword) ? null : keyword;
        }
    }
}