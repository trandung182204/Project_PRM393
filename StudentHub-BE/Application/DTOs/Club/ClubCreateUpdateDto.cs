using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Club
{
    public class ClubCreateUpdateDto
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; }

        [MaxLength(50)]
        public string? Category { get; set; }

        public string? ImageUrl { get; set; }

        public string? Description { get; set; }
    }
}
