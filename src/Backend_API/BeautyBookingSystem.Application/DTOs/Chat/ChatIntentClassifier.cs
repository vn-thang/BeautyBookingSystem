using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace BeautyBookingSystem.Application.DTOs.Chat
{
    public static class ChatIntentClassifier
    {
        public static ChatIntent Classify(string? message)
        {
            var text = NormalizeText(message);

            if (string.IsNullOrWhiteSpace(text))
                return ChatIntent.Unknown;

            if (ContainsAny(text, "voucher", "khuyen mai", "uu dai", "giam gia", "ma giam gia"))
                return ChatIntent.VoucherQuery;

            if (ContainsAny(text, "booking", "dat lich", "lich hen", "xem lich", "huy lich", "don dat lich", "lich cua toi"))
                return ChatIntent.BookingStatus;

            if (ContainsAny(text, "so sanh", "compare", "khac nhau", "nen chon", "nen di"))
            {
                if (ContainsAny(text, "dich vu", "service", "goi dau", "massage", "nail", "mi", "makeup", "waxing", "nho to", "duong sinh"))
                    return ChatIntent.CompareService;

                return ChatIntent.CompareStore;
            }

            if (ContainsAny(text, "chi tiet", "detail"))
            {
                if (ContainsAny(text, "dich vu", "service", "goi dau", "massage", "nail", "mi", "makeup", "waxing"))
                    return ChatIntent.ServiceDetail;

                if (ContainsAny(text, "cua hang", "store", "spa", "salon", "tiem"))
                    return ChatIntent.StoreDetail;
            }

            var isStore = ContainsAny(text, "cua hang", "store", "spa", "salon", "tiem", "near", "gan", "o dau", "dia chi", "quan nao", "o khu vuc nao");
            var isService = ContainsAny(text, "dich vu", "service", "goi dau", "massage", "nail", "mi", "makeup", "waxing", "lam mong", "nho toc", "nhuom toc", "uong toc", "chuom toc");

            if (isStore && isService)
                return ChatIntent.Ambiguous;

            if (isService)
                return ChatIntent.ServiceSearch;

            if (isStore)
                return ChatIntent.StoreSearch;

            if (ContainsAny(text, "xin chao", "chao", "hello", "hi", "cam on", "thanks"))
                return ChatIntent.SmallTalk;

            return ChatIntent.GeneralInfo;
        }

        public static string NormalizeText(string? input)
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

            return Regex.Replace(sb.ToString().Normalize(NormalizationForm.FormC), @"\s+", " ").Trim();
        }

        private static bool ContainsAny(string text, params string[] keywords)
        {
            return keywords.Any(k => text.Contains(k, StringComparison.Ordinal));
        }
    }
}