using Microsoft.EntityFrameworkCore;
using SecurityGuardPlatform.Core.Entities;
using SecurityGuardPlatform.Core.Interfaces;
using SecurityGuardPlatform.Infrastructure.Data;

namespace SecurityGuardPlatform.Infrastructure.Repositories;

public class TenantRepository<T> : Repository<T>, ITenantRepository<T> where T : TenantBaseEntity
{
    public TenantRepository(ApplicationDbContext context) : base(context)
    {
    }

    public virtual async Task<T?> GetByIdAsync(Guid id, Guid tenantId)
    {
        return await _dbSet.FirstOrDefaultAsync(e => e.Id == id && e.TenantId == tenantId);
    }

    public virtual async Task<IEnumerable<T>> GetAllAsync(Guid tenantId)
    {
        return await _dbSet.Where(e => e.TenantId == tenantId).ToListAsync();
    }

    public virtual async Task<IEnumerable<T>> GetPagedAsync(Guid tenantId, int page, int pageSize)
    {
        return await _dbSet
            .Where(e => e.TenantId == tenantId)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public virtual async Task<int> CountAsync(Guid tenantId)
    {
        return await _dbSet.CountAsync(e => e.TenantId == tenantId);
    }
}
