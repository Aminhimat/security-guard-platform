namespace SecurityGuardPlatform.Core.Constants;

public static class Roles
{
    public const string PlatformOwner = "PlatformOwner";
    public const string CompanyAdmin = "CompanyAdmin";
    public const string Supervisor = "Supervisor";
    public const string Guard = "Guard";
}

public static class Policies
{
    public const string PlatformOwnerOnly = "PlatformOwnerOnly";
    public const string CompanyAdminAndAbove = "CompanyAdminAndAbove";
    public const string SupervisorAndAbove = "SupervisorAndAbove";
    public const string AllRoles = "AllRoles";
}

public static class Claims
{
    public const string TenantId = "tenant_id";
    public const string Role = "role";
    public const string UserId = "user_id";
}

public static class DefaultValues
{
    public const int DefaultGeofenceRadius = 100; // meters
    public const int DefaultMaxUserAccounts = 10;
    public const int DefaultLocationUpdateInterval = 300; // seconds (5 minutes)
    public const int MaxIncidentDescriptionLength = 2000;
    public const int MaxFileSize = 10 * 1024 * 1024; // 10MB
}

public static class FileExtensions
{
    public static readonly string[] AllowedImageExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp" };
    public static readonly string[] AllowedAudioExtensions = { ".mp3", ".wav", ".m4a", ".aac" };
    public static readonly string[] AllowedVideoExtensions = { ".mp4", ".mov", ".avi", ".mkv" };
}
