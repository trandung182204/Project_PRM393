using System;
using System.Collections.Generic;

namespace Application.DTOs.Schedule
{
    public class ScheduleCreateUpdateDto
    {
        public DateTime Date { get; set; }
        public int SlotId { get; set; }
        public int SubjectId { get; set; }
        public int RoomId { get; set; }
        public int ClassId { get; set; }
        public int StaffId { get; set; }
    }

    public class BatchScheduleDto
    {
        public int ClassId { get; set; }
        public int SubjectId { get; set; }
        public int RoomId { get; set; }
        public int StaffId { get; set; }
        public List<int> SlotIds { get; set; }
        public List<int> DaysOfWeek { get; set; } // 0=Sunday, 1=Monday...
        public DateTime StartDate { get; set; }
        public int TotalSessions { get; set; }
        public bool SkipHolidays { get; set; } = true;
        public bool SkipSundays { get; set; } = true;
    }
}
