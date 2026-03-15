
namespace Domain.Entities
{
    public class SchoolClass
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(50)]
        public string ClassName { get; set; } // VD: 12A1

        [MaxLength(20)]
        public string AcademicYear { get; set; } // VD: 2024-2027

        // Navigation Properties
        public ICollection<Student> Students { get; set; }
        public ICollection<Schedule> Schedules { get; set; }
    }
}
