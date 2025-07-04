using System.ComponentModel.DataAnnotations;

namespace SecurityGuardPlatform.Core.Entities;

/// <summary>
/// Represents media files (photos, audio, video) attached to incident reports
/// </summary>
public class IncidentMedia : TenantBaseEntity
{
    /// <summary>
    /// The incident report this media belongs to
    /// </summary>
    [Required]
    public Guid IncidentReportId { get; set; }
    
    /// <summary>
    /// Media type: Photo, Audio, Video
    /// </summary>
    [Required]
    [MaxLength(20)]
    public string MediaType { get; set; } = string.Empty;
    
    /// <summary>
    /// Original filename
    /// </summary>
    [Required]
    [MaxLength(200)]
    public string FileName { get; set; } = string.Empty;
    
    /// <summary>
    /// File path or URL in cloud storage
    /// </summary>
    [Required]
    [MaxLength(500)]
    public string FilePath { get; set; } = string.Empty;
    
    /// <summary>
    /// File size in bytes
    /// </summary>
    public long FileSize { get; set; }
    
    /// <summary>
    /// MIME type of the file
    /// </summary>
    [MaxLength(100)]
    public string? MimeType { get; set; }
    
    /// <summary>
    /// Duration in seconds (for audio/video)
    /// </summary>
    public int? DurationSeconds { get; set; }
    
    /// <summary>
    /// Media description or caption
    /// </summary>
    [MaxLength(500)]
    public string? Description { get; set; }
    
    /// <summary>
    /// Location where media was captured
    /// </summary>
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    
    /// <summary>
    /// When the media was captured
    /// </summary>
    public DateTime? CapturedAt { get; set; }
    
    // Navigation property
    public virtual IncidentReport IncidentReport { get; set; } = null!;
}
