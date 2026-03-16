using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Event
{
    public class EventCreateUpdateDto
    {
        [Required]
        [MaxLength(200)]
        public string Title { get; set; }

        public DateTime EventDate { get; set; }

        [MaxLength(200)]
        public string? Location { get; set; }

        public string? ImageUrl { get; set; }

        public string? Description { get; set; }

        public bool IsNews { get; set; }

        public int? ClubId { get; set; }

        public decimal? Budget { get; set; }

        public int? MaxParticipants { get; set; }

        public int? RoomId { get; set; }
    }
}
