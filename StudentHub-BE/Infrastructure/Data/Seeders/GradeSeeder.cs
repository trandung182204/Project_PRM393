using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class GradeSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<GradeSeeder> _logger;

    public int Order => 4; // Depends on Student, Subject, Semester

    public GradeSeeder(
        ApplicationDbContext context,
        ILogger<GradeSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Grades.AnyAsync())
        {
            _logger.LogInformation("Grades already seeded, skipping...");
            return;
        }

        var student = await _context.Students.FirstOrDefaultAsync();
        var subjects = await _context.Subjects.ToListAsync();
        var semesters = await _context.Semesters.ToListAsync();

        if (student == null || subjects.Count < 3 || semesters.Count < 3)
        {
            _logger.LogWarning("Insufficient data to seed distributed grades. Skipping...");
            return;
        }

        var grades = new List<Grade>
        {
            // Semester 1 (Spring)
            new Grade { Score = 8.5, Status = "Passed", StudentId = student.Id, SubjectId = subjects[0].Id, SemesterId = semesters[0].Id },
            new Grade { Score = 9.0, Status = "Passed", StudentId = student.Id, SubjectId = subjects[1].Id, SemesterId = semesters[0].Id },
            
            // Semester 2 (Summer)
            new Grade { Score = 7.0, Status = "Passed", StudentId = student.Id, SubjectId = subjects[2].Id, SemesterId = semesters[1].Id },
            new Grade { Score = 4.5, Status = "Failed", StudentId = student.Id, SubjectId = subjects[3].Id, SemesterId = semesters[1].Id },
            
            // Semester 3 (Fall)
            new Grade { Score = 6.0, Status = "Passed", StudentId = student.Id, SubjectId = subjects[4].Id, SemesterId = semesters[2].Id }
        };

        await _context.Grades.AddRangeAsync(grades);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} grades for student {Id}", grades.Count, student.Id);
    }
}
