using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Tracks guard's location during shifts for GPS monitoring
/// </summary>
public class LocationLog : TenantBaseEntity
{
    /// <summary>
    /// The guard being tracked
    /// </summary>
    [Required]
    public Guid GuardId { get; set; }
    
    /// <summary>
    /// The shift this location belongs to
    /// </summary>
    [Required]
    public Guid ShiftId { get; set; }
    
    /// <summary>
    /// Timestamp of location record
    /// </summary>
    [Required]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// Location coordinates
    /// </summary>
    [Required]
    public double Latitude { get; set; }
    
    [Required]
    public double Longitude { get; set; }
    
    /// <summary>
    /// Location accuracy in meters
    /// </summary>
    public double? Accuracy { get; set; }
    
    /// <summary>
    /// Speed in km/h (if available)
    /// </summary>
    public double? Speed { get; set; }
    
    /// <summary>
    /// Battery level of the device (0-100)
    /// </summary>
    public int? BatteryLevel { get; set; }
    
    /// <summary>
    /// Whether this location was recorded while guard was within site geofence
    /// </summary>
    public bool IsWithinSiteGeofence { get; set; } = false;
    
    // Navigation properties
    public virtual User Guard { get; set; } = null!;
    public virtual Shift Shift { get; set; } = null!;
}
