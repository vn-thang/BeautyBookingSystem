using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.CustomerStore
{
    public class StoreNearbyDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public string Address { get; set; } = "";
        public string? LogoUrl { get; set; }
        public string? CoverImageUrl { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public double DistanceKm { get; set; }
        public double AverageRating { get; set; }
        public int TotalReviews { get; set; }
    }
}
