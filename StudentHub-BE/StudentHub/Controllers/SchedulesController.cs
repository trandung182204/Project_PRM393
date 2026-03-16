using Microsoft.AspNetCore.Mvc;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Application.DTOs.Schedule;
using Infrastructure.Utils;
using Domain.Entities;

namespace StudentHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SchedulesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public SchedulesController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetSchedules(
            [FromQuery] int? classId,
            [FromQuery] int? staffId,
            [FromQuery] DateTime? fromDate,
            [FromQuery] DateTime? toDate)
        {
            // Mặc định: tuần hiện tại (Thứ 2 -> Chủ nhật)
            var now = DateTime.Now;
            var monday = now.AddDays(-(int)now.DayOfWeek + (int)DayOfWeek.Monday);
            if (now.DayOfWeek == DayOfWeek.Sunday) monday = monday.AddDays(-7);

            var from = fromDate?.Date ?? monday.Date;
            var to = toDate?.Date ?? from.AddDays(6).Date;

            var query = _context.Schedules
                .Include(s => s.Slot)
                .Include(s => s.Subject)
                .Include(s => s.Room)
                .Include(s => s.Staff)
                .Include(s => s.SchoolClass)
                .Where(s => s.Date.Date >= from && s.Date.Date <= to)
                .AsQueryable();

            if (classId.HasValue)
            {
                query = query.Where(s => s.ClassId == classId.Value);
            }

            if (staffId.HasValue)
            {
                query = query.Where(s => s.StaffId == staffId.Value);
            }

            var schedules = await query
                .OrderBy(s => s.Date).ThenBy(s => s.Slot.StartTime)
                .Select(s => new
                {
                    id = s.Id,
                    date = s.Date,
                    slotId = s.SlotId,
                    time = $"{s.Slot.StartTime:hh\\:mm} - {s.Slot.EndTime:hh\\:mm}",
                    subject = s.Subject != null ? s.Subject.SubjectName : "N/A",
                    className = (s.SchoolClass != null && !string.IsNullOrWhiteSpace(s.SchoolClass.ClassName)) ? s.SchoolClass.ClassName : "N/A",
                    room = s.Room != null ? s.Room.RoomName : "N/A",
                    teacher = s.Staff != null ? s.Staff.FullName : "N/A",
                    status = s.Date < DateTime.Now ? "Finished" : (s.Date.Date == DateTime.Now.Date ? "Happening" : "Upcoming")
                })
                .ToListAsync();

            return Ok(new
            {
                fromDate = from,
                toDate = to,
                schedules
            });
        }

        [HttpPost("batch")]
        public async Task<IActionResult> BatchSchedule([FromBody] BatchScheduleDto dto)
        {
            var schedules = new List<Schedule>();
            var currentDate = dto.StartDate.Date;
            int sessionsCreated = 0;

            while (sessionsCreated < dto.TotalSessions)
            {
                bool isTargetDay = dto.DaysOfWeek.Contains((int)currentDate.DayOfWeek);
                bool isHoliday = dto.SkipHolidays && HolidayUtility.IsPublicHoliday(currentDate);
                bool isSunday = dto.SkipSundays && HolidayUtility.IsSunday(currentDate);

                if (isTargetDay && !isHoliday && !isSunday)
                {
                    foreach (var slotId in dto.SlotIds)
                    {
                        if (sessionsCreated >= dto.TotalSessions) break;

                        schedules.Add(new Schedule
                        {
                            Date = currentDate,
                            SlotId = slotId,
                            SubjectId = dto.SubjectId,
                            RoomId = dto.RoomId,
                            ClassId = dto.ClassId,
                            StaffId = dto.StaffId
                        });
                        sessionsCreated++;
                    }
                }
                currentDate = currentDate.AddDays(1);

                // Safety break to prevent infinite loop (max 1 year)
                if (currentDate > dto.StartDate.AddYears(1)) break;
            }

            _context.Schedules.AddRange(schedules);
            await _context.SaveChangesAsync();

            return Ok(new { message = $"Đã tạo thành công {schedules.Count} buổi học.", count = schedules.Count });
        }

        [HttpPost]
        public async Task<IActionResult> CreateSchedule([FromBody] ScheduleCreateUpdateDto dto)
        {
            var schedule = new Schedule
            {
                Date = dto.Date,
                SlotId = dto.SlotId,
                SubjectId = dto.SubjectId,
                RoomId = dto.RoomId,
                ClassId = dto.ClassId,
                StaffId = dto.StaffId
            };

            _context.Schedules.Add(schedule);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Thêm buổi học thành công." });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSchedule(int id, [FromBody] ScheduleCreateUpdateDto dto)
        {
            var schedule = await _context.Schedules.FindAsync(id);
            if (schedule == null) return NotFound("Không tìm thấy lịch học.");

            schedule.Date = dto.Date;
            schedule.SlotId = dto.SlotId;
            schedule.SubjectId = dto.SubjectId;
            schedule.RoomId = dto.RoomId;
            schedule.ClassId = dto.ClassId;
            schedule.StaffId = dto.StaffId;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Cập nhật lịch học thành công." });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSchedule(int id)
        {
            var schedule = await _context.Schedules.FindAsync(id);
            if (schedule == null) return NotFound("Không tìm thấy lịch học.");

            _context.Schedules.Remove(schedule);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Xóa lịch học thành công." });
        }
    }
}
