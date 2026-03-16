using System.ComponentModel.DataAnnotations;
using Domain.Enums;

namespace Domain.Entities
{
    public class Event
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(200)]
        public string Title { get; set; }

        public DateTime EventDate { get; set; }

        [MaxLength(200)]
        public string Location { get; set; } 

        public string ImageUrl { get; set; }

        public string Description { get; set; }

        public bool IsNews { get; set; }

        public EventStatus Status { get; set; } = EventStatus.Pending;

        public decimal? Budget { get; set; }

        public int? MaxParticipants { get; set; }

        // FK to Club
        public int? ClubId { get; set; }
        [ForeignKey("ClubId")]
        public Club Club { get; set; }

        // FK to Room (for schedule/room conflict checking)
        public int? RoomId { get; set; }
        [ForeignKey("RoomId")]
        public Room Room { get; set; }

        // Navigation Properties
        public ICollection<EventRegistration> Registrations { get; set; }
    }
}
