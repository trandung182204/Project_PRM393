using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Subject
{
    public class SubjectDto
    {
        [Required, MaxLength(20)]
        public string SubjectCode { get; set; }

        [Required, MaxLength(100)]
        public string SubjectName { get; set; }

        [Required]
        public int Credits { get; set; }
    }
}
