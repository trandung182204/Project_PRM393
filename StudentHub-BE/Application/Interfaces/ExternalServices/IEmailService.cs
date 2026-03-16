using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.ExternalServices
{
    public interface IEmailService
    {
        Task<bool> SendEmailAsync(string email, string message);
    }
}
