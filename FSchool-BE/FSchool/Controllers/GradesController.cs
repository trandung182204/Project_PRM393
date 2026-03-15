using Application.DTOs.Grade;
using Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FSchool.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GradesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public GradesController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("student/{studentId}")]
        public async Task<ActionResult<IEnumerable<GradeDto>>> GetByStudentId(
            int studentId, 
            [FromQuery] string? semester = null, 
            [FromQuery] string? scholastic = null)
        {
            var query = _context.Grades
                .Include(g => g.Subject)
                .Include(g => g.Semester)
                .Where(g => g.StudentId == studentId);

            if (!string.IsNullOrEmpty(semester))
            {
                query = query.Where(g => g.Semester.Name.Contains(semester));
            }

            if (!string.IsNullOrEmpty(scholastic))
            {
                query = query.Where(g => g.Semester.Name.Contains(scholastic));
            }

            var grades = await query
                .Select(g => new GradeDto
                {
                    Id = g.Id,
                    OralScore = g.OralScore,
                    SmallTestScore = g.SmallTestScore,
                    MiddleTestScore = g.MiddleTestScore,
                    FinalTestScore = g.FinalTestScore,
                    Score = g.Score,
                    Status = g.Status,
                    SubjectName = g.Subject.SubjectName,
                    SemesterName = g.Semester.Name
                })
                .ToListAsync();

            return Ok(grades);
        }

        [HttpPost]
        public async Task<ActionResult<GradeDto>> CreateOrUpdateGrade([FromBody] GradeCreateUpdateDto dto)
        {
            Domain.Entities.Grade grade;

            // Calculate weighted average
            // Oral (x1), 15m (x1), 45m (x2), Final (x3) => Total weight = 7
            double calculatedScore = Math.Round((dto.OralScore * 1 + dto.SmallTestScore * 1 + dto.MiddleTestScore * 2 + dto.FinalTestScore * 3) / 7, 1);
            string calculatedStatus = calculatedScore >= 5.0 ? "Passed" : "Failed";

            if (dto.Id.HasValue && dto.Id.Value > 0)
            {
                grade = await _context.Grades.FindAsync(dto.Id.Value);
                if (grade == null) return NotFound("Grade record not found.");
                
                grade.OralScore = dto.OralScore;
                grade.SmallTestScore = dto.SmallTestScore;
                grade.MiddleTestScore = dto.MiddleTestScore;
                grade.FinalTestScore = dto.FinalTestScore;
                grade.Score = calculatedScore;
                grade.Status = calculatedStatus;
                grade.SubjectId = dto.SubjectId;
                grade.SemesterId = dto.SemesterId;
                grade.StudentId = dto.StudentId;

                _context.Grades.Update(grade);
            }
            else
            {
                // Check if grade already exists for this student, subject, and semester
                grade = await _context.Grades.FirstOrDefaultAsync(g => 
                    g.StudentId == dto.StudentId && 
                    g.SubjectId == dto.SubjectId && 
                    g.SemesterId == dto.SemesterId);

                if (grade != null)
                {
                    grade.OralScore = dto.OralScore;
                    grade.SmallTestScore = dto.SmallTestScore;
                    grade.MiddleTestScore = dto.MiddleTestScore;
                    grade.FinalTestScore = dto.FinalTestScore;
                    grade.Score = calculatedScore;
                    grade.Status = calculatedStatus;
                    _context.Grades.Update(grade);
                }
                else
                {
                    grade = new Domain.Entities.Grade
                    {
                        OralScore = dto.OralScore,
                        SmallTestScore = dto.SmallTestScore,
                        MiddleTestScore = dto.MiddleTestScore,
                        FinalTestScore = dto.FinalTestScore,
                        Score = calculatedScore,
                        Status = calculatedStatus,
                        StudentId = dto.StudentId,
                        SubjectId = dto.SubjectId,
                        SemesterId = dto.SemesterId
                    };
                    await _context.Grades.AddAsync(grade);
                }
            }

            await _context.SaveChangesAsync();

            // Return the updated/created grade with navigation properties
            var result = await _context.Grades
                .Include(g => g.Subject)
                .Include(g => g.Semester)
                .FirstOrDefaultAsync(g => g.Id == grade.Id);

            return Ok(new GradeDto
            {
                Id = result.Id,
                OralScore = result.OralScore,
                SmallTestScore = result.SmallTestScore,
                MiddleTestScore = result.MiddleTestScore,
                FinalTestScore = result.FinalTestScore,
                Score = result.Score,
                Status = result.Status,
                SubjectName = result.Subject.SubjectName,
                SemesterName = result.Semester.Name
            });
        }

        [HttpGet("staff/{staffId}/classes")]
        public async Task<ActionResult<IEnumerable<object>>> GetClassesByStaff(int staffId)
        {
            var classes = await _context.Schedules
                .Where(s => s.StaffId == staffId)
                .Select(s => s.SchoolClass)
                .Distinct()
                .Select(c => new {
                    c.Id,
                    c.ClassName
                })
                .ToListAsync();

            return Ok(classes);
        }

        [HttpGet("staff/{staffId}/subjects")]
        public async Task<ActionResult<IEnumerable<object>>> GetSubjectsByStaff(int staffId)
        {
            var subjects = await _context.Schedules
                .Where(s => s.StaffId == staffId)
                .Select(s => s.Subject)
                .Distinct()
                .Select(sub => new {
                    sub.Id,
                    sub.SubjectName
                })
                .ToListAsync();

            return Ok(subjects);
        }
    }
}


