namespace SecurityGuardPlatform.Core.Enums;

public enum UserRole
{
    PlatformOwner,
    CompanyAdmin,
    Supervisor,
    Guard
}

public enum ShiftStatus
{
    Scheduled,
    Active,
    Completed,
    Cancelled,
    NoShow
}

public enum CheckInType
{
    QR,
    NFC,
    Manual,
    GPS
}

public enum CheckpointType
{
    QR,
    NFC,
    Manual
}

public enum IncidentType
{
    Security,
    Safety,
    Maintenance,
    Medical,
    Other
}

public enum Severity
{
    Low,
    Medium,
    High,
    Critical
}

public enum IncidentStatus
{
    Open,
    InProgress,
    Resolved,
    Closed
}

public enum MediaType
{
    Photo,
    Audio,
    Video
}

public enum SubscriptionPlan
{
    Basic,
    Professional,
    Enterprise
}
