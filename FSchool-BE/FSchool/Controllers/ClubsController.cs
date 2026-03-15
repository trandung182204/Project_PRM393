using Microsoft.AspNetCore.Mvc;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Domain.Enums;
using Application.DTOs.Club;

namespace FSchool.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ClubsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ClubsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/clubs - Lấy danh sách CLB (chỉ Active)
        [HttpGet]
        public async Task<IActionResult> GetClubs()
        {
            var clubs = await _context.Clubs
                .Where(c => c.Status == ClubStatus.Active)
                .Select(c => new
                {
                    id = c.Id,
                    name = c.Name,
                    category = c.Category,
                    members = c.StudentClubs.Count(sc => sc.Status == MembershipStatus.Active),
                    image = c.ImageUrl ?? "https://picsum.photos/id/5/200/200",
                    description = c.Description,
                    status = c.Status.ToString(),
                    foundedDate = c.FoundedDate
                })
                .ToListAsync();

            return Ok(clubs);
        }

        // GET: api/clubs/pending - Danh sách CLB chờ duyệt (Admin)
        [HttpGet("pending")]
        public async Task<IActionResult> GetPendingClubs()
        {
            var clubs = await _context.Clubs
                .Where(c => c.Status == ClubStatus.PendingApproval)
                .Select(c => new
                {
                    id = c.Id,
                    name = c.Name,
                    category = c.Category,
                    image = c.ImageUrl ?? "https://picsum.photos/id/5/200/200",
                    description = c.Description,
                    status = c.Status.ToString(),
                    foundedDate = c.FoundedDate
                })
                .ToListAsync();

            return Ok(clubs);
        }

        // GET: api/clubs/all - Lấy tất cả CLB (Admin)
        [HttpGet("all")]
        public async Task<IActionResult> GetAllClubs()
        {
            var clubs = await _context.Clubs
                .Select(c => new
                {
                    id = c.Id,
                    name = c.Name,
                    category = c.Category,
                    members = c.StudentClubs.Count(sc => sc.Status == MembershipStatus.Active),
                    image = c.ImageUrl ?? "https://picsum.photos/id/5/200/200",
                    description = c.Description,
                    status = c.Status.ToString(),
                    foundedDate = c.FoundedDate
                })
                .ToListAsync();

            return Ok(clubs);
        }

        // POST: api/clubs/propose - Đề xuất thành lập CLB
        [HttpPost("propose")]
        public async Task<IActionResult> ProposeClub([FromBody] ClubCreateUpdateDto clubDto)
        {
            var club = new Domain.Entities.Club
            {
                Name = clubDto.Name,
                Category = clubDto.Category ?? "General",
                ImageUrl = clubDto.ImageUrl ?? "https://picsum.photos/id/5/200/200",
                Description = clubDto.Description ?? "",
                MembersCount = 0,
                Status = ClubStatus.PendingApproval,
                FoundedDate = DateTime.UtcNow
            };

            _context.Clubs.Add(club);
            await _context.SaveChangesAsync();

            return Ok(new { id = club.Id, message = "Club proposal submitted for approval." });
        }

        // PUT: api/clubs/{id}/approve - Admin duyệt CLB
        [HttpPut("{id}/approve")]
        public async Task<IActionResult> ApproveClub(int id)
        {
            var club = await _context.Clubs.FindAsync(id);
            if (club == null) return NotFound();

            if (club.Status != ClubStatus.PendingApproval)
                return BadRequest("Club is not in PendingApproval status.");

            club.Status = ClubStatus.Active;
            club.FoundedDate = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Club approved and now active." });
        }

        // PUT: api/clubs/{id}/deactivate - Đóng CLB
        [HttpPut("{id}/deactivate")]
        public async Task<IActionResult> DeactivateClub(int id)
        {
            var club = await _context.Clubs.FindAsync(id);
            if (club == null) return NotFound();

            club.Status = ClubStatus.Inactive;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Club deactivated." });
        }

        // POST: api/clubs - Tạo CLB (Admin - tạo trực tiếp Active)
        [HttpPost]
        public async Task<IActionResult> CreateClub([FromBody] ClubCreateUpdateDto clubDto)
        {
            var club = new Domain.Entities.Club
            {
                Name = clubDto.Name,
                Category = clubDto.Category ?? "General",
                ImageUrl = clubDto.ImageUrl ?? "https://picsum.photos/id/5/200/200",
                Description = clubDto.Description ?? "",
                MembersCount = 0,
                Status = ClubStatus.Active,
                FoundedDate = DateTime.UtcNow
            };

            _context.Clubs.Add(club);
            await _context.SaveChangesAsync();

            return Ok(new { id = club.Id });
        }

        // PUT: api/clubs/{id} - Cập nhật CLB
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateClub(int id, [FromBody] ClubCreateUpdateDto clubDto)
        {
            var club = await _context.Clubs.FindAsync(id);
            if (club == null) return NotFound();

            club.Name = clubDto.Name;
            club.Category = clubDto.Category ?? "General";
            club.ImageUrl = clubDto.ImageUrl ?? "https://picsum.photos/id/5/200/200";
            club.Description = clubDto.Description ?? "";

            await _context.SaveChangesAsync();
            return Ok();
        }

        // DELETE: api/clubs/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteClub(int id)
        {
            var club = await _context.Clubs.FindAsync(id);
            if (club == null) return NotFound();

            _context.Clubs.Remove(club);
            await _context.SaveChangesAsync();
            return Ok();
        }

        // ==================== MEMBER MANAGEMENT ====================

        // POST: api/clubs/{id}/join?studentId=X - Học sinh xin gia nhập CLB
        [HttpPost("{id}/join")]
        public async Task<IActionResult> JoinClub(int id, [FromQuery] int studentId)
        {
            var club = await _context.Clubs.FindAsync(id);
            if (club == null) return NotFound("Club not found.");

            if (club.Status != ClubStatus.Active)
                return BadRequest("Club is not active.");

            var student = await _context.Students.FindAsync(studentId);
            if (student == null) return NotFound("Student not found.");

            // Kiểm tra đã là thành viên chưa
            var existing = await _context.StudentClubs
                .FirstOrDefaultAsync(sc => sc.StudentId == studentId && sc.ClubId == id);

            if (existing != null)
            {
                if (existing.Status == MembershipStatus.Active)
                    return BadRequest("Student is already an active member.");
                if (existing.Status == MembershipStatus.Pending)
                    return BadRequest("Student already has a pending application.");

                // Nếu Inactive, cho phép join lại
                existing.Status = MembershipStatus.Pending;
                existing.LeftDate = null;
                existing.JoinDate = DateTime.UtcNow;
            }
            else
            {
                var studentClub = new Domain.Entities.StudentClub
                {
                    StudentId = studentId,
                    ClubId = id,
                    ClubRole = ClubRole.Member,
                    Status = MembershipStatus.Pending,
                    JoinDate = DateTime.UtcNow
                };
                _context.StudentClubs.Add(studentClub);
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Join request submitted." });
        }

        // GET: api/clubs/{id}/members - Lấy danh sách thành viên
        [HttpGet("{id}/members")]
        public async Task<IActionResult> GetClubMembers(int id)
        {
            var club = await _context.Clubs.FindAsync(id);
            if (club == null) return NotFound();

            var members = await _context.StudentClubs
                .Where(sc => sc.ClubId == id)
                .Include(sc => sc.Student)
                .Select(sc => new ClubMemberDto
                {
                    StudentId = sc.StudentId,
                    FullName = sc.Student.FullName,
                    RollNumber = sc.Student.RollNumber,
                    AvatarUrl = sc.Student.AvatarUrl,
                    ClubRole = sc.ClubRole.ToString(),
                    Status = sc.Status.ToString(),
                    JoinDate = sc.JoinDate,
                    LeftDate = sc.LeftDate
                })
                .ToListAsync();

            return Ok(members);
        }

        // GET: api/clubs/{id}/members/pending - Danh sách đơn xin chờ duyệt
        [HttpGet("{id}/members/pending")]
        public async Task<IActionResult> GetPendingMembers(int id)
        {
            var members = await _context.StudentClubs
                .Where(sc => sc.ClubId == id && sc.Status == MembershipStatus.Pending)
                .Include(sc => sc.Student)
                .Select(sc => new ClubMemberDto
                {
                    StudentId = sc.StudentId,
                    FullName = sc.Student.FullName,
                    RollNumber = sc.Student.RollNumber,
                    AvatarUrl = sc.Student.AvatarUrl,
                    ClubRole = sc.ClubRole.ToString(),
                    Status = sc.Status.ToString(),
                    JoinDate = sc.JoinDate
                })
                .ToListAsync();

            return Ok(members);
        }

        // PUT: api/clubs/{id}/members/{studentId}/approve - Duyệt đơn xin gia nhập
        [HttpPut("{id}/members/{studentId}/approve")]
        public async Task<IActionResult> ApproveMember(int id, int studentId)
        {
            var membership = await _context.StudentClubs
                .FirstOrDefaultAsync(sc => sc.ClubId == id && sc.StudentId == studentId);

            if (membership == null) return NotFound("Membership not found.");

            if (membership.Status != MembershipStatus.Pending)
                return BadRequest("Membership is not in Pending status.");

            membership.Status = MembershipStatus.Active;

            // Cập nhật MembersCount
            var club = await _context.Clubs.FindAsync(id);
            if (club != null)
            {
                club.MembersCount = await _context.StudentClubs
                    .CountAsync(sc => sc.ClubId == id && sc.Status == MembershipStatus.Active) + 1;
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Member approved." });
        }

        // PUT: api/clubs/{id}/members/{studentId}/reject - Từ chối đơn xin
        [HttpPut("{id}/members/{studentId}/reject")]
        public async Task<IActionResult> RejectMember(int id, int studentId)
        {
            var membership = await _context.StudentClubs
                .FirstOrDefaultAsync(sc => sc.ClubId == id && sc.StudentId == studentId);

            if (membership == null) return NotFound("Membership not found.");

            _context.StudentClubs.Remove(membership);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Member rejected." });
        }

        // PUT: api/clubs/{id}/members/{studentId}/role - Bổ nhiệm chức vụ
        [HttpPut("{id}/members/{studentId}/role")]
        public async Task<IActionResult> AssignRole(int id, int studentId, [FromBody] ClubRoleUpdateDto dto)
        {
            var membership = await _context.StudentClubs
                .FirstOrDefaultAsync(sc => sc.ClubId == id && sc.StudentId == studentId);

            if (membership == null) return NotFound("Membership not found.");

            if (membership.Status != MembershipStatus.Active)
                return BadRequest("Member must be active to assign a role.");

            if (!Enum.TryParse<ClubRole>(dto.Role, true, out var role))
                return BadRequest($"Invalid role: {dto.Role}. Valid roles: Member, President, VicePresident, Secretary, Treasurer.");

            // Nếu assign President, bỏ President cũ
            if (role == ClubRole.President)
            {
                var currentPresident = await _context.StudentClubs
                    .FirstOrDefaultAsync(sc => sc.ClubId == id && sc.ClubRole == ClubRole.President && sc.Status == MembershipStatus.Active);

                if (currentPresident != null && currentPresident.StudentId != studentId)
                {
                    currentPresident.ClubRole = ClubRole.Member;
                }
            }

            membership.ClubRole = role;
            await _context.SaveChangesAsync();

            return Ok(new { message = $"Role updated to {role}." });
        }

        // PUT: api/clubs/{id}/members/{studentId}/leave - Rời CLB
        [HttpPut("{id}/members/{studentId}/leave")]
        public async Task<IActionResult> LeaveClub(int id, int studentId)
        {
            var membership = await _context.StudentClubs
                .FirstOrDefaultAsync(sc => sc.ClubId == id && sc.StudentId == studentId);

            if (membership == null) return NotFound("Membership not found.");

            membership.Status = MembershipStatus.Inactive;
            membership.LeftDate = DateTime.UtcNow;

            // Cập nhật MembersCount
            var club = await _context.Clubs.FindAsync(id);
            if (club != null)
            {
                club.MembersCount = await _context.StudentClubs
                    .CountAsync(sc => sc.ClubId == id && sc.Status == MembershipStatus.Active) - 1;
                if (club.MembersCount < 0) club.MembersCount = 0;
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Student left the club." });
        }

        // GET: api/clubs/{id}/my-status?studentId=X - Kiểm tra trạng thái thành viên
        [HttpGet("{id}/my-status")]
        public async Task<IActionResult> GetMyStatus(int id, [FromQuery] int studentId)
        {
            var membership = await _context.StudentClubs
                .FirstOrDefaultAsync(sc => sc.ClubId == id && sc.StudentId == studentId);

            if (membership == null)
                return Ok(new { isMember = false, status = "None", role = "None" });

            return Ok(new
            {
                isMember = membership.Status == MembershipStatus.Active,
                status = membership.Status.ToString(),
                role = membership.ClubRole.ToString()
            });
        }
    }
}
