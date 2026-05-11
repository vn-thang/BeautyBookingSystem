using BeautyBookingSystem.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using System.Text;
using System.Text.Json;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public sealed class GeminiChatClient : IChatAiClient
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public GeminiChatClient(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        public async Task<string> GenerateReplyAsync(
            string message,
            string context,
            string memory,
            CancellationToken cancellationToken = default)
        {
            var apiKey = _configuration["GEMINI_API_KEY"]
                ?? throw new InvalidOperationException("Missing GEMINI_API_KEY");

            var model = _configuration["Gemini:ComposerModel"] ?? "gemini-2.5-flash";

            var systemPrompt = """
            Bạn là trợ lý CSKH của BeautyBookingSystem.
            Trả lời tiếng Việt, tự nhiên, ngắn gọn, chuyên nghiệp.
            Chỉ dùng dữ liệu trong CONTEXT và MEMORY.
            Không bịa thông tin.
            Nếu dữ liệu chưa đủ thì hỏi lại ngắn gọn.
            Khi có danh sách kết quả, hãy gợi ý 3 lựa chọn tốt nhất.
            Có thể dùng markdown và deep link dạng beautybooking://store/{id} hoặc beautybooking://service/{id}.
            """;

            var prompt = $"""
            SYSTEM:
            {systemPrompt}

            MEMORY:
            {TrimTo(memory, 500)}

            CONTEXT:
            {TrimTo(context, 1200)}

            USER:
            {message}
            """;

            var payload = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new { text = prompt }
                        }
                    }
                },
                generationConfig = new
                {
                    temperature = 0.35
                }
            };

            using var request = new HttpRequestMessage(
                HttpMethod.Post,
                $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent");

            request.Headers.Add("x-goog-api-key", apiKey);
            request.Content = new StringContent(
                JsonSerializer.Serialize(payload),
                Encoding.UTF8,
                "application/json");

            using var response = await _httpClient.SendAsync(request, cancellationToken);
            var body = await response.Content.ReadAsStringAsync(cancellationToken);

            if (!response.IsSuccessStatusCode)
                throw new Exception($"Gemini composer error: {body}");

            using var doc = JsonDocument.Parse(body);
            return doc.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString() ?? string.Empty;
        }

        private static string TrimTo(string? value, int maxChars)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;

            var text = value.Trim();
            return text.Length <= maxChars ? text : text[..maxChars];
        }
    }
}