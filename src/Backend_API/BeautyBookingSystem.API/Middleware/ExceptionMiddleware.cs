using BeautyBookingSystem.Application.DTOs.Common;
using System.Net;
using System.Text.Json;

namespace BeautyBookingSystem.API.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                // Cho phép Request đi tiếp vào Controller
                await _next(context);
            }
            catch (Exception ex)
            {
                // Nếu Controller có lỗi, nó sẽ văng ra đây
                _logger.LogError(ex, "Lỗi hệ thống: {Message}", ex.Message);
                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError; // Lỗi 500

            // Trả về đúng format ApiResponse mà App Mobile mong đợi
            var response = ApiResponse<string>.ErrorResponse("Hệ thống đang bận hoặc gặp sự cố. Vui lòng thử lại sau!");

            var json = JsonSerializer.Serialize(response, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
            return context.Response.WriteAsync(json);
        }
    }
}
