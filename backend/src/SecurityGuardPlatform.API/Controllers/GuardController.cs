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
public class GuardController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<GuardController> _logger;

    public GuardController(ApplicationDbContext context, ILogger<GuardController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [HttpPost("checkin")]
    public async Task<ActionResult<CheckInResponseDto>> CheckIn([FromBody] CheckInRequestDto request)
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || currentUser.Role != Roles.Guard)
            {
                return Unauthorized();
            }

            // Find current active shift
            var currentShift = await _context.Shifts
                .FirstOrDefaultAsync(s => s.GuardId == currentUser.Id && s.ActualEndTime == null);

            if (currentShift == null)
            {
                return BadRequest("No active shift found. Please start your shift first.");
            }

            var checkIn = new CheckIn
            {
                GuardId = currentUser.Id,
                TenantId = currentUser.TenantId ?? Guid.Empty,
                ShiftId = currentShift.Id,
                CheckInTime = DateTime.UtcNow,
                CheckInType = "Manual",
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                Notes = request.Notes,
                CheckpointId = request.CheckpointId
            };

            _context.CheckIns.Add(checkIn);
            await _context.SaveChangesAsync();

            return Ok(new CheckInResponseDto
            {
                Id = checkIn.Id.ToString(),
                CheckInTime = checkIn.CheckInTime,
                Success = true,
                Message = "Check-in successful"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during check-in");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("incident")]
    public async Task<ActionResult<IncidentResponseDto>> ReportIncident([FromBody] ReportIncidentRequestDto request)
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || currentUser.Role != Roles.Guard)
            {
                return Unauthorized();
            }

            // Get the user's current site from active shift
            var currentShift = await _context.Shifts
                .FirstOrDefaultAsync(s => s.GuardId == currentUser.Id && s.ActualEndTime == null);

            var incident = new IncidentReport
            {
                GuardId = currentUser.Id,
                TenantId = currentUser.TenantId ?? Guid.Empty,
                SiteId = currentShift?.SiteId ?? request.SiteId,
                Title = request.Type,
                Description = request.Description,
                IncidentType = request.Type,
                Severity = request.Severity,
                Status = "Open",
                Latitude = request.Latitude,
                Longitude = request.Longitude
            };

            _context.IncidentReports.Add(incident);
            await _context.SaveChangesAsync();

            return Ok(new IncidentResponseDto
            {
                Id = incident.Id.ToString(),
                ReportedAt = incident.CreatedAt,
                Success = true,
                Message = "Incident reported successfully"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error reporting incident");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("shifts/current")]
    public async Task<ActionResult<CurrentShiftDto>> GetCurrentShift()
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || currentUser.Role != Roles.Guard)
            {
                return Unauthorized();
            }

            var currentShift = await _context.Shifts
                .Where(s => s.GuardId == currentUser.Id && s.ActualEndTime == null)
                .Include(s => s.Site)
                .FirstOrDefaultAsync();

            if (currentShift == null)
            {
                return Ok(new CurrentShiftDto { IsOnDuty = false });
            }

            return Ok(new CurrentShiftDto
            {
                IsOnDuty = true,
                ShiftId = currentShift.Id.ToString(),
                StartTime = currentShift.ActualStartTime ?? currentShift.ScheduledStartTime,
                SiteName = currentShift.Site?.Name ?? "Unknown Site",
                SiteId = currentShift.SiteId.ToString()
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting current shift");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("shifts/start")]
    public async Task<ActionResult<ShiftResponseDto>> StartShift([FromBody] StartShiftRequestDto request)
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || currentUser.Role != Roles.Guard)
            {
                return Unauthorized();
            }

            // Check if already on duty
            var existingShift = await _context.Shifts
                .FirstOrDefaultAsync(s => s.GuardId == currentUser.Id && s.ActualEndTime == null);

            if (existingShift != null)
            {
                return BadRequest("You are already on duty");
            }

            // For now, create a simple shift. In a real app, you'd find scheduled shifts
            var shift = new Shift
            {
                GuardId = currentUser.Id,
                TenantId = currentUser.TenantId ?? Guid.Empty,
                SiteId = request.SiteId,
                ScheduledStartTime = DateTime.UtcNow,
                ScheduledEndTime = DateTime.UtcNow.AddHours(8),
                ActualStartTime = DateTime.UtcNow,
                Status = "Active",
                Notes = request.Notes
            };

            _context.Shifts.Add(shift);
            await _context.SaveChangesAsync();

            return Ok(new ShiftResponseDto
            {
                Id = shift.Id.ToString(),
                StartTime = shift.ActualStartTime,
                Success = true,
                Message = "Shift started successfully"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error starting shift");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("shifts/end")]
    public async Task<ActionResult<ShiftResponseDto>> EndShift([FromBody] EndShiftRequestDto request)
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || currentUser.Role != Roles.Guard)
            {
                return Unauthorized();
            }

            var currentShift = await _context.Shifts
                .FirstOrDefaultAsync(s => s.GuardId == currentUser.Id && s.ActualEndTime == null);

            if (currentShift == null)
            {
                return BadRequest("No active shift found");
            }

            currentShift.ActualEndTime = DateTime.UtcNow;
            currentShift.Status = "Completed";
            currentShift.Notes = request.Notes;

            await _context.SaveChangesAsync();

            return Ok(new ShiftResponseDto
            {
                Id = currentShift.Id.ToString(),
                EndTime = currentShift.ActualEndTime,
                Success = true,
                Message = "Shift ended successfully"
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error ending shift");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("patrols/history")]
    public async Task<ActionResult<List<PatrolHistoryDto>>> GetPatrolHistory([FromQuery] int days = 7)
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || currentUser.Role != Roles.Guard)
            {
                return Unauthorized();
            }

            var startDate = DateTime.Today.AddDays(-days);
            
            var patrols = await _context.CheckIns
                .Where(c => c.GuardId == currentUser.Id && c.CheckInTime >= startDate)
                .Include(c => c.Shift)
                .ThenInclude(s => s.Site)
                .Include(c => c.Checkpoint)
                .Select(c => new PatrolHistoryDto
                {
                    Id = c.Id.ToString(),
                    Timestamp = c.CheckInTime,
                    Location = c.Shift.Site != null ? c.Shift.Site.Name : "Unknown Location",
                    CheckpointName = c.Checkpoint != null ? c.Checkpoint.Name : null,
                    Latitude = c.Latitude,
                    Longitude = c.Longitude,
                    Notes = c.Notes ?? "",
                    Status = "Completed"
                })
                .OrderByDescending(p => p.Timestamp)
                .ToListAsync();

            return Ok(patrols);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting patrol history");
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
}

// DTOs
public class CheckInRequestDto
{
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string? Notes { get; set; }
    public Guid? CheckpointId { get; set; }
    public Guid? SiteId { get; set; }
}

public class CheckInResponseDto
{
    public string Id { get; set; } = string.Empty;
    public DateTime CheckInTime { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class ReportIncidentRequestDto
{
    public string Type { get; set; } = string.Empty;
    public string Severity { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public Guid SiteId { get; set; } = Guid.Empty;
}

public class IncidentResponseDto
{
    public string Id { get; set; } = string.Empty;
    public DateTime ReportedAt { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class CurrentShiftDto
{
    public bool IsOnDuty { get; set; }
    public string? ShiftId { get; set; }
    public DateTime? StartTime { get; set; }
    public string? SiteName { get; set; }
    public string? SiteId { get; set; }
}

public class StartShiftRequestDto
{
    public Guid SiteId { get; set; } = Guid.Empty;
    public string? Notes { get; set; }
}

public class EndShiftRequestDto
{
    public string? Notes { get; set; }
}

public class ShiftResponseDto
{
    public string Id { get; set; } = string.Empty;
    public DateTime? StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class PatrolHistoryDto
{
    public string Id { get; set; } = string.Empty;
    public DateTime Timestamp { get; set; }
    public string Location { get; set; } = string.Empty;
    public string? CheckpointName { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string Notes { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
}
