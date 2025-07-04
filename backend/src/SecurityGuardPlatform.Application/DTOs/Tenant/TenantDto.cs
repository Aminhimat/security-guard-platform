namespace SecurityGuardPlatform.Application.DTOs.Tenant;

public class TenantDto
{
    public Guid Id { get; set; }
    public string CompanyName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string ContactEmail { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public int MaxUserAccounts { get; set; }
    public int CurrentUserCount { get; set; }
    public string SubscriptionPlan { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime? SubscriptionExpiryDate { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateTenantDto
{
    public string CompanyName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string ContactEmail { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public int MaxUserAccounts { get; set; } = 10;
    public string SubscriptionPlan { get; set; } = "Basic";
    public DateTime? SubscriptionExpiryDate { get; set; }
}

public class UpdateTenantDto
{
    public string CompanyName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string ContactEmail { get; set; } = string.Empty;
    public string ContactPhone { get; set; } = string.Empty;
    public int MaxUserAccounts { get; set; }
    public string SubscriptionPlan { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime? SubscriptionExpiryDate { get; set; }
}

public class UpdateUserLimitDto
{
    public int MaxUserAccounts { get; set; }
}
