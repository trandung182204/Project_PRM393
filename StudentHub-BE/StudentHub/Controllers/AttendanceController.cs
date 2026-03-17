using Microsoft.AspNetCore.Mvc;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Domain.Entities;

namespace StudentHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AttendanceController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public AttendanceController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// GET api/Attendance/{scheduleId}
        /// Returns list of students in the schedule's class with their attendance status.
        /// </summary>
        [HttpGet("{scheduleId}")]
        public async Task<IActionResult> GetAttendance(int scheduleId)
        {
            var schedule = await _context.Schedules
                .Include(s => s.SchoolClass)
                    .ThenInclude(c => c.Students)
                .FirstOrDefaultAsync(s => s.Id == scheduleId);

            if (schedule == null)
                return NotFound("Schedule not found.");

            if (schedule.SchoolClass == null)
                return NotFound("No class associated with this schedule.");

            var existingAttendance = await _context.Attendances
                .Where(a => a.ScheduleId == scheduleId)
                .ToListAsync();

            var result = schedule.SchoolClass.Students.Select(student =>
            {
                var attendance = existingAttendance.FirstOrDefault(a => a.StudentId == student.Id);
                return new
                {
                    studentId = student.Id,
                    fullName = student.FullName,
                    rollNumber = student.RollNumber,
                    status = attendance?.Status ?? "Not Marked",
                    attendanceId = attendance?.Id
                };
            }).OrderBy(s => s.rollNumber).ToList();

            return Ok(result);
        }

        /// <summary>
        /// POST api/Attendance/{scheduleId}
        /// Accepts [{ studentId, status }] and upserts attendance records.
        /// </summary>
        [HttpPost("{scheduleId}")]
        public async Task<IActionResult> SaveAttendance(int scheduleId, [FromBody] List<AttendanceDto> records)
        {
            var schedule = await _context.Schedules.FindAsync(scheduleId);
            if (schedule == null)
                return NotFound("Schedule not found.");

            foreach (var record in records)
            {
                var existing = await _context.Attendances
                    .FirstOrDefaultAsync(a => a.ScheduleId == scheduleId && a.StudentId == record.StudentId);

                if (existing != null)
                {
                    existing.Status = record.Status;
                }
                else
                {
                    _context.Attendances.Add(new Attendance
                    {
                        ScheduleId = scheduleId,
                        StudentId = record.StudentId,
                        Status = record.Status
                    });
                }
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Attendance saved successfully." });
        }
    }

    public class AttendanceDto
    {
        public int StudentId { get; set; }
        public string Status { get; set; } // Present, Absent
    }
}
