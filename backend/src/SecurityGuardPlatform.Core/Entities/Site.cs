using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Represents a site/location that needs security coverage
/// </summary>
public class Site : TenantBaseEntity
{
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(200)]
    public string Address { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Description { get; set; }
    
    /// <summary>
    /// Site coordinates
    /// </summary>
    [Required]
    public double Latitude { get; set; }
    
    [Required]
    public double Longitude { get; set; }
    
    /// <summary>
    /// Geofence radius in meters
    /// </summary>
    public int GeofenceRadius { get; set; } = 100;
    
    /// <summary>
    /// Client contact information
    /// </summary>
    [MaxLength(100)]
    public string? ClientName { get; set; }
    
    [EmailAddress]
    [MaxLength(100)]
    public string? ClientEmail { get; set; }
    
    [Phone]
    [MaxLength(20)]
    public string? ClientPhone { get; set; }
    
    /// <summary>
    /// Special instructions for guards
    /// </summary>
    [MaxLength(1000)]
    public string? Instructions { get; set; }
    
    /// <summary>
    /// Whether the site is currently active
    /// </summary>
    public bool IsActive { get; set; } = true;
    
    // Navigation properties
    public virtual ICollection<Checkpoint> Checkpoints { get; set; } = new List<Checkpoint>();
    public virtual ICollection<Shift> Shifts { get; set; } = new List<Shift>();
    public virtual ICollection<IncidentReport> IncidentReports { get; set; } = new List<IncidentReport>();
}
