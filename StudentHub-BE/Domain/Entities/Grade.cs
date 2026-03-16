
namespace Domain.Entities
{
    public class Grade
    {
        [Key]
        public int Id { get; set; }

        public double OralScore { get; set; } // Hệ số 1
        public double SmallTestScore { get; set; } // Hệ số 1 (15 phút)
        public double MiddleTestScore { get; set; } // Hệ số 2 (45 phút)
        public double FinalTestScore { get; set; } // Hệ số 3 (Học kỳ)

        public double Score { get; set; } // Trung bình môn (Weighted Average)

        [MaxLength(20)]
        public string Status { get; set; } // Passed, Failed

        // Foreign Keys
        public int StudentId { get; set; }
        [ForeignKey("StudentId")]
        public Student Student { get; set; }

        public int SubjectId { get; set; }
        [ForeignKey("SubjectId")]
        public Subject Subject { get; set; }

        public int SemesterId { get; set; }
        [ForeignKey("SemesterId")]
        public Semester Semester { get; set; }
    }
}
