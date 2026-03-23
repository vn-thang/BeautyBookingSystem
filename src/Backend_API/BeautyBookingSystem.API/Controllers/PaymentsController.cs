using System.Net;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/payments")]
    public class PaymentsController : ControllerBase
    {
        private readonly IConfiguration _config;

        public PaymentsController(IConfiguration config)
        {
            _config = config;
        }

        [HttpPost("vnpay/create")]
        public IActionResult CreateVnpay([FromBody] CreatePaymentRequest req)
        {
            var tmnCode = _config["Vnpay:TmnCode"]!;
            var hashSecret = _config["Vnpay:HashSecret"]!;
            var returnUrl = _config["Vnpay:ReturnUrl"]!;
            var paymentUrl = _config["Vnpay:PaymentUrl"]!;

            var vnpayParams = new SortedDictionary<string, string>
            {
                ["vnp_Version"] = "2.1.0",
                ["vnp_Command"] = "pay",
                ["vnp_TmnCode"] = tmnCode,
                ["vnp_Amount"] = (req.Amount * 100).ToString(),
                ["vnp_CurrCode"] = "VND",
                ["vnp_TxnRef"] = req.OrderId,
                ["vnp_OrderInfo"] = req.OrderInfo,
                ["vnp_OrderType"] = "other",
                ["vnp_Locale"] = "vn",
                ["vnp_ReturnUrl"] = returnUrl,
                ["vnp_IpAddr"] = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1",
                ["vnp_CreateDate"] = DateTime.UtcNow.AddHours(7).ToString("yyyyMMddHHmmss")
            };

            var queryString = BuildQueryString(vnpayParams);
            var secureHash = HmacSha512(hashSecret, queryString);

            var url = $"{paymentUrl}?{queryString}&vnp_SecureHashType=HmacSHA512&vnp_SecureHash={secureHash}";
            return Ok(new { url });
        }

        [HttpGet("vnpay/ipn")]
        public IActionResult VnpayIpn()
        {
            var vnpParams = Request.Query.ToDictionary(k => k.Key, v => v.Value.ToString());

            if (!vnpParams.TryGetValue("vnp_SecureHash", out var secureHash))
            {
                return Ok(new { RspCode = "97", Message = "Missing signature" });
            }

            vnpParams.Remove("vnp_SecureHash");
            vnpParams.Remove("vnp_SecureHashType");

            var hashSecret = _config["Vnpay:HashSecret"]!;
            var sorted = new SortedDictionary<string, string>(vnpParams);

            var data = BuildQueryString(sorted);
            var checkHash = HmacSha512(hashSecret, data);

            if (!string.Equals(secureHash, checkHash, StringComparison.OrdinalIgnoreCase))
            {
                return Ok(new { RspCode = "97", Message = "Invalid signature" });
            }

            var responseCode = vnpParams.GetValueOrDefault("vnp_ResponseCode");
            var transactionStatus = vnpParams.GetValueOrDefault("vnp_TransactionStatus");

            if (responseCode == "00" && transactionStatus == "00")
            {
                // TODO: update DB thành công
                return Ok(new { RspCode = "00", Message = "Confirm Success" });
            }

            // TODO: update DB thất bại
            return Ok(new { RspCode = "00", Message = "Confirm Success" });
        }

        [HttpGet("vnpay/return")]
        public IActionResult VnPayReturn()
        {
            var responseCode = Request.Query["vnp_ResponseCode"];
            var appReturnUrl = _config["Vnpay:AppReturnUrl"];

            var status = responseCode == "00" ? "success" : "fail";

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

        private static string BuildQueryString(SortedDictionary<string, string> data)
        {
            var sb = new StringBuilder();

            foreach (var kv in data)
            {
                if (string.IsNullOrWhiteSpace(kv.Value)) continue;

                if (sb.Length > 0) sb.Append('&');
                sb.Append(WebUtility.UrlEncode(kv.Key));
                sb.Append('=');
                sb.Append(WebUtility.UrlEncode(kv.Value));
            }

            return sb.ToString();
        }

        private static string HmacSha512(string key, string input)
        {
            using var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(key));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(input));
            return Convert.ToHexString(hash).ToLowerInvariant();
        }
    }

    public class CreatePaymentRequest
    {
        public string OrderId { get; set; } = default!;
        public int Amount { get; set; }
        public string OrderInfo { get; set; } = default!;
    }
}