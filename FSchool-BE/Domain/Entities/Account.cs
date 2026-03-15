namespace Domain.Entities
{
    public class Account
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(20)]
        public string PhoneNumber { get; set; }

        [Required, MaxLength(255)]
        public string Email { get; set; }

        [Required]
        public string PasswordHash { get; set; }

        // Navigation Properties (1-1)
        public ICollection<Role> Roles { get; set; }
        public Student Student { get; set; }
        public Staff Staff { get; set; }
    }
}
