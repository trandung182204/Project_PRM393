using Microsoft.AspNetCore.Mvc;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Domain.Entities;

namespace StudentHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AbsenceRequestsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public AbsenceRequestsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/absencerequests?accountId=1&staffId=1
        [HttpGet]
        public async Task<IActionResult> GetAbsenceRequests([FromQuery] int? studentId, [FromQuery] int? accountId, [FromQuery] int? staffId)
        {
            var query = _context.AbsenceRequests
                .Include(a => a.Student)
                    .ThenInclude(s => s.SchoolClasses)
                .Include(a => a.Slots)
                .AsQueryable();

            // Privacy: If no ID is provided, return empty list instead of everything
            if (!studentId.HasValue && !accountId.HasValue && !staffId.HasValue)
            {
                return Ok(new List<object>());
            }

            // Support filtering by accountId (from login) or direct studentId
            if (accountId.HasValue)
            {
                var student = await _context.Students.FirstOrDefaultAsync(s => s.AccountId == accountId.Value);
                if (student != null)
                {
                    query = query.Where(a => a.StudentId == student.Id);
                }
                else
                {
                    return Ok(new List<object>()); // No student found for this account
                }
            }
            else if (studentId.HasValue)
            {
                query = query.Where(a => a.StudentId == studentId.Value);
            }
            else if (staffId.HasValue)
            {
                // Filter by staff: only requests where the staff is teaching at least one of the requested slots on that date
                query = query.Where(a => _context.Schedules.Any(s => 
                    s.StaffId == staffId.Value &&
                    s.Date.Date == a.Date.Date &&
                    a.Slots.Select(sl => sl.Id).Contains(s.SlotId) &&
                    s.SchoolClass.Students.Any(stu => stu.Id == a.StudentId)));
            }

            var requests = await query
                .OrderByDescending(a => a.CreatedDate)
                .ToListAsync();

            // Map to response with subject information
            var result = new List<object>();
            foreach (var a in requests)
            {
                var slotsDetail = new List<object>();
                // Fallback to student's first class if no schedule class is found during the loop
                string requestClassName = "N/A";
                var firstClass = a.Student.SchoolClasses.FirstOrDefault();
                if (firstClass != null && !string.IsNullOrWhiteSpace(firstClass.ClassName))
                {
                    requestClassName = firstClass.ClassName;
                }

                foreach (var s in a.Slots)
                {
                    // Find the subject for this student, date, and slot from schedule
                    var schedule = await _context.Schedules
                        .Include(sc => sc.Subject)
                        .Include(sc => sc.SchoolClass)
                        .ThenInclude(c => c.Students)
                        .FirstOrDefaultAsync(sc => 
                            sc.Date.Date == a.Date.Date && 
                            sc.SlotId == s.Id && 
                            sc.SchoolClass.Students.Any(stu => stu.Id == a.StudentId));

                    if (schedule != null && schedule.SchoolClass != null && !string.IsNullOrWhiteSpace(schedule.SchoolClass.ClassName))
                    {
                        requestClassName = schedule.SchoolClass.ClassName;
                    }

                    slotsDetail.Add(new
                    {
                        id = s.Id,
                        slotName = s.SlotName,
                        startTime = s.StartTime.ToString(@"hh\:mm"),
                        endTime = s.EndTime.ToString(@"hh\:mm"),
                        subjectName = schedule?.Subject?.SubjectName ?? "N/A"
                    });
                }

                result.Add(new
                {
                    id = a.Id,
                    date = a.Date,
                    reason = a.Reason,
                    status = a.Status,
                    createdDate = a.CreatedDate,
                    studentId = a.StudentId,
                    studentName = a.Student.FullName,
                    className = requestClassName,
                    slots = slotsDetail
                });
            }

            return Ok(result);
        }

        // GET: api/absencerequests/5
        [HttpGet("{id}")]
        public async Task<IActionResult> GetAbsenceRequest(int id)
        {
            var request = await _context.AbsenceRequests
                .Include(a => a.Student)
                .Include(a => a.Slots)
                .Where(a => a.Id == id)
                .Select(a => new
                {
                    id = a.Id,
                    date = a.Date,
                    reason = a.Reason,
                    status = a.Status,
                    createdDate = a.CreatedDate,
                    studentId = a.StudentId,
                    studentName = a.Student.FullName,
                    slots = a.Slots.Select(s => new
                    {
                        id = s.Id,
                        slotName = s.SlotName,
                        startTime = s.StartTime.ToString(@"hh\:mm"),
                        endTime = s.EndTime.ToString(@"hh\:mm")
                    })
                })
                .FirstOrDefaultAsync();

            if (request == null)
                return NotFound(new { message = "Absence request not found" });

            return Ok(request);
        }

        // POST: api/absencerequests
        [HttpPost]
        public async Task<IActionResult> CreateAbsenceRequest([FromBody] CreateAbsenceRequestDto dto)
        {
            if (dto == null)
                return BadRequest(new { message = "Invalid request body" });

            // Resolve Student from AccountId (since frontend sends Account.Id from login)
            var student = await _context.Students.FirstOrDefaultAsync(s => s.AccountId == dto.AccountId);
            if (student == null)
                return BadRequest(new { message = "Student not found for this account" });

            // Validate slots exist
            var slots = await _context.Slots
                .Where(s => dto.SlotIds.Contains(s.Id))
                .ToListAsync();

            if (slots.Count != dto.SlotIds.Count)
                return BadRequest(new { message = "One or more slots not found" });

            var absenceRequest = new AbsenceRequest
            {
                Date = dto.Date,
                Reason = dto.Reason,
                Status = "Pending",
                CreatedDate = DateTime.Now,
                StudentId = student.Id, // Use resolved Student.Id
                Slots = slots
            };

            _context.AbsenceRequests.Add(absenceRequest);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetAbsenceRequest), new { id = absenceRequest.Id }, new
            {
                id = absenceRequest.Id,
                date = absenceRequest.Date,
                reason = absenceRequest.Reason,
                status = absenceRequest.Status,
                createdDate = absenceRequest.CreatedDate,
                studentId = absenceRequest.StudentId,
                studentName = student.FullName,
                slots = slots.Select(s => new
                {
                    id = s.Id,
                    slotName = s.SlotName,
                    startTime = s.StartTime.ToString(@"hh\:mm"),
                    endTime = s.EndTime.ToString(@"hh\:mm")
                })
            });
        }

        // PUT: api/absencerequests/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAbsenceRequest(int id, [FromBody] UpdateAbsenceRequestDto dto)
        {
            var absenceRequest = await _context.AbsenceRequests
                .Include(a => a.Slots)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (absenceRequest == null)
                return NotFound(new { message = "Absence request not found" });

            if (absenceRequest.Status != "Pending")
                return BadRequest(new { message = "Only pending requests can be updated" });

            // Validate slots exist
            var slots = await _context.Slots
                .Where(s => dto.SlotIds.Contains(s.Id))
                .ToListAsync();

            if (slots.Count != dto.SlotIds.Count)
                return BadRequest(new { message = "One or more slots not found" });

            absenceRequest.Date = dto.Date;
            absenceRequest.Reason = dto.Reason;
            absenceRequest.Slots = slots;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Absence request updated successfully" });
        }

        // PATCH: api/absencerequests/5/status
        [HttpPatch("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateStatusDto dto)
        {
            var absenceRequest = await _context.AbsenceRequests.FindAsync(id);

            if (absenceRequest == null)
                return NotFound(new { message = "Absence request not found" });

            if (dto.Status != "Approved" && dto.Status != "Rejected" && dto.Status != "Pending")
                return BadRequest(new { message = "Invalid status. Must be 'Approved', 'Rejected', or 'Pending'." });

            absenceRequest.Status = dto.Status;
            await _context.SaveChangesAsync();

            return Ok(new { message = $"Absence request {dto.Status.ToLower()} successfully", status = dto.Status });
        }

        // DELETE: api/absencerequests/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAbsenceRequest(int id)
        {
            var absenceRequest = await _context.AbsenceRequests.FindAsync(id);

            if (absenceRequest == null)
                return NotFound(new { message = "Absence request not found" });

            if (absenceRequest.Status != "Pending")
                return BadRequest(new { message = "Only pending requests can be deleted" });

            _context.AbsenceRequests.Remove(absenceRequest);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Absence request deleted successfully" });
        }
    }

    // DTO for creating an absence request
    public class CreateAbsenceRequestDto
    {
        public DateTime Date { get; set; }
        public string Reason { get; set; }
        public int AccountId { get; set; } // This is the Account.Id from login
        public List<int> SlotIds { get; set; }
    }

    // DTO for updating an absence request
    public class UpdateAbsenceRequestDto
    {
        public DateTime Date { get; set; }
        public string Reason { get; set; }
        public List<int> SlotIds { get; set; }
    }

    // DTO for updating status
    public class UpdateStatusDto
    {
        public string Status { get; set; }
    }
}
