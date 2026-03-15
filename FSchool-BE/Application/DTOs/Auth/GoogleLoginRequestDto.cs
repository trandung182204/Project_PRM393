using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Auth
{
    public class GoogleLoginRequestDto
    {
        [Required]
        public string IdToken { get; set; } = null!;
    }
}
