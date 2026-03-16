using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Domain.Entities;
using Infrastructure.Data;
using System.Linq;

namespace StudentHub.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CourseRegistrationController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CourseRegistrationController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpPost("student/register")]
        public async Task<IActionResult> RegisterSubject([FromBody] SubjectRegistrationDto request)
        {
            var student = await _context.Students.FindAsync(request.StudentId);
            var subject = await _context.Subjects.FindAsync(request.SubjectId);
            var semester = await _context.Semesters.FindAsync(request.SemesterId);

            if (student == null || subject == null || semester == null)
                return BadRequest("Thông tin Sinh viên, Môn học hoặc Học kỳ không hợp lệ.");

            var existing = await _context.Grades.AnyAsync(g => g.StudentId == request.StudentId && g.SubjectId == request.SubjectId && g.SemesterId == request.SemesterId);
            if (existing) return BadRequest("Sinh viên đã đăng ký môn học này trong học kỳ này.");

            var grade = new Grade
            {
                StudentId = request.StudentId,
                SubjectId = request.SubjectId,
                SemesterId = request.SemesterId,
                Score = 0,
                Status = "Registered"
            };

            _context.Grades.Add(grade);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đăng ký môn học thành công." });
        }

        [HttpPost("staff/assign-class")]
        public async Task<IActionResult> AssignToClass([FromBody] ClassAssignmentDto request)
        {
            var student = await _context.Students.Include(s => s.SchoolClasses).FirstOrDefaultAsync(s => s.Id == request.StudentId);
            var schoolClass = await _context.Classes.Include(c => c.Students).FirstOrDefaultAsync(c => c.Id == request.ClassId);

            if (student == null || schoolClass == null)
                return BadRequest("Thông tin Sinh viên hoặc Lớp học không hợp lệ.");

            if (schoolClass.Students.Any(s => s.Id == request.StudentId))
                return BadRequest("Sinh viên đã có trong lớp này.");

            schoolClass.Students.Add(student);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Xếp lớp thành công." });
        }

        [HttpPost("staff/batch-assign-class")]
        public async Task<IActionResult> BatchAssignToClass([FromBody] BatchClassAssignmentDto request)
        {
            var schoolClass = await _context.Classes.Include(c => c.Students).FirstOrDefaultAsync(c => c.Id == request.ClassId);
            if (schoolClass == null) return BadRequest("Lớp học không hợp lệ.");

            var students = await _context.Students
                .Where(s => request.StudentIds.Contains(s.Id))
                .ToListAsync();

            foreach (var student in students)
            {
                if (!schoolClass.Students.Any(s => s.Id == student.Id))
                {
                    schoolClass.Students.Add(student);
                }
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Xếp lớp hàng loạt thành công." });
        }

        [HttpPost("staff/remove-class")]
        public async Task<IActionResult> RemoveFromClass([FromBody] RemoveFromClassDto request)
        {
            var schoolClass = await _context.Classes.Include(c => c.Students).FirstOrDefaultAsync(c => c.Id == request.ClassId);
            if (schoolClass == null) return BadRequest("Lớp học không hợp lệ.");

            var student = schoolClass.Students.FirstOrDefault(s => s.Id == request.StudentId);
            if (student == null) return BadRequest("Sinh viên không có trong lớp này.");

            schoolClass.Students.Remove(student);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Xóa sinh viên khỏi lớp thành công." });
        }
    }

    public class SubjectRegistrationDto
    {
        public int StudentId { get; set; }
        public int SubjectId { get; set; }
        public int SemesterId { get; set; }
    }

    public class ClassAssignmentDto
    {
        public int StudentId { get; set; }
        public int ClassId { get; set; }
    }

    public class BatchClassAssignmentDto
    {
        public int ClassId { get; set; }
        public List<int> StudentIds { get; set; }
    }

    public class RemoveFromClassDto
    {
        public int StudentId { get; set; }
        public int ClassId { get; set; }
    }
}
