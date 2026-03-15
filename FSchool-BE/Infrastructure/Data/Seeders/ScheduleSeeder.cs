using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders;

public class ScheduleSeeder : ISeeder
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ScheduleSeeder> _logger;

    public int Order => 3; // Depends on Slot, Subject, Room, SchoolClass, Staff

    public ScheduleSeeder(
        ApplicationDbContext context,
        ILogger<ScheduleSeeder> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task SeedAsync()
    {
        if (await _context.Schedules.AnyAsync())
        {
            _logger.LogInformation("Schedules already seeded, skipping...");
            return;
        }

        var slots = await _context.Slots.ToListAsync();
        var subjects = await _context.Subjects.ToListAsync();
        var rooms = await _context.Rooms.ToListAsync();
        var classes = await _context.Classes.ToListAsync();
        var staffs = await _context.Staffs.ToListAsync();

        if (!slots.Any() || !subjects.Any() || !rooms.Any() || !classes.Any() || !staffs.Any())
        {
            _logger.LogWarning("Missing dependencies for Schedule seeding. Skipping...");
            return;
        }

        // Get class 1 and class 2
        var class1 = classes.FirstOrDefault();
        var class2 = classes.Count > 1 ? classes[1] : class1;
        var staff1 = staffs.FirstOrDefault();
        var staff2 = staffs.Count > 1 ? staffs[1] : staff1;

        // Monday of current week
        var today = DateTime.Now.Date;
        var monday = today.AddDays(-(int)today.DayOfWeek + (int)DayOfWeek.Monday);

        var schedules = new List<Schedule>
        {
            // === Class 1 schedules ===
            new Schedule { Date = monday, SlotId = slots[0].Id, SubjectId = subjects[0].Id, RoomId = rooms[0].Id, ClassId = class1!.Id, StaffId = staff1!.Id },
            new Schedule { Date = monday.AddDays(1), SlotId = slots[0].Id, SubjectId = subjects[0].Id, RoomId = rooms[0].Id, ClassId = class1.Id, StaffId = staff1.Id },

            // === Class 2 schedules (Mon - Fri) ===
            // Monday: Slot 1 - SWE201, Slot 2 - DBI202
            new Schedule { Date = monday, SlotId = slots[0].Id, SubjectId = subjects.Count > 1 ? subjects[1].Id : subjects[0].Id, RoomId = rooms.Count > 1 ? rooms[1].Id : rooms[0].Id, ClassId = class2!.Id, StaffId = staff2!.Id },
            new Schedule { Date = monday, SlotId = slots.Count > 1 ? slots[1].Id : slots[0].Id, SubjectId = subjects.Count > 2 ? subjects[2].Id : subjects[0].Id, RoomId = rooms.Count > 2 ? rooms[2].Id : rooms[0].Id, ClassId = class2.Id, StaffId = staff1!.Id },

            // Tuesday: Slot 1 - MAS291, Slot 3 - PRN211
            new Schedule { Date = monday.AddDays(1), SlotId = slots[0].Id, SubjectId = subjects.Count > 3 ? subjects[3].Id : subjects[0].Id, RoomId = rooms[0].Id, ClassId = class2.Id, StaffId = staff2.Id },
            new Schedule { Date = monday.AddDays(1), SlotId = slots.Count > 2 ? slots[2].Id : slots[0].Id, SubjectId = subjects[0].Id, RoomId = rooms.Count > 1 ? rooms[1].Id : rooms[0].Id, ClassId = class2.Id, StaffId = staff1.Id },

            // Wednesday: Slot 2 - SWT301, Slot 4 - SWE201
            new Schedule { Date = monday.AddDays(2), SlotId = slots.Count > 1 ? slots[1].Id : slots[0].Id, SubjectId = subjects.Count > 4 ? subjects[4].Id : subjects[0].Id, RoomId = rooms.Count > 2 ? rooms[2].Id : rooms[0].Id, ClassId = class2.Id, StaffId = staff2.Id },
            new Schedule { Date = monday.AddDays(2), SlotId = slots.Count > 3 ? slots[3].Id : slots[0].Id, SubjectId = subjects.Count > 1 ? subjects[1].Id : subjects[0].Id, RoomId = rooms[0].Id, ClassId = class2.Id, StaffId = staff1.Id },

            // Thursday: Slot 1 - DBI202
            new Schedule { Date = monday.AddDays(3), SlotId = slots[0].Id, SubjectId = subjects.Count > 2 ? subjects[2].Id : subjects[0].Id, RoomId = rooms.Count > 3 ? rooms[3].Id : rooms[0].Id, ClassId = class2.Id, StaffId = staff2.Id },

            // Friday: Slot 3 - MAS291, Slot 4 - SWT301
            new Schedule { Date = monday.AddDays(4), SlotId = slots.Count > 2 ? slots[2].Id : slots[0].Id, SubjectId = subjects.Count > 3 ? subjects[3].Id : subjects[0].Id, RoomId = rooms.Count > 1 ? rooms[1].Id : rooms[0].Id, ClassId = class2.Id, StaffId = staff1.Id },
            new Schedule { Date = monday.AddDays(4), SlotId = slots.Count > 3 ? slots[3].Id : slots[0].Id, SubjectId = subjects.Count > 4 ? subjects[4].Id : subjects[0].Id, RoomId = rooms.Count > 2 ? rooms[2].Id : rooms[0].Id, ClassId = class2.Id, StaffId = staff2.Id },
        };

        await _context.Schedules.AddRangeAsync(schedules);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} schedules", schedules.Count);
    }
}
