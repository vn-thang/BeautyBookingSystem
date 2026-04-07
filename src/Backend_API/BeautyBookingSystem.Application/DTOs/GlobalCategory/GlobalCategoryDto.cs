namespace BeautyBookingSystem.Application.DTOs.GlobalCategory
{
    public class GlobalCategoryDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string? IconUrl { get; set; }
        public bool IsActive { get; set; }
        public int SortOrder { get; set; }
    }
}