using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Domain.Entities;
using Infrastructure.Data;
using Application.DTOs.Class;

namespace StudentHub.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ClassesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ClassesController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<SchoolClass>>> GetClasses()
        {
            return await _context.Classes.ToListAsync();
        }

        [HttpGet("{id}/students")]
        public async Task<ActionResult<IEnumerable<object>>> GetStudentsInClass(int id)
        {
            var students = await _context.Classes
                .Where(c => c.Id == id)
                .SelectMany(c => c.Students)
                .Select(s => new {
                    s.Id,
                    s.FullName,
                    s.RollNumber
                })
                .ToListAsync();

            return Ok(students);
        }

        [HttpPost]
        public async Task<ActionResult<SchoolClass>> CreateClass([FromBody] CreateClassDto dto)
        {
            var schoolClass = new SchoolClass
            {
                ClassName = dto.ClassName,
                AcademicYear = dto.AcademicYear
            };

            _context.Classes.Add(schoolClass);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetClasses), new { id = schoolClass.Id }, schoolClass);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateClass(int id, [FromBody] CreateClassDto dto)
        {
            var schoolClass = await _context.Classes.FindAsync(id);
            if (schoolClass == null) return NotFound("Lớp học không tồn tại.");

            schoolClass.ClassName = dto.ClassName;
            schoolClass.AcademicYear = dto.AcademicYear;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật lớp học thành công." });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteClass(int id)
        {
            var schoolClass = await _context.Classes
                .Include(c => c.Students)
                .Include(c => c.Schedules)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (schoolClass == null) return NotFound("Lớp học không tồn tại.");

            // Remove class (associations with students will be handled by EF if configured correctly)
            _context.Classes.Remove(schoolClass);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Xóa lớp học thành công." });
        }
    }
}

