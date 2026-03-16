
namespace Domain.Entities   
{
    public class Shift
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(50)]
        public string ShiftName { get; set; } // VD: Sáng, Chi?u

        public ICollection<Slot> Slots { get; set; }
    }
}
