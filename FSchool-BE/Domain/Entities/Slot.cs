

namespace Domain.Entities
{
    public class Slot
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(50)]
        public string SlotName { get; set; } // VD: Slot 1

        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }

        // Foreign Keys
        public int ShiftId { get; set; }
        [ForeignKey("ShiftId")]
        public Shift Shift { get; set; }

        // Navigation Properties
        public ICollection<Schedule> Schedules { get; set; }

        // Many-to-Many với AbsenceRequest (EF Core tự sinh bảng trung gian)
        public ICollection<AbsenceRequest> AbsenceRequests { get; set; }
    }
}
