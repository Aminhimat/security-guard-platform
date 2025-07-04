using SecurityGuardPlatform.Core.Entities;

namespace SecurityGuardPlatform.Core.Interfaces;

public interface ITenantService
{
    Task<Tenant?> GetTenantAsync(Guid tenantId);
    Task<IEnumerable<Tenant>> GetAllTenantsAsync();
    Task<Tenant> CreateTenantAsync(Tenant tenant);
    Task<Tenant> UpdateTenantAsync(Tenant tenant);
    Task DeleteTenantAsync(Guid tenantId);
    Task<bool> CanAddUserAsync(Guid tenantId);
    Task<int> GetUserCountAsync(Guid tenantId);
    Task<bool> UpdateUserLimitAsync(Guid tenantId, int newLimit);
}
