using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Auth
{
    public class AuthResponseDto
    {
        public int Id { get; set; }

        public string? RollNumber { get; set; }
        public string? EmployeeId { get; set; }
        public string? Department { get; set; }

        public string FullName { get; set; }

        public string AccessToken { get; set; } = null!;
        public string Role { get; set; } = null!;
        public int? ClassId { get; set; }
        public int? StudentId { get; set; }
        public int? StaffId { get; set; }
    }
}

