using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SecurityGuardPlatform.Infrastructure.Data;
using SecurityGuardPlatform.Core.Constants;

namespace SecurityGuardPlatform.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DashboardController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<DashboardController> _logger;

    public DashboardController(ApplicationDbContext context, ILogger<DashboardController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpGet("stats")]
    public async Task<ActionResult<DashboardStatsDto>> GetDashboardStats()
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null)
            {
                return Unauthorized();
            }

            // Get stats based on user role and tenant
            var stats = new DashboardStatsDto();

            if (currentUser.Role == Roles.Guard)
            {
                // Get guard-specific stats
                stats.ActiveShifts = await _context.Shifts
                    .Where(s => s.GuardId == currentUser.Id && s.ActualEndTime == null)
                    .CountAsync();

                stats.TodayCheckIns = await _context.CheckIns
                    .Where(c => c.GuardId == currentUser.Id && c.CheckInTime.Date == DateTime.Today)
                    .CountAsync();

                stats.PendingIncidents = await _context.IncidentReports
                    .Where(i => i.GuardId == currentUser.Id && i.Status == "Pending")
                    .CountAsync();

                stats.TotalSites = await _context.Sites
                    .Where(s => s.TenantId == currentUser.TenantId)
                    .CountAsync();
            }
            else if (currentUser.Role == Roles.CompanyAdmin || currentUser.Role == Roles.Supervisor)
            {
                // Get company-wide stats for the tenant
                stats.ActiveShifts = await _context.Shifts
                    .Where(s => s.TenantId == currentUser.TenantId && s.ActualEndTime == null)
                    .CountAsync();

                stats.TodayCheckIns = await _context.CheckIns
                    .Where(c => c.TenantId == currentUser.TenantId && c.CheckInTime.Date == DateTime.Today)
                    .CountAsync();

                stats.PendingIncidents = await _context.IncidentReports
                    .Where(i => i.TenantId == currentUser.TenantId && i.Status == "Pending")
                    .CountAsync();

                stats.TotalSites = await _context.Sites
                    .Where(s => s.TenantId == currentUser.TenantId)
                    .CountAsync();

                stats.TotalGuards = await _context.Users
                    .Where(u => u.TenantId == currentUser.TenantId && u.Role == Roles.Guard)
                    .CountAsync();
            }

            return Ok(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting dashboard stats");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("recent-activity")]
    public async Task<ActionResult<List<RecentActivityDto>>> GetRecentActivity()
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null)
            {
                return Unauthorized();
            }

            var activities = new List<RecentActivityDto>();

            // Get recent check-ins
            var recentCheckIns = await _context.CheckIns
                .Where(c => c.TenantId == currentUser.TenantId)
                .OrderByDescending(c => c.CheckInTime)
                .Take(10)
                .Include(c => c.Guard)
                .Include(c => c.Shift)
                .ThenInclude(s => s.Site)
                .Select(c => new RecentActivityDto
                {
                    Id = c.Id.ToString(),
                    Type = "CheckIn",
                    Description = $"{c.Guard!.FirstName} {c.Guard.LastName} checked in at {c.Shift!.Site!.Name}",
                    Timestamp = c.CheckInTime,
                    UserName = $"{c.Guard.FirstName} {c.Guard.LastName}"
                })
                .ToListAsync();

            activities.AddRange(recentCheckIns);

            // Get recent incidents
            var recentIncidents = await _context.IncidentReports
                .Where(i => i.TenantId == currentUser.TenantId)
                .OrderByDescending(i => i.IncidentDateTime)
                .Take(5)
                .Include(i => i.Guard)
                .Select(i => new RecentActivityDto
                {
                    Id = i.Id.ToString(),
                    Type = "Incident",
                    Description = $"Incident reported: {i.Title}",
                    Timestamp = i.IncidentDateTime,
                    UserName = $"{i.Guard!.FirstName} {i.Guard.LastName}"
                })
                .ToListAsync();

            activities.AddRange(recentIncidents);

            // Sort by timestamp
            activities = activities.OrderByDescending(a => a.Timestamp).Take(15).ToList();

            return Ok(activities);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting recent activity");
            return StatusCode(500, "Internal server error");
        }
    }

    private async Task<SecurityGuardPlatform.Core.Entities.User?> GetCurrentUserAsync()
    {
        var userIdClaim = User.FindFirst("sub") ?? User.FindFirst("id");
        if (userIdClaim == null || !Guid.TryParse(userIdClaim.Value, out var userId))
        {
            return null;
        }

        return await _context.Users
            .Include(u => u.Tenant)
            .FirstOrDefaultAsync(u => u.Id == userId);
    }
}

public class DashboardStatsDto
{
    public int ActiveShifts { get; set; }
    public int TodayCheckIns { get; set; }
    public int PendingIncidents { get; set; }
    public int TotalSites { get; set; }
    public int TotalGuards { get; set; }
}

public class RecentActivityDto
{
    public string Id { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string UserName { get; set; } = string.Empty;
}
