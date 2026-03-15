namespace Domain.Entities
{
    public class AbsenceRequest
    {
        [Key]
        public int Id { get; set; }

        public DateTime Date { get; set; } // Ngày xin nghỉ

        [MaxLength(500)]
        public string Reason { get; set; }

        [MaxLength(50)]
        public string Status { get; set; } // Pending, Approved, Rejected

        public DateTime CreatedDate { get; set; } = DateTime.Now;

        // Foreign Keys
        public int StudentId { get; set; }
        [ForeignKey("StudentId")]
        public Student Student { get; set; }

        // Many-to-Many với Slot
        public ICollection<Slot> Slots { get; set; }
    }
}