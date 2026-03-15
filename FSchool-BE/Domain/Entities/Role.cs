using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class Role
    {
        [Key]
        public int RoleId { get; set; }

        [Required, MaxLength(255)]
        public string RoleName { get; set; }


        public ICollection<Account> Accounts { get; set; }
    }
}
