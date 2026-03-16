using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Grade
{
    public class GradeCreateUpdateDto
    {
        public int? Id { get; set; } // Null for new grades

        public double OralScore { get; set; }
        public double SmallTestScore { get; set; }
        public double MiddleTestScore { get; set; }
        public double FinalTestScore { get; set; }

        [MaxLength(20)]
        public string? Status { get; set; } // Passed, Failed

        [Required]
        public int StudentId { get; set; }

        [Required]
        public int SubjectId { get; set; }

        [Required]
        public int SemesterId { get; set; }
    }
}
