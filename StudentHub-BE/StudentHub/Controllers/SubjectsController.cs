using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Domain.Entities;
using Infrastructure.Data;
using Application.DTOs.Subject;

namespace StudentHub.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SubjectsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public SubjectsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Subject>>> GetSubjects()
        {
            return await _context.Subjects.ToListAsync();
        }

        [HttpPost]
        public async Task<ActionResult<Subject>> CreateSubject([FromBody] SubjectDto dto)
        {
            var subject = new Subject
            {
                SubjectCode = dto.SubjectCode,
                SubjectName = dto.SubjectName,
                Credits = dto.Credits
            };

            _context.Subjects.Add(subject);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetSubjects), new { id = subject.Id }, subject);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSubject(int id, [FromBody] SubjectDto dto)
        {
            var subject = await _context.Subjects.FindAsync(id);
            if (subject == null) return NotFound("Môn học không tồn tại.");

            subject.SubjectCode = dto.SubjectCode;
            subject.SubjectName = dto.SubjectName;
            subject.Credits = dto.Credits;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật môn học thành công." });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSubject(int id)
        {
            var subject = await _context.Subjects
                .Include(s => s.Schedules)
                .Include(s => s.Grades)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (subject == null) return NotFound("Môn học không tồn tại.");

            if (subject.Schedules != null && subject.Schedules.Any())
            {
                return BadRequest("Không thể xóa môn học này vì nó đã được xếp lịch cho lớp học.");
            }

            if (subject.Grades != null && subject.Grades.Any())
            {
                return BadRequest("Không thể xóa môn học này vì đã có điểm của sinh viên.");
            }

            _context.Subjects.Remove(subject);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Xóa môn học thành công." });
        }
    }
}
