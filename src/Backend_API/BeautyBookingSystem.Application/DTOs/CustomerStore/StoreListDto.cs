using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


    namespace BeautyBookingSystem.Application.DTOs.StoreCustomer
    {
        public class StoreListDto
        {
            public int Id { get; set; }
            public string Name { get; set; } = null!;
            public string Address { get; set; } = null!;
            public string? LogoUrl { get; set; }
            public decimal AverageRating { get; set; }
            public int TotalReviews { get; set; }
            public bool IsOpen { get; set; }
        }
    } 
