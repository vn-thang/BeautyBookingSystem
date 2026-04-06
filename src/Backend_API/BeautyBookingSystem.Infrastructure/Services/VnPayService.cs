using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.DTOs.StoreWallet;
using BeautyBookingSystem.Infrastructure.Helpers;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Http;
using System;
using System.Linq;
using System.Text.Json;
using System.Net.Http;
using System.Net.Http.Json;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class VnPayService : IVnPayService
    {
        private readonly IConfiguration _configuration;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IHttpClientFactory _httpClientFactory;

        public VnPayService(IConfiguration configuration, IHttpContextAccessor httpContextAccessor, IHttpClientFactory httpClientFactory)
        {
            _configuration = configuration;
            _httpContextAccessor = httpContextAccessor;
            _httpClientFactory = httpClientFactory;
        }
        public string CreatePaymentUrl(TopUpRequest model)
        {
            var context = _httpContextAccessor.HttpContext;
            if (context == null) throw new Exception("Không tìm thấy HttpContext");

            var timeZoneById = TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
            var timeNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, timeZoneById);
            
            string tmnCode = _configuration["Vnpay:TmnCode"] ?? string.Empty;
            string hashSecret = _configuration["Vnpay:HashSecret"] ?? string.Empty;
            string baseUrl = _configuration["Vnpay:BaseUrl"] ?? string.Empty;
            string urlCallBack = _configuration["Vnpay:ReturnUrl"] ?? string.Empty;

            var tick = DateTime.Now.Ticks.ToString();
            var txnRef = $"{model.StoreId}_{tick}"; 

            var pay = new VnPayLibrary();
            var ipAddress = context.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

            pay.AddRequestData("vnp_Version", "2.1.0");
            pay.AddRequestData("vnp_Command", "pay");
            pay.AddRequestData("vnp_TmnCode", tmnCode);
            pay.AddRequestData("vnp_Amount", ((long)(model.Amount * 100)).ToString()); 
            pay.AddRequestData("vnp_CreateDate", timeNow.ToString("yyyyMMddHHmmss"));
            pay.AddRequestData("vnp_CurrCode", "VND");
            pay.AddRequestData("vnp_IpAddr", ipAddress);
            pay.AddRequestData("vnp_Locale", "vn");
            pay.AddRequestData("vnp_OrderInfo", $"Nap tien vao vi cua hang {model.StoreId}");
            pay.AddRequestData("vnp_OrderType", "other");
            pay.AddRequestData("vnp_ReturnUrl", urlCallBack);
            pay.AddRequestData("vnp_TxnRef", txnRef); 

            var paymentUrl = pay.CreateRequestUrl(baseUrl, hashSecret);

            return paymentUrl;
        }
        public VnPayResponseDto PaymentExecute()
        {
            var context = _httpContextAccessor.HttpContext;
            if (context == null) throw new Exception("Không tìm thấy HttpContext");

            var collections = context.Request.Query; 
            var pay = new VnPayLibrary();

            foreach (var (key, value) in collections)
            {
                if (!string.IsNullOrEmpty(key) && key.StartsWith("vnp_"))
                {
                    pay.AddResponseData(key, value.ToString());
                }
            }

            var vnp_orderId = pay.GetResponseData("vnp_TxnRef");
            var vnp_TransactionId = pay.GetResponseData("vnp_TransactionNo");
            var vnp_ResponseCode = pay.GetResponseData("vnp_ResponseCode");
            var vnp_OrderInfo = pay.GetResponseData("vnp_OrderInfo");
            
            var vnp_SecureHash = collections.FirstOrDefault(p => p.Key == "vnp_SecureHash").Value.ToString() ?? string.Empty;
            
            var vnp_Amount_String = collections.FirstOrDefault(p => p.Key == "vnp_Amount").Value.ToString() ?? "0";
            decimal amount = Convert.ToDecimal(vnp_Amount_String) / 100m;

            string hashSecret = _configuration["Vnpay:HashSecret"] ?? string.Empty;
            bool checkSignature = pay.ValidateSignature(vnp_SecureHash, hashSecret);

            if (!checkSignature)
            {
                return new VnPayResponseDto { Success = false };
            }

            return new VnPayResponseDto
            {
                Success = vnp_ResponseCode == "00",
                PaymentMethod = "VnPay",
                OrderDescription = vnp_OrderInfo,
                OrderId = vnp_orderId,
                TransactionId = vnp_TransactionId,
                VnPayResponseCode = vnp_ResponseCode,
                Amount = amount 
            };
        }

        public async Task<bool> RefundAsync(string vnp_TxnRef, string vnp_TransactionDate, decimal amount, string createBy)
        {
            var context = _httpContextAccessor.HttpContext;
            var ipAddress = context?.Connection?.RemoteIpAddress?.ToString() ?? "127.0.0.1";
            
            string tmnCode = _configuration["Vnpay:TmnCode"] ?? string.Empty;
            string hashSecret = _configuration["Vnpay:HashSecret"] ?? string.Empty;
            string refundUrl = _configuration["Vnpay:RefundUrl"] ?? string.Empty;

            var vnp_RequestId = Guid.NewGuid().ToString(); 
            var vnp_Version = "2.1.0";
            var vnp_Command = "refund";
            var vnp_TransactionType = "02";
            var vnp_Amount = ((long)(amount * 100)).ToString();
            var vnp_CreateDate = DateTime.Now.ToString("yyyyMMddHHmmss");
            var vnp_OrderInfo = $"Hoan tien cho giao dich {vnp_TxnRef}";

            var payLib = new VnPayLibrary();
            var signData = $"{vnp_RequestId}|{vnp_Version}|{vnp_Command}|{tmnCode}|{vnp_TransactionType}|{vnp_TxnRef}|{vnp_Amount}||{vnp_TransactionDate}|{createBy}|{vnp_CreateDate}|{ipAddress}|{vnp_OrderInfo}";
            
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
                vnp_OrderInfo = vnp_OrderInfo,
                vnp_TransactionDate = vnp_TransactionDate,
                vnp_CreateBy = createBy, 
                vnp_CreateDate = vnp_CreateDate,
                vnp_IpAddr = ipAddress,
                vnp_SecureHash = vnp_SecureHash
            };

            var client = _httpClientFactory.CreateClient("VnPayClient");
            var response = await client.PostAsJsonAsync(refundUrl, requestData);

            if (response.IsSuccessStatusCode)
            {
                var responseContent = await response.Content.ReadAsStringAsync();
                using JsonDocument doc = JsonDocument.Parse(responseContent);
                JsonElement root = doc.RootElement;
                
                string vnp_ResponseCode = root.GetProperty("vnp_ResponseCode").GetString()??string.Empty;
                string vnp_Message = root.GetProperty("vnp_Message").GetString()??string.Empty;

                if (vnp_ResponseCode == "00") 
                {
                    return true; 
                }
                else
                {
                    return false;
                }
            }

            return false;
        }
    }
}