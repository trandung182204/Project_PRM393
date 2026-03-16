using Domain.Entities;

namespace Application.Interfaces.Repositories
{
    public interface IAccountRepository
    {
        Task<Account?> GetByPhoneNumberAsync(string phoneNumber);
        Task<Account?> GetByPhoneAsync(string phoneNumber);
        Task<Account?> GetByEmailAsync(string email);

        Task UpdateAsync(Account account);

        Task<Account?> GetByIdAsync(int id);
        Task AddAsync(Account account);
    }
}
