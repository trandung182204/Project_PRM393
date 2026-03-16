using Application.Interfaces.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories
{
    public class AccountRepository : IAccountRepository
    {
        private readonly ApplicationDbContext _context;

        public AccountRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public Task<Account?> GetByPhoneAsync(string phoneNumber)
        {
            return _context.Accounts.FirstOrDefaultAsync(x => x.PhoneNumber == phoneNumber);
        }

        public async Task<Account?> GetByPhoneNumberAsync(string phonenumber)
        {
            return await _context.Accounts
                .Include(x => x.Roles)
                .Include(x => x.Student)
                    .ThenInclude(s => s.SchoolClasses)
                .Include(x => x.Staff)
                .FirstOrDefaultAsync(x => x.PhoneNumber == phonenumber);
        }

        public async Task<Account?> GetByEmailAsync(string email)
        {
            return await _context.Accounts
                .Include(x => x.Roles)
                .Include(x => x.Student)
                    .ThenInclude(s => s.SchoolClasses)
                .Include(x => x.Staff)
                .FirstOrDefaultAsync(x => x.Email == email);
        }

        public async Task UpdateAsync(Account account)
        {
            _context.Accounts.Update(account);

            await _context.SaveChangesAsync();
        }

        public async Task<Account?> GetByIdAsync(int id)
        {
            return await _context.Accounts.FindAsync(id);
        }

        public async Task AddAsync(Account account)
        {
            await _context.Accounts.AddAsync(account);
            await _context.SaveChangesAsync();
        }
    }
}
