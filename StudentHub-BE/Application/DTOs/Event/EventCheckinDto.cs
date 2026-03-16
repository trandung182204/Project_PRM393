using System.ComponentModel.DataAnnotations;

namespace Application.DTOs.Event
{
    public class EventCheckinDto
    {
        [Required]
        public int StudentId { get; set; }
    }
}
