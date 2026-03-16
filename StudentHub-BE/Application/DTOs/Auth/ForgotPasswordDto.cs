using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Auth
{
    public class SendOtpRequest { public string PhoneNumber { get; set; } = null!; }
    public class VerifyOtpRequest
    {
        public string PhoneNumber { get; set; } = null!;
        public string OtpCode { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
    }
}
