using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Domain.Entities;
using Infrastructure.Data;

namespace StudentHub.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SlotsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        public SlotsController(ApplicationDbContext context) => _context = context;

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Slot>>> GetSlots() => await _context.Slots.OrderBy(s => s.StartTime).ToListAsync();
    }
}
