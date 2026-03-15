namespace Domain.Entities
{
    public class Attendance
    {
        [Key]
        public int Id { get; set; }

        [MaxLength(20)]
        public string Status { get; set; } // Present, Absent, Late

        // Foreign Keys
        public int StudentId { get; set; }
        [ForeignKey("StudentId")]
        public Student Student { get; set; }

        public int ScheduleId { get; set; }
        [ForeignKey("ScheduleId")]
        public Schedule Schedule { get; set; }
    }
}
