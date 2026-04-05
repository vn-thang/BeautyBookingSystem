using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.AspNetCore.Mvc;
using System.Globalization;
using System.Net;
using System.Security.Cryptography;
using System.Text;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/payments")]
    public class PaymentsController : ControllerBase
    {
        private readonly IConfiguration _config;
        private readonly IUnitOfWork _unitOfWork;

        public PaymentsController(IConfiguration config, IUnitOfWork unitOfWork)
        {
            _config = config;
            _unitOfWork = unitOfWork;
        }

        [HttpPost("vnpay/create")]
        public async Task<IActionResult> CreateVnpay([FromBody] CreatePaymentRequest req)
        {
            if (req.BookingId <= 0)
                return BadRequest("BookingId invalid");

            if (req.Amount <= 0)
                return BadRequest("Amount invalid");

            var booking = await _unitOfWork.BookingRepository.GetByIdWithDetailsAsync(req.BookingId);
            if (booking == null)
                return NotFound("Booking not found");

            var now = DateTime.UtcNow.AddHours(7);

            var successfulPayments = booking.Payments
                .Where(p => p.Status == PaymentStatus.Success)
                .ToList();

            var paidAmount = successfulPayments.Sum(p => p.Amount);
            var remainingAmount = booking.FinalPrice - paidAmount;
            if (remainingAmount < 0) remainingAmount = 0;

            PaymentType ResolvePaymentType(decimal amount)
            {
                if (booking.DepositAmount > 0 &&
                    successfulPayments.Count == 0 &&
                    amount == booking.DepositAmount)
                {
                    return PaymentType.Deposit;
                }

                if (amount == booking.FinalPrice || amount == remainingAmount)
                {
                    return PaymentType.Full;
                }

                throw new InvalidOperationException("Số tiền thanh toán không hợp lệ");
            }

            // Chỉ lấy payment pending mới nhất
            var pendingPayments = booking.Payments
                .Where(p => p.Status == PaymentStatus.Pending)
                .OrderByDescending(p => p.Id)
                .ToList();

            if (pendingPayments.Count > 1)
            {
                // Nếu có nhiều pending bất thường, chỉ cho dùng pending mới nhất
                // và các pending cũ hơn coi như lỗi dữ liệu
                var latestPending = pendingPayments.First();

                foreach (var oldPending in pendingPayments.Skip(1))
                {
                    oldPending.Status = PaymentStatus.Failed;
                    _unitOfWork.PaymentRepository.Update(oldPending);
                }

                latestPending.Amount = req.Amount;
                latestPending.PaymentMethod = req.PaymentMethod;
                latestPending.PaymentType = ResolvePaymentType(req.Amount);

                _unitOfWork.PaymentRepository.Update(latestPending);
                await _unitOfWork.SaveChangesAsync();

                return await BuildVnpayResponse(latestPending, req, now);
            }

            if (pendingPayments.Count == 1)
            {
                var payment = pendingPayments[0];

                try
                {
                    payment.Amount = req.Amount;
                    payment.PaymentMethod = req.PaymentMethod;
                    payment.PaymentType = ResolvePaymentType(req.Amount);

                    _unitOfWork.PaymentRepository.Update(payment);
                    await _unitOfWork.SaveChangesAsync();

                    return await BuildVnpayResponse(payment, req, now);
                }
                catch (InvalidOperationException ex)
                {
                    return BadRequest(ex.Message);
                }
            }

            PaymentType paymentType;
            try
            {
                paymentType = ResolvePaymentType(req.Amount);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(ex.Message);
            }

            var newPayment = new Payment
            {
                BookingId = booking.Id,
                Amount = req.Amount,
                PaymentMethod = req.PaymentMethod,
                PaymentType = paymentType,
                Status = PaymentStatus.Pending
            };

            await _unitOfWork.PaymentRepository.AddAsync(newPayment);
            await _unitOfWork.SaveChangesAsync();

            return await BuildVnpayResponse(newPayment, req, now);
        }

        private async Task<IActionResult> BuildVnpayResponse(Payment payment, CreatePaymentRequest req, DateTime now)
        {
            var tmnCode = _config["Vnpay:TmnCode"]!;
            var hashSecret = _config["Vnpay:HashSecret"]!;
            var returnUrl = _config["Vnpay:ReturnUrl"]!;
            var paymentUrl = _config["Vnpay:PaymentUrl"]!;

            var orderId = $"PAY_{payment.Id}";

            var vnpayParams = new SortedDictionary<string, string>(StringComparer.Ordinal)
            {
                ["vnp_Version"] = "2.1.0",
                ["vnp_Command"] = "pay",
                ["vnp_TmnCode"] = tmnCode,
                ["vnp_Amount"] = ((long)req.Amount * 100).ToString(),
                ["vnp_CurrCode"] = "VND",
                ["vnp_TxnRef"] = orderId,
                ["vnp_OrderInfo"] = NormalizeVnpayText(req.OrderInfo),
                ["vnp_OrderType"] = "other",
                ["vnp_Locale"] = "vn",
                ["vnp_ReturnUrl"] = returnUrl,
                ["vnp_IpAddr"] = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1",
                ["vnp_CreateDate"] = now.ToString("yyyyMMddHHmmss")
            };

            var queryString = BuildVnpayQueryString(vnpayParams, encode: true);
            var secureHash = HmacSha512(hashSecret, queryString);
            var url = $"{paymentUrl}?{queryString}&vnp_SecureHash={secureHash}";

            return Ok(new
            {
                url,
                paymentId = payment.Id,
                bookingId = payment.BookingId,
                amount = req.Amount
            });
        }

        [HttpGet("vnpay/ipn")]
        public async Task<IActionResult> VnpayIpn()
        {
            var result = await ProcessVnpayCallbackAsync(Request.Query);

            return Ok(new
            {
                RspCode = result.Success ? "00" : "97",
                Message = result.Message
            });
        }

        [HttpGet("vnpay/return")]
        public async Task<IActionResult> VnPayReturn()
        {
            var result = await ProcessVnpayCallbackAsync(Request.Query);

            var appReturnUrl = _config["Vnpay:AppReturnUrl"]!;
            var status = result.Success ? "success" : "fail";

            return Content($@"
<html>
  <body style='text-align:center;padding-top:50px'>
    <h2>Đang chuyển về ứng dụng...</h2>
    <script>
      setTimeout(function() {{
        window.location.href = '{appReturnUrl}?status={status}';
      }}, 500);
    </script>
    <p>Nếu không tự chuyển, bấm nút bên dưới:</p>
    <a href='{appReturnUrl}?status={status}'>
      <button style='padding:10px 20px;font-size:16px'>Quay về app</button>
    </a>
  </body>
</html>
", "text/html");
        }

        private async Task<(bool Success, string Message)> ProcessVnpayCallbackAsync(IQueryCollection query)
        {
            var vnpParams = query.ToDictionary(k => k.Key, v => v.Value.ToString());

            if (!vnpParams.TryGetValue("vnp_SecureHash", out var secureHash))
                return (false, "Missing signature");

            vnpParams.Remove("vnp_SecureHash");
            vnpParams.Remove("vnp_SecureHashType");

            var hashSecret = _config["Vnpay:HashSecret"]!;
            var sorted = new SortedDictionary<string, string>(vnpParams, StringComparer.Ordinal);

            var signData = BuildVnpayQueryString(sorted, encode: true);
            var checkHash = HmacSha512(hashSecret, signData);

            if (!string.Equals(secureHash, checkHash, StringComparison.OrdinalIgnoreCase))
                return (false, "Invalid signature");

            var responseCode = vnpParams.GetValueOrDefault("vnp_ResponseCode");
            var transactionStatus = vnpParams.GetValueOrDefault("vnp_TransactionStatus");
            var orderId = vnpParams.GetValueOrDefault("vnp_TxnRef");

            if (string.IsNullOrWhiteSpace(orderId) || !orderId.StartsWith("PAY_"))
                return (false, "Invalid order id");

            if (!int.TryParse(orderId.Replace("PAY_", ""), out var paymentId))
                return (false, "Invalid payment id");

            var payment = await _unitOfWork.PaymentRepository.GetByIdAsync(paymentId);
            if (payment == null)
                return (false, "Payment not found");

            if (payment.Status == PaymentStatus.Success)
                return (true, "Already processed");

            var booking = await _unitOfWork.BookingRepository.GetByIdWithDetailsAsync(payment.BookingId);
            if (booking == null)
                return (false, "Booking not found");

            if (responseCode == "00" && transactionStatus == "00")
            {
                payment.Status = PaymentStatus.Success;
                payment.PaidAt = DateTime.UtcNow;

                _unitOfWork.PaymentRepository.Update(payment);

                var successfulPayments = booking.Payments
                    .Where(p => p.Status == PaymentStatus.Success || p.Id == payment.Id)
                    .ToList();

                var depositPaidAmount = successfulPayments
                    .Where(p => p.PaymentType == PaymentType.Deposit)
                    .Sum(p => p.Amount);

                var paidAmount = successfulPayments
                    .Where(p => p.PaymentType == PaymentType.Full)
                    .Sum(p => p.Amount);

                var remainingAmount = booking.FinalPrice - depositPaidAmount - paidAmount;
                if (remainingAmount < 0) remainingAmount = 0;

                if (remainingAmount <= 0)
                {
                    booking.Status = BookingStatus.Confirmed;
                }

                _unitOfWork.BookingRepository.Update(booking);
                await _unitOfWork.SaveChangesAsync();

                return (true, "Confirm Success");
            }

            payment.Status = PaymentStatus.Failed;
            _unitOfWork.PaymentRepository.Update(payment);
            await _unitOfWork.SaveChangesAsync();

            return (false, "Payment failed");
        }

        private static string BuildVnpayQueryString(SortedDictionary<string, string> data, bool encode)
        {
            var sb = new StringBuilder();

            foreach (var kv in data)
            {
                if (string.IsNullOrWhiteSpace(kv.Value)) continue;

                if (sb.Length > 0) sb.Append('&');

                if (encode)
                {
                    sb.Append(WebUtility.UrlEncode(kv.Key));
                    sb.Append('=');
                    sb.Append(WebUtility.UrlEncode(kv.Value));
                }
                else
                {
                    sb.Append(kv.Key);
                    sb.Append('=');
                    sb.Append(kv.Value);
                }
            }

            return sb.ToString();
        }

        private static string HmacSha512(string key, string input)
        {
            using var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(key));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(input));
            return Convert.ToHexString(hash).ToLowerInvariant();
        }

        private static string NormalizeVnpayText(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return string.Empty;

            var normalized = input.Normalize(NormalizationForm.FormD);
            var sb = new StringBuilder();

            foreach (var ch in normalized)
            {
                var category = CharUnicodeInfo.GetUnicodeCategory(ch);
                if (category == UnicodeCategory.NonSpacingMark) continue;

                if (char.IsLetterOrDigit(ch) || char.IsWhiteSpace(ch) || ch == '.' || ch == ',' || ch == '-' || ch == ':' || ch == '/')
                {
                    sb.Append(ch);
                }
            }

            return sb.ToString().Normalize(NormalizationForm.FormC).Trim();
        }
    }

    public class CreatePaymentRequest
    {
        public int BookingId { get; set; }
        public int Amount { get; set; }
        public string OrderInfo { get; set; } = default!;
        public PaymentMethod PaymentMethod { get; set; }
    }
}