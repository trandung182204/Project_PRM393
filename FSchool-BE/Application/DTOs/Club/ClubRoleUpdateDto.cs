using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Club
{
    public class ClubRoleUpdateDto
    {
        [Required]
        public string Role { get; set; } // President, VicePresident, Secretary, Treasurer, Member
    }
}
