using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Represents a work shift for a guard
/// </summary>
public class Shift : TenantBaseEntity
{
    /// <summary>
    /// The guard assigned to this shift
    /// </summary>
    [Required]
    public Guid GuardId { get; set; }
    
    /// <summary>
    /// The site for this shift
    /// </summary>
    [Required]
    public Guid SiteId { get; set; }
    
    /// <summary>
    /// Scheduled start time
    /// </summary>
    [Required]
    public DateTime ScheduledStartTime { get; set; }
    
    /// <summary>
    /// Scheduled end time
    /// </summary>
    [Required]
    public DateTime ScheduledEndTime { get; set; }
    
    /// <summary>
    /// Actual start time (when guard clocks in)
    /// </summary>
    public DateTime? ActualStartTime { get; set; }
    
    /// <summary>
    /// Actual end time (when guard clocks out)
    /// </summary>
    public DateTime? ActualEndTime { get; set; }
    
    /// <summary>
    /// Shift status: Scheduled, Active, Completed, Cancelled, NoShow
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string Status { get; set; } = "Scheduled";
    
    /// <summary>
    /// Notes about the shift
    /// </summary>
    [MaxLength(1000)]
    public string? Notes { get; set; }
    
    /// <summary>
    /// Break time in minutes
    /// </summary>
    public int? BreakTimeMinutes { get; set; }
    
    // Navigation properties
    public virtual User Guard { get; set; } = null!;
    public virtual Site Site { get; set; } = null!;
    public virtual ICollection<CheckIn> CheckIns { get; set; } = new List<CheckIn>();
    public virtual ICollection<LocationLog> LocationLogs { get; set; } = new List<LocationLog>();
}
