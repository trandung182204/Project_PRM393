namespace Application.DTOs.Semester
{
    public class FilterOptionsDto
    {
        public List<string> Years { get; set; } = new();
        public List<string> Semesters { get; set; } = new();
    }
}
