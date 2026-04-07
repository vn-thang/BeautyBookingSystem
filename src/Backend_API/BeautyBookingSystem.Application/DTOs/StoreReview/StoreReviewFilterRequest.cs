using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreReview
{
    public class StoreReviewFilterRequest
    {
        public int? Rating { get; set; } 
        public bool? HasReplied { get; set; } 
       
    }
}
