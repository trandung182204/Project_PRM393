using Application.DTOs.Semester;
using Domain.Entities;
using Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FSchool.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SemestersController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public SemestersController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Semester>>> GetSemesters()
        {
            return await _context.Semesters.ToListAsync();
        }

        [HttpGet("filters")]
        public async Task<ActionResult<FilterOptionsDto>> GetFilterOptions()
        {
            var semesters = await _context.Semesters.ToListAsync();
            
            var options = new FilterOptionsDto
            {
                // Extract unique years from semester names (e.g., "Fall 2026" -> "2026")
                Years = semesters
                    .Select(s => {
                        var parts = s.Name.Split(' ');
                        return parts.Length > 1 ? parts.Last() : s.StartDate.Year.ToString();
                    })
                    .Distinct()
                    .OrderByDescending(y => y)
                    .ToList(),
                
                // Extract unique semester names (e.g., "Fall 2026" -> "Fall")
                Semesters = semesters
                    .Select(s => s.Name.Split(' ').First())
                    .Distinct()
                    .ToList()
            };

            return Ok(options);
        }
    }
}
