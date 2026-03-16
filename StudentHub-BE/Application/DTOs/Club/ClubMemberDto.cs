using Domain.Enums;

namespace Application.DTOs.Club
{
    public class ClubMemberDto
    {
        public int StudentId { get; set; }
        public string FullName { get; set; }
        public string RollNumber { get; set; }
        public string AvatarUrl { get; set; }
        public string ClubRole { get; set; }
        public string Status { get; set; }
        public DateTime JoinDate { get; set; }
        public DateTime? LeftDate { get; set; }
    }
}
