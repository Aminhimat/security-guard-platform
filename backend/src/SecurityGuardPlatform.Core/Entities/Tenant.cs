using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Represents a security company (tenant) in the multi-tenant system
/// </summary>
public class Tenant : BaseEntity
{
    [Required]
    [MaxLength(100)]
    public string CompanyName { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]
    public string Address { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    [MaxLength(100)]
    public string ContactEmail { get; set; } = string.Empty;
    
    [Required]
    [Phone]
    [MaxLength(20)]
    public string ContactPhone { get; set; } = string.Empty;
    
    /// <summary>
    /// Maximum number of user accounts this tenant can have
    /// </summary>
    public int MaxUserAccounts { get; set; } = 10;
    
    /// <summary>
    /// Current subscription plan
    /// </summary>
    [MaxLength(50)]
    public string SubscriptionPlan { get; set; } = "Basic";
    
    /// <summary>
    /// Whether the tenant is active
    /// </summary>
    public bool IsActive { get; set; } = true;
    
    /// <summary>
    /// Subscription expiry date
    /// </summary>
    public DateTime? SubscriptionExpiryDate { get; set; }
    
    // Navigation properties
    public virtual ICollection<User> Users { get; set; } = new List<User>();
    public virtual ICollection<Site> Sites { get; set; } = new List<Site>();
    public virtual ICollection<Shift> Shifts { get; set; } = new List<Shift>();
    public virtual ICollection<IncidentReport> IncidentReports { get; set; } = new List<IncidentReport>();
}
