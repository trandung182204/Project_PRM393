
namespace Domain.Entities
{
    public class Room
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(50)]
        public string RoomName { get; set; } // VD: BE-333

        public int Capacity { get; set; }

        public ICollection<Schedule> Schedules { get; set; }
    }
}
