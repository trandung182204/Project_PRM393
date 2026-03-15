namespace Application.DTOs.Grade
{
    public class GradeDto
    {
        public int Id { get; set; }
        public double OralScore { get; set; }
        public double SmallTestScore { get; set; }
        public double MiddleTestScore { get; set; }
        public double FinalTestScore { get; set; }
        public double Score { get; set; }
        public string Status { get; set; }
        public string SubjectName { get; set; }
        public string SemesterName { get; set; }
    }
}
