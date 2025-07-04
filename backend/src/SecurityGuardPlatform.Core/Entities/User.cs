using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Identity;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// User entity extending IdentityUser for authentication
/// </summary>
public class User : IdentityUser<Guid>
{
    [Required]
    [MaxLength(50)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(50)]
    public string LastName { get; set; } = string.Empty;
    
    /// <summary>
    /// The tenant this user belongs to (null for platform owners)
    /// </summary>
    public Guid? TenantId { get; set; }
    
    /// <summary>
    /// User role: PlatformOwner, CompanyAdmin, Supervisor, Guard
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string Role { get; set; } = string.Empty;
    
    /// <summary>
    /// Employee ID within the company
    /// </summary>
    [MaxLength(20)]
    public string? EmployeeId { get; set; }
    
    /// <summary>
    /// Whether the user is active
    /// </summary>
    public bool IsActive { get; set; } = true;
    
    /// <summary>
    /// Last known location (for guards)
    /// </summary>
    public double? LastLatitude { get; set; }
    public double? LastLongitude { get; set; }
    public DateTime? LastLocationUpdate { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation properties
    public virtual Tenant? Tenant { get; set; }
    public virtual ICollection<Shift> Shifts { get; set; } = new List<Shift>();
    public virtual ICollection<IncidentReport> IncidentReports { get; set; } = new List<IncidentReport>();
    public virtual ICollection<CheckIn> CheckIns { get; set; } = new List<CheckIn>();
}
