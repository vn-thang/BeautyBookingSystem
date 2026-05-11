
using BeautyBookingSystem.Application.DTOs.Payments;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Helpers; 
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Net.Http.Json;
using System.Text.Json;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class CustomerVnPayService : ICustomerVnPayService
    {
        private readonly IConfiguration _config;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<CustomerVnPayService> _logger;

        public CustomerVnPayService(IConfiguration config,
        IHttpClientFactory httpClientFactory, 
            IHttpContextAccessor httpContextAccessor,
            ILogger<CustomerVnPayService> logger)
        {
            _config = config;
            _httpClientFactory = httpClientFactory;
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
        }

        public string CreatePaymentUrl(Payment payment, CreatePaymentRequest req, string ipAddress)
        {
            var vnpay = new VnPayLibrary(); 
            vnpay.AddRequestData("vnp_Version", "2.1.0");
            vnpay.AddRequestData("vnp_Command", "pay");
            vnpay.AddRequestData("vnp_TmnCode", _config["Vnpay:TmnCode"]!);
            vnpay.AddRequestData("vnp_Amount", ((long)(payment.Amount * 100)).ToString()); 
            
            var createDate = payment.CreatedAt.ToLocalTime(); 
            vnpay.AddRequestData("vnp_CreateDate", createDate.ToString("yyyyMMddHHmmss"));
            
            vnpay.AddRequestData("vnp_CurrCode", "VND");
            vnpay.AddRequestData("vnp_IpAddr", ipAddress);
            vnpay.AddRequestData("vnp_Locale", "vn");
            vnpay.AddRequestData("vnp_OrderInfo", $"Thanh toan don hang {payment.BookingId}");
            vnpay.AddRequestData("vnp_OrderType", "other"); 
            vnpay.AddRequestData("vnp_ReturnUrl", _config["Vnpay:CustomerReturnUrl"]!);
            vnpay.AddRequestData("vnp_TxnRef", $"PAY_{payment.Id}");
            
            string paymentUrl = vnpay.CreateRequestUrl(_config["Vnpay:BaseUrl"]!, _config["Vnpay:HashSecret"]!);

            return paymentUrl;
        }

        public VnPayCallbackResult ValidateCallback(IQueryCollection query)
        {
            var vnpay = new VnPayLibrary();

            foreach (var (key, value) in query)
            {
                if (!string.IsNullOrEmpty(key) && key.StartsWith("vnp_"))
                {
                    vnpay.AddResponseData(key, value.ToString());
                }
            }

            string orderId = vnpay.GetResponseData("vnp_TxnRef");
            string vnp_ResponseCode = vnpay.GetResponseData("vnp_ResponseCode");
            string vnp_TransactionStatus = vnpay.GetResponseData("vnp_TransactionStatus");
            string vnp_SecureHash = query["vnp_SecureHash"].ToString();
            string transactionId = vnpay.GetResponseData("vnp_TransactionNo"); 

            bool isValidSignature = vnpay.ValidateSignature(vnp_SecureHash, _config["Vnpay:HashSecret"]!);

            return new VnPayCallbackResult
            {
                IsValidSignature = isValidSignature,
                OrderId = orderId,
                ResponseCode = vnp_ResponseCode,
                TransactionStatus = vnp_TransactionStatus,
                TransactionId = transactionId,
                Message = isValidSignature ? "Success" : "Invalid signature"
            };
        }
        public async Task<(bool IsSuccess, string ResponseCode, string Message)> RefundAsync(
            string vnp_TxnRef, 
            string vnp_TransactionDate, 
            decimal amount, 
            string createBy, 
            string vnp_TransactionNo = "") 
        {
            var context = _httpContextAccessor.HttpContext;
            var ipAddress = context?.Connection?.RemoteIpAddress?.ToString() ?? "127.0.0.1";
            
            string tmnCode = _config["Vnpay:TmnCode"] ?? string.Empty;
            string hashSecret = _config["Vnpay:HashSecret"] ?? string.Empty;
            string refundUrl = _config["Vnpay:RefundUrl"] ?? string.Empty;

            var vnp_RequestId = Guid.NewGuid().ToString(); 
            var vnp_Version = "2.1.0";
            var vnp_Command = "refund";
            var vnp_TransactionType = "02"; 
            var vnp_Amount = ((long)(amount * 100)).ToString();
            var vnp_CreateDate = DateTime.Now.ToString("yyyyMMddHHmmss");
            var vnp_OrderInfo = $"Hoan tien cho giao dich {vnp_TxnRef}";

            var payLib = new VnPayLibrary();
            
            var signData = $"{vnp_RequestId}|{vnp_Version}|{vnp_Command}|{tmnCode}|{vnp_TransactionType}|{vnp_TxnRef}|{vnp_Amount}|{vnp_TransactionNo}|{vnp_TransactionDate}|{createBy}|{vnp_CreateDate}|{ipAddress}|{vnp_OrderInfo}";
            
            var vnp_SecureHash = payLib.HmacSHA512(hashSecret, signData);
            
            var requestData = new
            {
                vnp_RequestId = vnp_RequestId,
                vnp_Version = vnp_Version,
                vnp_Command = vnp_Command,
                vnp_TmnCode = tmnCode,
                vnp_TransactionType = vnp_TransactionType,
                vnp_TxnRef = vnp_TxnRef,
                vnp_Amount = vnp_Amount,
                vnp_TransactionNo = vnp_TransactionNo,
                vnp_TransactionDate = vnp_TransactionDate,
                vnp_CreateBy = createBy, 
                vnp_CreateDate = vnp_CreateDate,
                vnp_IpAddr = ipAddress,
                vnp_SecureHash = vnp_SecureHash,
                vnp_OrderInfo = vnp_OrderInfo
            };

            try 
            {
                var client = _httpClientFactory.CreateClient();
                var response = await client.PostAsJsonAsync(refundUrl, requestData);

                if (response.IsSuccessStatusCode)
                {
                    var responseContent = await response.Content.ReadAsStringAsync();
                    _logger.LogInformation($"VNPay Refund Response: {responseContent}");

                    using JsonDocument doc = JsonDocument.Parse(responseContent);
                    JsonElement root = doc.RootElement;
                    
                    string vnp_ResponseCode = root.GetProperty("vnp_ResponseCode").GetString() ?? string.Empty;
                    string vnp_Message = root.GetProperty("vnp_Message").GetString() ?? string.Empty;

                    if (vnp_ResponseCode == "00") 
                    {
                        return (true, "00", "Hoàn tiền thành công"); 
                    }
                    
                    return (false, vnp_ResponseCode, vnp_Message);
                }

                _logger.LogError($"VNPay Refund API failed: {response.StatusCode}");
                return (false, "HTTP_ERROR", "Lỗi kết nối đến cổng VNPay");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception in VNPay Refund API");
                return (false, "EXCEPTION", "Có lỗi xảy ra khi gọi API VNPay");
            }
        }
    }
}