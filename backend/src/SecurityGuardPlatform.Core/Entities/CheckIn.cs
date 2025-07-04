using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Represents a guard's check-in at a checkpoint
/// </summary>
public class CheckIn : TenantBaseEntity
{
    /// <summary>
    /// The guard who performed the check-in
    /// </summary>
    [Required]
    public Guid GuardId { get; set; }
    
    /// <summary>
    /// The shift this check-in belongs to
    /// </summary>
    [Required]
    public Guid ShiftId { get; set; }
    
    /// <summary>
    /// The checkpoint that was scanned (optional for manual check-ins)
    /// </summary>
    public Guid? CheckpointId { get; set; }
    
    /// <summary>
    /// Check-in timestamp
    /// </summary>
    [Required]
    public DateTime CheckInTime { get; set; } = DateTime.UtcNow;
    
    /// <summary>
    /// Check-in type: QR, NFC, Manual, GPS
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string CheckInType { get; set; } = string.Empty;
    
    /// <summary>
    /// Guard's location at check-in
    /// </summary>
    [Required]
    public double Latitude { get; set; }
    
    [Required]
    public double Longitude { get; set; }
    
    /// <summary>
    /// Location accuracy in meters
    /// </summary>
    public double? LocationAccuracy { get; set; }
    
    /// <summary>
    /// Check-in notes or observations
    /// </summary>
    [MaxLength(1000)]
    public string? Notes { get; set; }
    
    /// <summary>
    /// Photo taken at check-in (file path/URL)
    /// </summary>
    [MaxLength(500)]
    public string? PhotoPath { get; set; }
    
    /// <summary>
    /// Whether this was within the expected geofence
    /// </summary>
    public bool IsWithinGeofence { get; set; } = true;
    
    // Navigation properties
    public virtual User Guard { get; set; } = null!;
    public virtual Shift Shift { get; set; } = null!;
    public virtual Checkpoint? Checkpoint { get; set; }
}
