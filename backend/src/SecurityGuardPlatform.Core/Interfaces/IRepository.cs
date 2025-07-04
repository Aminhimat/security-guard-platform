using SecurityGuardPlatform.Core.Entities;

namespace SecurityGuardPlatform.Core.Interfaces;

public interface IRepository<T> where T : BaseEntity
{
    Task<T?> GetByIdAsync(Guid id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> AddAsync(T entity);
    Task<T> UpdateAsync(T entity);
    Task DeleteAsync(Guid id);
    Task<bool> ExistsAsync(Guid id);
}

public interface ITenantRepository<T> : IRepository<T> where T : TenantBaseEntity
{
    Task<T?> GetByIdAsync(Guid id, Guid tenantId);
    Task<IEnumerable<T>> GetAllAsync(Guid tenantId);
    Task<IEnumerable<T>> GetPagedAsync(Guid tenantId, int page, int pageSize);
    Task<int> CountAsync(Guid tenantId);
}
