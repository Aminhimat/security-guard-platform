namespace SecurityGuardPlatform.Application.DTOs.Incident;

public class IncidentReportDto
{
    public Guid Id { get; set; }
    public Guid GuardId { get; set; }
    public string GuardName { get; set; } = string.Empty;
    public Guid SiteId { get; set; }
    public string SiteName { get; set; } = string.Empty;
    public Guid? ShiftId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string IncidentType { get; set; } = string.Empty;
    public string Severity { get; set; } = string.Empty;
    public DateTime IncidentDateTime { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? ActionsTaken { get; set; }
    public bool EmergencyServicesContacted { get; set; }
    public string? EmergencyServiceDetails { get; set; }
    public bool FollowUpRequired { get; set; }
    public string? FollowUpNotes { get; set; }
    public List<IncidentMediaDto> Media { get; set; } = new();
    public DateTime CreatedAt { get; set; }
}

public class CreateIncidentReportDto
{
    public Guid SiteId { get; set; }
    public Guid? ShiftId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string IncidentType { get; set; } = string.Empty;
    public string Severity { get; set; } = "Medium";
    public DateTime IncidentDateTime { get; set; } = DateTime.UtcNow;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string? ActionsTaken { get; set; }
    public bool EmergencyServicesContacted { get; set; }
    public string? EmergencyServiceDetails { get; set; }
}

public class IncidentMediaDto
{
    public Guid Id { get; set; }
    public string MediaType { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public long FileSize { get; set; }
    public string? MimeType { get; set; }
    public int? DurationSeconds { get; set; }
    public string? Description { get; set; }
    public DateTime? CapturedAt { get; set; }
}
