using Microsoft.AspNetCore.Mvc;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace StudentHub.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NewsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public NewsController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetNews()
        {
            var news = await _context.Events
                .Where(e => e.IsNews)
                .Select(e => new
                {
                    title = e.Title,
                    content = e.Description,
                    image = e.ImageUrl ?? "https://www.foxroad.co.nz/cdn/shop/articles/flowers-nature-pictures_900x.jpg?v=1725492833"
                })
                .ToListAsync();

            return Ok(news);
        }
    }
}
