using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Base entity for multi-tenant data with tenant isolation
/// </summary>
public abstract class TenantBaseEntity : BaseEntity
{
    [Required]
    public Guid TenantId { get; set; }
    
    // Navigation property to the tenant (security company)
    public virtual Tenant Tenant { get; set; } = null!;
}
