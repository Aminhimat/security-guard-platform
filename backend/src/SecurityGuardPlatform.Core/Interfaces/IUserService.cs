using SecurityGuardPlatform.Core.Entities;

namespace SecurityGuardPlatform.Core.Interfaces;

public interface IUserService
{
    Task<User?> GetUserAsync(Guid userId);
    Task<User?> GetUserByEmailAsync(string email);
    Task<IEnumerable<User>> GetUsersByTenantAsync(Guid tenantId);
    Task<User> CreateUserAsync(User user, string password);
    Task<User> UpdateUserAsync(User user);
    Task DeleteUserAsync(Guid userId);
    Task<bool> ValidatePasswordAsync(User user, string password);
    Task<string> GenerateJwtTokenAsync(User user);
    Task UpdateLocationAsync(Guid userId, double latitude, double longitude);
}
