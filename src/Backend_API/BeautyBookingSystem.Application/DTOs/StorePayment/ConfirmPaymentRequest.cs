using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StorePayment
{
    public class ConfirmPaymentRequest
    {
        public string? TransactionId { get; set; }
        // Mã GD (nếu khách ck ngân hàng, thu ngân tự nhập)
    }
}
