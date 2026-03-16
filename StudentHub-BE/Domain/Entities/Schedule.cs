

namespace Domain.Entities
{
    public class Schedule
    {
        [Key]
        public int Id { get; set; }

        public DateTime Date { get; set; } // Ngày di?n ra ti?t h?c

        // Các Foreign Keys trung tâm
        public int SlotId { get; set; }
        [ForeignKey("SlotId")]
        public Slot Slot { get; set; }

        public int SubjectId { get; set; }
        [ForeignKey("SubjectId")]
        public Subject Subject { get; set; }

        public int RoomId { get; set; }
        [ForeignKey("RoomId")]
        public Room Room { get; set; }

        public int ClassId { get; set; }
        [ForeignKey("ClassId")]
        public SchoolClass SchoolClass { get; set; }

        public int StaffId { get; set; }
        [ForeignKey("StaffId")]
        public Staff Staff { get; set; } // Giáo viên d?y

        // Navigation Properties
        public ICollection<Attendance> Attendances { get; set; }
    }
}
