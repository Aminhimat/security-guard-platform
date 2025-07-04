using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Represents an incident report submitted by a guard
/// </summary>
public class IncidentReport : TenantBaseEntity
{
    /// <summary>
    /// The guard who reported the incident
    /// </summary>
    [Required]
    public Guid GuardId { get; set; }
    
    /// <summary>
    /// The site where the incident occurred
    /// </summary>
    [Required]
    public Guid SiteId { get; set; }
    
    /// <summary>
    /// The shift during which the incident occurred
    /// </summary>
    public Guid? ShiftId { get; set; }
    
    /// <summary>
    /// Incident title/summary
    /// </summary>
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;
    
    /// <summary>
    /// Detailed description of the incident
    /// </summary>
    [Required]
    [MaxLength(2000)]
    public string Description { get; set; } = string.Empty;
    
    /// <summary>
    /// Incident type: Security, Safety, Maintenance, Medical, Other
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string IncidentType { get; set; } = string.Empty;
    
    /// <summary>
    /// Severity level: Low, Medium, High, Critical
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string Severity { get; set; } = "Medium";
    
    /// <summary>
    /// When the incident occurred
    /// </summary>
    [Required]
    public DateTime IncidentDateTime { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// Location where the incident occurred
    /// </summary>
    [Required]
    public double Latitude { get; set; }
    
    [Required]
    public double Longitude { get; set; }
    
    /// <summary>
    /// Status: Open, InProgress, Resolved, Closed
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string Status { get; set; } = "Open";
    
    /// <summary>
    /// Actions taken by the guard
    /// </summary>
    [MaxLength(1000)]
    public string? ActionsTaken { get; set; }
    
    /// <summary>
    /// Whether emergency services were contacted
    /// </summary>
    public bool EmergencyServicesContacted { get; set; } = false;
    
    /// <summary>
    /// Emergency service details (police report number, etc.)
    /// </summary>
    [MaxLength(200)]
    public string? EmergencyServiceDetails { get; set; }
    
    /// <summary>
    /// Follow-up required
    /// </summary>
    public bool FollowUpRequired { get; set; } = false;
    
    /// <summary>
    /// Follow-up notes
    /// </summary>
    [MaxLength(1000)]
    public string? FollowUpNotes { get; set; }
    
    // Navigation properties
    public virtual User Guard { get; set; } = null!;
    public virtual Site Site { get; set; } = null!;
    public virtual Shift? Shift { get; set; }
    public virtual ICollection<IncidentMedia> IncidentMedia { get; set; } = new List<IncidentMedia>();
}
