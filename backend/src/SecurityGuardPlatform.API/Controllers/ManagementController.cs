using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SecurityGuardPlatform.Infrastructure.Data;
using SecurityGuardPlatform.Core.Constants;
using SecurityGuardPlatform.Core.Entities;
using System.Security.Claims;

namespace SecurityGuardPlatform.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ManagementController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<ManagementController> _logger;

    public ManagementController(ApplicationDbContext context, ILogger<ManagementController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet("guards")]
    public async Task<ActionResult<List<GuardInfoDto>>> GetGuards()
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || !IsManagerOrAdmin(currentUser))
            {
                return Unauthorized();
            }

            var guards = await _context.Users
                .Where(u => u.Role == Roles.Guard && u.TenantId == currentUser.TenantId)
                .Select(u => new GuardInfoDto
                {
                    Id = u.Id.ToString(),
                    Name = u.FirstName + " " + u.LastName,
                    Email = u.Email ?? "",
                    PhoneNumber = u.PhoneNumber,
                    IsActive = u.IsActive,
                    LastLogin = u.CreatedAt, // Using CreatedAt as fallback since LastLogin doesn't exist
                    CreatedAt = u.CreatedAt
                })
                .ToListAsync();

            return Ok(guards);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting guards");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("patrols")]
    public async Task<ActionResult<List<PatrolRecordDto>>> GetPatrols([FromQuery] DateTime? date = null)
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || !IsManagerOrAdmin(currentUser))
            {
                return Unauthorized();
            }

            var targetDate = date ?? DateTime.Today;
            
            var patrols = await _context.CheckIns
                .Where(c => c.TenantId == currentUser.TenantId && 
                           c.CheckInTime.Date == targetDate.Date)
                .Include(c => c.Guard)
                .Include(c => c.Shift)
                .ThenInclude(s => s.Site)
                .Select(c => new PatrolRecordDto
                {
                    Id = c.Id.ToString(),
                    GuardId = c.GuardId.ToString(),
                    GuardName = c.Guard.FirstName + " " + c.Guard.LastName,
                    Timestamp = c.CheckInTime,
                    Location = c.Shift != null && c.Shift.Site != null ? c.Shift.Site.Name : "Unknown Location",
                    Latitude = c.Latitude,
                    Longitude = c.Longitude,
                    Notes = c.Notes ?? "",
                    Photos = new List<string>(), // TODO: Implement photo storage
                    Status = "completed"
                })
                .OrderByDescending(p => p.Timestamp)
                .ToListAsync();

            return Ok(patrols);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting patrols");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("incidents")]
    public async Task<ActionResult<List<IncidentReportDto>>> GetIncidents([FromQuery] DateTime? date = null)
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || !IsManagerOrAdmin(currentUser))
            {
                return Unauthorized();
            }

            var targetDate = date ?? DateTime.Today;
            
            var incidents = await _context.IncidentReports
                .Where(i => i.TenantId == currentUser.TenantId && 
                           i.CreatedAt.Date == targetDate.Date)
                .Include(i => i.Guard)
                .Include(i => i.Site)
                .Select(i => new IncidentReportDto
                {
                    Id = i.Id.ToString(),
                    GuardId = i.GuardId.ToString(),
                    GuardName = i.Guard.FirstName + " " + i.Guard.LastName,
                    Timestamp = i.CreatedAt,
                    Location = i.Site != null ? i.Site.Name : "Unknown Location",
                    Latitude = i.Latitude,
                    Longitude = i.Longitude,
                    Type = i.IncidentType,
                    Severity = i.Severity,
                    Description = i.Description,
                    Status = i.Status,
                    Photos = new List<string>() // TODO: Implement photo storage
                })
                .OrderByDescending(i => i.Timestamp)
                .ToListAsync();

            return Ok(incidents);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting incidents");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("stats")]
    public async Task<ActionResult<ManagementStatsDto>> GetManagementStats()
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || !IsManagerOrAdmin(currentUser))
            {
                return Unauthorized();
            }

            var today = DateTime.Today;
            var stats = new ManagementStatsDto
            {
                TotalGuards = await _context.Users
                    .Where(u => u.Role == Roles.Guard && u.TenantId == currentUser.TenantId)
                    .CountAsync(),

                OnDutyGuards = await _context.Shifts
                    .Where(s => s.TenantId == currentUser.TenantId && s.ActualEndTime == null)
                    .CountAsync(),

                TodayPatrols = await _context.CheckIns
                    .Where(c => c.TenantId == currentUser.TenantId && c.CheckInTime.Date == today)
                    .CountAsync(),

                TodayIncidents = await _context.IncidentReports
                    .Where(i => i.TenantId == currentUser.TenantId && i.CreatedAt.Date == today)
                    .CountAsync(),

                PendingIncidents = await _context.IncidentReports
                    .Where(i => i.TenantId == currentUser.TenantId && i.Status == "Pending")
                    .CountAsync()
            };

            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting management stats");
            return StatusCode(500, "Internal server error");
        }
    }

    private async Task<User?> GetCurrentUserAsync()
    {
        var userEmail = User.FindFirst(ClaimTypes.Email)?.Value;
        if (string.IsNullOrEmpty(userEmail))
        {
            return null;
        }

        return await _context.Users
            .Include(u => u.Tenant)
            .FirstOrDefaultAsync(u => u.Email == userEmail);
    }

    private static bool IsManagerOrAdmin(User user)
    {
        return user.Role == Roles.CompanyAdmin || user.Role == Roles.PlatformOwner;
    }
}

// DTOs
public class GuardInfoDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public bool IsActive { get; set; }
    public DateTime? LastLogin { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class PatrolRecordDto
{
    public string Id { get; set; } = string.Empty;
    public string GuardId { get; set; } = string.Empty;
    public string GuardName { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string Location { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Notes { get; set; } = string.Empty;
    public List<string> Photos { get; set; } = new();
    public string Status { get; set; } = string.Empty;
}

public class IncidentReportDto
{
    public string Id { get; set; } = string.Empty;
    public string GuardId { get; set; } = string.Empty;
    public string GuardName { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string Location { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Severity { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public List<string> Photos { get; set; } = new();
}

public class ManagementStatsDto
{
    public int TotalGuards { get; set; }
    public int OnDutyGuards { get; set; }
    public int TodayPatrols { get; set; }
    public int TodayIncidents { get; set; }
    public int PendingIncidents { get; set; }
}
