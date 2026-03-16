using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Data.Seeders
{
    public interface ISeeder
    {
        int Order { get; }
        Task SeedAsync();
    }
}
