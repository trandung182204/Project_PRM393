using Domain.Enums;

namespace Domain.Entities
{
    public class StudentClub
    {
        [Key]
        public int Id { get; set; }

        public int StudentId { get; set; }
        [ForeignKey("StudentId")]
        public Student Student { get; set; }

        public int ClubId { get; set; }
        [ForeignKey("ClubId")]
        public Club Club { get; set; }

        public ClubRole ClubRole { get; set; } = ClubRole.Member;

        public MembershipStatus Status { get; set; } = MembershipStatus.Pending;

        public DateTime JoinDate { get; set; } = DateTime.UtcNow;

        public DateTime? LeftDate { get; set; }
    }
}
