using Microsoft.AspNetCore.Mvc;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Domain.Enums;
using Application.DTOs.Event;

namespace FSchool.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public EventsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/events - Lấy sự kiện Published (hiển thị cho sinh viên)
        [HttpGet]
        public async Task<IActionResult> GetEvents()
        {
            var events = await _context.Events
                .Where(e => !e.IsNews && (e.Status == EventStatus.Published || e.Status == EventStatus.Ongoing))
                .Select(e => new
                {
                    id = e.Id,
                    title = e.Title,
                    date = e.EventDate.ToString("dd MMM yyyy"),
                    location = e.Location,
                    image = e.ImageUrl ?? "https://picsum.photos/id/1/500/300",
                    description = e.Description,
                    isNews = e.IsNews,
                    status = e.Status.ToString(),
                    clubId = e.ClubId,
                    budget = e.Budget,
                    maxParticipants = e.MaxParticipants,
                    registrationCount = e.Registrations != null ? e.Registrations.Count : 0
                })
                .ToListAsync();

            return Ok(events);
        }

        // GET: api/events/all - Lấy tất cả sự kiện (Admin)
        [HttpGet("all")]
        public async Task<IActionResult> GetAllEvents()
        {
            var events = await _context.Events
                .Where(e => !e.IsNews)
                .Select(e => new
                {
                    id = e.Id,
                    title = e.Title,
                    date = e.EventDate.ToString("dd MMM yyyy"),
                    location = e.Location,
                    image = e.ImageUrl ?? "https://picsum.photos/id/1/500/300",
                    description = e.Description,
                    isNews = e.IsNews,
                    status = e.Status.ToString(),
                    clubId = e.ClubId,
                    budget = e.Budget,
                    maxParticipants = e.MaxParticipants,
                    registrationCount = e.Registrations != null ? e.Registrations.Count : 0
                })
                .ToListAsync();

            return Ok(events);
        }

        // GET: api/events/pending - Sự kiện chờ duyệt (Admin)
        [HttpGet("pending")]
        public async Task<IActionResult> GetPendingEvents()
        {
            var events = await _context.Events
                .Where(e => e.Status == EventStatus.Pending)
                .Select(e => new
                {
                    id = e.Id,
                    title = e.Title,
                    date = e.EventDate.ToString("dd MMM yyyy"),
                    location = e.Location,
                    image = e.ImageUrl ?? "https://picsum.photos/id/1/500/300",
                    description = e.Description,
                    status = e.Status.ToString(),
                    clubId = e.ClubId,
                    budget = e.Budget,
                    maxParticipants = e.MaxParticipants
                })
                .ToListAsync();

            return Ok(events);
        }

        // POST: api/events/propose - Ban quản trị CLB đề xuất sự kiện
        [HttpPost("propose")]
        public async Task<IActionResult> ProposeEvent([FromBody] EventCreateUpdateDto eventDto)
        {
            // Kiểm tra trùng phòng nếu có RoomId
            if (eventDto.RoomId.HasValue)
            {
                var roomConflict = await _context.Events
                    .AnyAsync(e => e.RoomId == eventDto.RoomId
                        && e.EventDate.Date == eventDto.EventDate.Date
                        && e.Status != EventStatus.Cancelled
                        && e.Status != EventStatus.Completed);

                if (roomConflict)
                    return BadRequest("Room is already booked for this date.");
            }

            var @event = new Domain.Entities.Event
            {
                Title = eventDto.Title,
                EventDate = eventDto.EventDate,
                Location = eventDto.Location ?? "School Campus",
                ImageUrl = eventDto.ImageUrl ?? "https://picsum.photos/id/1/500/300",
                Description = eventDto.Description ?? "",
                IsNews = eventDto.IsNews,
                Status = EventStatus.Pending,
                ClubId = eventDto.ClubId,
                Budget = eventDto.Budget,
                MaxParticipants = eventDto.MaxParticipants,
                RoomId = eventDto.RoomId
            };

            _context.Events.Add(@event);
            await _context.SaveChangesAsync();

            return Ok(new { id = @event.Id, message = "Event proposal submitted for approval." });
        }

        // PUT: api/events/{id}/approve - Admin duyệt sự kiện
        [HttpPut("{id}/approve")]
        public async Task<IActionResult> ApproveEvent(int id)
        {
            var @event = await _context.Events.FindAsync(id);
            if (@event == null) return NotFound();

            if (@event.Status != EventStatus.Pending)
                return BadRequest("Event is not in Pending status.");

            @event.Status = EventStatus.Approved;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Event approved." });
        }

        // PUT: api/events/{id}/publish - Publish sự kiện cho mọi người thấy
        [HttpPut("{id}/publish")]
        public async Task<IActionResult> PublishEvent(int id)
        {
            var @event = await _context.Events.FindAsync(id);
            if (@event == null) return NotFound();

            if (@event.Status != EventStatus.Approved)
                return BadRequest("Event must be Approved before publishing.");

            @event.Status = EventStatus.Published;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Event published and visible to students." });
        }

        // POST: api/events/{id}/register?studentId=X - Học sinh đăng ký tham gia
        [HttpPost("{id}/register")]
        public async Task<IActionResult> RegisterForEvent(int id, [FromQuery] int studentId)
        {
            var @event = await _context.Events.FindAsync(id);
            if (@event == null) return NotFound("Event not found.");

            if (@event.Status != EventStatus.Published && @event.Status != EventStatus.Ongoing)
                return BadRequest("Event is not open for registration.");

            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound("Student not found.");

            // Kiểm tra đã đăng ký chưa
            var existing = await _context.EventRegistrations
                .FirstOrDefaultAsync(er => er.EventId == id && er.StudentId == studentId);

            if (existing != null)
                return BadRequest("Student already registered for this event.");

            // Kiểm tra max participants
            if (@event.MaxParticipants.HasValue)
            {
                var currentCount = await _context.EventRegistrations
                    .CountAsync(er => er.EventId == id);
                if (currentCount >= @event.MaxParticipants.Value)
                    return BadRequest("Event is full.");
            }

            var registration = new Domain.Entities.EventRegistration
            {
                EventId = id,
                StudentId = studentId,
                RegistrationDate = DateTime.UtcNow,
                AttendanceStatus = EventAttendanceStatus.Registered
            };

            _context.EventRegistrations.Add(registration);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Registered for event successfully." });
        }

        // PUT: api/events/{id}/checkin/{studentId} - Điểm danh (quét QR / tick tay)
        [HttpPut("{id}/checkin/{studentId}")]
        public async Task<IActionResult> CheckinStudent(int id, int studentId)
        {
            var registration = await _context.EventRegistrations
                .FirstOrDefaultAsync(er => er.EventId == id && er.StudentId == studentId);

            if (registration == null)
                return NotFound("Registration not found. Student must register first.");

            registration.AttendanceStatus = EventAttendanceStatus.Attended;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Student checked in successfully." });
        }

        // PUT: api/events/{id}/complete - Tổng kết sự kiện
        [HttpPut("{id}/complete")]
        public async Task<IActionResult> CompleteEvent(int id)
        {
            var @event = await _context.Events.FindAsync(id);
            if (@event == null) return NotFound();

            @event.Status = EventStatus.Completed;

            // Đánh dấu những người đã đăng ký nhưng không checkin là Absent
            var noShows = await _context.EventRegistrations
                .Where(er => er.EventId == id && er.AttendanceStatus == EventAttendanceStatus.Registered)
                .ToListAsync();

            foreach (var reg in noShows)
            {
                reg.AttendanceStatus = EventAttendanceStatus.Absent;
            }

            await _context.SaveChangesAsync();

            // Thống kê
            var totalRegistered = await _context.EventRegistrations.CountAsync(er => er.EventId == id);
            var totalAttended = await _context.EventRegistrations
                .CountAsync(er => er.EventId == id && er.AttendanceStatus == EventAttendanceStatus.Attended);

            return Ok(new
            {
                message = "Event completed.",
                totalRegistered,
                totalAttended,
                totalAbsent = totalRegistered - totalAttended
            });
        }

        // GET: api/events/{id}/registrations - Danh sách đăng ký
        [HttpGet("{id}/registrations")]
        public async Task<IActionResult> GetRegistrations(int id)
        {
            var registrations = await _context.EventRegistrations
                .Where(er => er.EventId == id)
                .Include(er => er.Student)
                .Select(er => new EventRegistrationDto
                {
                    StudentId = er.StudentId,
                    FullName = er.Student.FullName,
                    RollNumber = er.Student.RollNumber,
                    RegistrationDate = er.RegistrationDate,
                    AttendanceStatus = er.AttendanceStatus.ToString()
                })
                .ToListAsync();

            return Ok(registrations);
        }

        // GET: api/events/{id}/my-status?studentId=X - Kiểm tra trạng thái đăng ký
        [HttpGet("{id}/my-status")]
        public async Task<IActionResult> GetMyEventStatus(int id, [FromQuery] int studentId)
        {
            var registration = await _context.EventRegistrations
                .FirstOrDefaultAsync(er => er.EventId == id && er.StudentId == studentId);

            if (registration == null)
                return Ok(new { isRegistered = false, attendanceStatus = "None" });

            return Ok(new
            {
                isRegistered = true,
                attendanceStatus = registration.AttendanceStatus.ToString()
            });
        }

        // POST: api/events - Tạo sự kiện (Admin - trực tiếp Published)
        [HttpPost]
        public async Task<IActionResult> CreateEvent([FromBody] EventCreateUpdateDto eventDto)
        {
            var @event = new Domain.Entities.Event
            {
                Title = eventDto.Title,
                EventDate = eventDto.EventDate,
                Location = eventDto.Location ?? "School Campus",
                ImageUrl = eventDto.ImageUrl ?? "https://picsum.photos/id/1/500/300",
                Description = eventDto.Description ?? "",
                IsNews = eventDto.IsNews,
                Status = EventStatus.Published,
                ClubId = eventDto.ClubId,
                Budget = eventDto.Budget,
                MaxParticipants = eventDto.MaxParticipants,
                RoomId = eventDto.RoomId
            };

            _context.Events.Add(@event);
            await _context.SaveChangesAsync();

            return Ok(new { id = @event.Id });
        }

        // PUT: api/events/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateEvent(int id, [FromBody] EventCreateUpdateDto eventDto)
        {
            var @event = await _context.Events.FindAsync(id);
            if (@event == null) return NotFound();

            @event.Title = eventDto.Title;
            @event.EventDate = eventDto.EventDate;
            @event.Location = eventDto.Location ?? "School Campus";
            @event.ImageUrl = eventDto.ImageUrl ?? "https://picsum.photos/id/1/500/300";
            @event.Description = eventDto.Description ?? "";
            @event.IsNews = eventDto.IsNews;
            @event.ClubId = eventDto.ClubId;
            @event.Budget = eventDto.Budget;
            @event.MaxParticipants = eventDto.MaxParticipants;
            @event.RoomId = eventDto.RoomId;

            await _context.SaveChangesAsync();
            return Ok();
        }

        // DELETE: api/events/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteEvent(int id)
        {
            var @event = await _context.Events.FindAsync(id);
            if (@event == null) return NotFound();

            _context.Events.Remove(@event);
            await _context.SaveChangesAsync();
            return Ok();
        }

        // PUT: api/events/{id}/cancel - Hủy sự kiện
        [HttpPut("{id}/cancel")]
        public async Task<IActionResult> CancelEvent(int id)
        {
            var @event = await _context.Events.FindAsync(id);
            if (@event == null) return NotFound();

            if (@event.Status == EventStatus.Completed)
                return BadRequest("Cannot cancel a completed event.");

            @event.Status = EventStatus.Cancelled;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Event cancelled." });
        }
    }
}
