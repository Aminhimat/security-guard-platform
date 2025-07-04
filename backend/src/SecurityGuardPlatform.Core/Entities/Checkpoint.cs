using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Represents a checkpoint within a site (QR/NFC scan points)
/// </summary>
public class Checkpoint : TenantBaseEntity
{
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Description { get; set; }
    
    /// <summary>
    /// The site this checkpoint belongs to
    /// </summary>
    [Required]
    public Guid SiteId { get; set; }
    
    /// <summary>
    /// Checkpoint coordinates
    /// </summary>
    [Required]
    public double Latitude { get; set; }
    
    [Required]
    public double Longitude { get; set; }
    
    /// <summary>
    /// QR code content or NFC tag ID
    /// </summary>
    [Required]
    [MaxLength(200)]
    public string CheckpointCode { get; set; } = string.Empty;
    
    /// <summary>
    /// Type of checkpoint: QR, NFC, Manual
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string CheckpointType { get; set; } = "QR";
    
    /// <summary>
    /// Expected scan interval in minutes
    /// </summary>
    public int? ExpectedIntervalMinutes { get; set; }
    
    /// <summary>
    /// Whether this checkpoint is mandatory to scan
    /// </summary>
    public bool IsMandatory { get; set; } = true;
    
    /// <summary>
    /// Special instructions for this checkpoint
    /// </summary>
    [MaxLength(500)]
    public string? Instructions { get; set; }
    
    /// <summary>
    /// Whether the checkpoint is active
    /// </summary>
    public bool IsActive { get; set; } = true;
    
    // Navigation properties
    public virtual Site Site { get; set; } = null!;
    public virtual ICollection<CheckIn> CheckIns { get; set; } = new List<CheckIn>();
}
