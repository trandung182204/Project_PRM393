namespace Domain.Entities
{
    public class Subject
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(20)]
        public string SubjectCode { get; set; } // VD: PRN211

        [Required, MaxLength(100)]
        public string SubjectName { get; set; }

        public int Credits { get; set; }

        public ICollection<Schedule> Schedules { get; set; }
        public ICollection<Grade> Grades { get; set; }
    }
}
