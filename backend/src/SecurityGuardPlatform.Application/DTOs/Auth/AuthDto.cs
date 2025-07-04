namespace SecurityGuardPlatform.Application.DTOs.Auth;

public class LoginRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class LoginResponseDto
{
    public string Token { get; set; } = string.Empty;
    public string RefreshToken { get; set; } = string.Empty;
    public UserDto User { get; set; } = null!;
}

public class RegisterRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string? EmployeeId { get; set; }
    public Guid? TenantId { get; set; }
}

public class UserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string? EmployeeId { get; set; }
    public Guid? TenantId { get; set; }
    public string? TenantName { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}
