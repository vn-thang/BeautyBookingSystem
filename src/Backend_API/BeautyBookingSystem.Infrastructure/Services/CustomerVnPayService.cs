using BeautyBookingSystem.Application.DTOs.Payments;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Helpers; // Dùng thư viện của bạn ở đây
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class CustomerVnPayService : ICustomerVnPayService
    {
        private readonly IConfiguration _config;

        public CustomerVnPayService(IConfiguration config)
        {
            _config = config;
        }
        public string CreatePaymentUrl(Payment payment, CreatePaymentRequest req, string ipAddress)
        {
            var vnpay = new VnPayLibrary(); 
            vnpay.AddRequestData("vnp_Version", "2.1.0");
            vnpay.AddRequestData("vnp_Command", "pay");
            vnpay.AddRequestData("vnp_TmnCode", _config["Vnpay:TmnCode"]!);
            vnpay.AddRequestData("vnp_Amount", ((long)(payment.Amount * 100)).ToString()); 
            vnpay.AddRequestData("vnp_CreateDate", DateTime.Now.ToString("yyyyMMddHHmmss"));
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
    }
}