namespace Application.DTOs.Event
{
    public class EventRegistrationDto
    {
        public int StudentId { get; set; }
        public string FullName { get; set; }
        public string RollNumber { get; set; }
        public DateTime RegistrationDate { get; set; }
        public string AttendanceStatus { get; set; }
    }
}
