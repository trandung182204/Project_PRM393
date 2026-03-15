namespace Application.DTOs.Admin;

public class CreateAccountDto
{
    public string PhoneNumber { get; set; }
    public string Email { get; set; }
    public string Password { get; set; }
    public string FullName { get; set; }
    public string Role { get; set; } // Student or Staff
    
    // For Student
    public string? RollNumber { get; set; }
    
    // For Staff
    public string? EmployeeId { get; set; }
    public string? Department { get; set; }
}
