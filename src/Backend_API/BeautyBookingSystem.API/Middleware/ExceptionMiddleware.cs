using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Common.Exceptions;
using System.Net;
using System.Text.Json;

namespace BeautyBookingSystem.API.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;

        public ExceptionMiddleware(
            RequestDelegate next,
            ILogger<ExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "System Error: {Message}", ex.Message);

                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(
            HttpContext context,
            Exception exception)
        {
            context.Response.ContentType = "application/json";

            var statusCode = HttpStatusCode.InternalServerError;
            var message = "Hệ thống đang bận hoặc gặp sự cố.";

            switch (exception)
            {
                case BadRequestException badRequest:
                    statusCode = HttpStatusCode.BadRequest;
                    message = badRequest.Message;
                    break;

                case UnauthorizedException unauthorized: 
                    statusCode = HttpStatusCode.Unauthorized;
                    message = unauthorized.Message;
                    break;

                case ForbiddenException forbidden: 
                    statusCode = HttpStatusCode.Forbidden;
                    message = forbidden.Message;
                    break;

                case NotFoundException notFound: 
                    statusCode = HttpStatusCode.NotFound;
                    message = notFound.Message;
                    break;

                case KeyNotFoundException:
                    statusCode = HttpStatusCode.NotFound;
                    message = "Không tìm thấy dữ liệu yêu cầu.";
                    break;
            }

            context.Response.StatusCode = (int)statusCode;

            var response = ApiResponse<string>.Fail(message);

            var json = JsonSerializer.Serialize(
                response,
                new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                });

            return context.Response.WriteAsync(json);
        }
    }
}