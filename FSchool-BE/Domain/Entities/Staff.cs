namespace Domain.Entities
{
    public class Staff
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(100)]
        public string FullName { get; set; }

        [Required, MaxLength(20)]
        public string EmployeeId { get; set; } // Mã nhân viên / Giáo viên

        [MaxLength(50)]
        public string Department { get; set; }

        // Foreign Keys
        public int AccountId { get; set; }
        [ForeignKey("AccountId")]
        public Account Account { get; set; }

        // Navigation Properties
        public ICollection<Schedule> Schedules { get; set; }
    }
}
