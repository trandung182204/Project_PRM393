
namespace Domain.Entities
{
    public class Semester
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(50)]
        public string Name { get; set; } // VD: Fall 2025

        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

        public ICollection<Grade> Grades { get; set; }
    }
}
