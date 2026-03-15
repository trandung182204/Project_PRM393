using Domain.Enums;

namespace Domain.Entities
{
    public class EventRegistration
    {
        [Key]
        public int Id { get; set; }

        public int EventId { get; set; }
        [ForeignKey("EventId")]
        public Event Event { get; set; }

        public int StudentId { get; set; }
        [ForeignKey("StudentId")]
        public Student Student { get; set; }

        public DateTime RegistrationDate { get; set; } = DateTime.UtcNow;

        public EventAttendanceStatus AttendanceStatus { get; set; } = EventAttendanceStatus.Registered;
    }
}
