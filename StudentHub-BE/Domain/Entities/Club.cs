using Domain.Enums;

namespace Domain.Entities
{
    public class Club
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; }

        [MaxLength(50)]
        public string Category { get; set; } // VD: Academic, Sports, Arts

        public int MembersCount { get; set; }

        public string ImageUrl { get; set; }

        public string Description { get; set; }

        public ClubStatus Status { get; set; } = ClubStatus.PendingApproval;

        public DateTime FoundedDate { get; set; } = DateTime.UtcNow;

        // Giáo viên cố vấn
        public int? AdvisorStaffId { get; set; }
        [ForeignKey("AdvisorStaffId")]
        public Staff AdvisorStaff { get; set; }

        // Navigation Properties
        public ICollection<StudentClub> StudentClubs { get; set; }

        public ICollection<Event> Events { get; set; }
    }
}
