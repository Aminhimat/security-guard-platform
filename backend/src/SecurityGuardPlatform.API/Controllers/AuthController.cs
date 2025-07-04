using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SecurityGuardPlatform.Application.DTOs.Auth;
using SecurityGuardPlatform.Application.DTOs.Tenant;
using SecurityGuardPlatform.Core.Constants;
using SecurityGuardPlatform.Core.Entities;
using SecurityGuardPlatform.Infrastructure.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace SecurityGuardPlatform.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly UserManager<User> _userManager;
    private readonly SignInManager<User> _signInManager;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthController> _logger;
    private readonly ApplicationDbContext _context;

    public AuthController(
        UserManager<User> userManager,
        SignInManager<User> signInManager,
        IConfiguration configuration,
        ILogger<AuthController> logger,
        ApplicationDbContext context)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _configuration = configuration;
        _logger = logger;
        _context = context;
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponseDto>> Login([FromBody] LoginRequestDto request)
    {
        try
        {
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null || !user.IsActive)
            {
                return Unauthorized("Invalid credentials");
            }

            var result = await _signInManager.CheckPasswordSignInAsync(user, request.Password, false);
            if (!result.Succeeded)
            {
                return Unauthorized("Invalid credentials");
            }

            var token = await GenerateJwtToken(user);

            var userDto = new UserDto
            {
                Id = user.Id,
                Email = user.Email!,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                EmployeeId = user.EmployeeId,
                TenantId = user.TenantId,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt
            };

            return Ok(new LoginResponseDto
            {
                Token = token,
                RefreshToken = "", // TODO: Implement refresh tokens
                User = userDto
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during login for email {Email}", request.Email);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("register")]
    [Authorize(Policy = Policies.CompanyAdminAndAbove)]
    public async Task<ActionResult<UserDto>> Register([FromBody] RegisterRequestDto request)
    {
        try
        {
            // Validate tenant access for company admins
            var currentUser = await GetCurrentUserAsync();
            if (currentUser?.Role == Roles.CompanyAdmin && request.TenantId != currentUser.TenantId)
            {
                return Forbid("Cannot create users for other tenants");
            }

            // Check user limits for the tenant
            var tenant = await _context.Tenants.FindAsync(request.TenantId);
            if (tenant == null)
            {
                return BadRequest("Invalid tenant");
            }

            var currentUserCount = await _context.Users.CountAsync(u => u.TenantId == request.TenantId);
            if (currentUserCount >= tenant.MaxUserAccounts)
            {
                return BadRequest($"User limit exceeded. Maximum allowed users: {tenant.MaxUserAccounts}, Current users: {currentUserCount}");
            }

            var user = new User
            {
                UserName = request.Email,
                Email = request.Email,
                FirstName = request.FirstName,
                LastName = request.LastName,
                Role = request.Role,
                EmployeeId = request.EmployeeId,
                TenantId = request.TenantId
            };

            var result = await _userManager.CreateAsync(user, request.Password);
            if (!result.Succeeded)
            {
                return BadRequest(result.Errors);
            }

            // Add role
            await _userManager.AddToRoleAsync(user, request.Role);

            var userDto = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                EmployeeId = user.EmployeeId,
                TenantId = user.TenantId,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt
            };

            return CreatedAtAction(nameof(GetUser), new { id = user.Id }, userDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during registration for email {Email}", request.Email);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("user/{id}")]
    [Authorize]
    public async Task<ActionResult<UserDto>> GetUser(Guid id)
    {
        try
        {
            var user = await _userManager.FindByIdAsync(id.ToString());
            if (user == null)
            {
                return NotFound();
            }

            // Check tenant access
            var currentUser = await GetCurrentUserAsync();
            if (!CanAccessUser(currentUser, user))
            {
                return Forbid();
            }

            var userDto = new UserDto
            {
                Id = user.Id,
                Email = user.Email!,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                EmployeeId = user.EmployeeId,
                TenantId = user.TenantId,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt
            };

            return Ok(userDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user {UserId}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<UserDto>> GetCurrentUser()
    {
        try
        {
            var user = await GetCurrentUserAsync();
            if (user == null)
            {
                return Unauthorized();
            }

            var userDto = new UserDto
            {
                Id = user.Id,
                Email = user.Email!,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role,
                EmployeeId = user.EmployeeId,
                TenantId = user.TenantId,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt
            };

            return Ok(userDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting current user");
            return StatusCode(500, "Internal server error");
        }
    }

    private async Task<string> GenerateJwtToken(User user)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]!);

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Email, user.Email!),
            new(ClaimTypes.Role, user.Role),
            new(Claims.UserId, user.Id.ToString()),
            new(Claims.Role, user.Role)
        };

        if (user.TenantId.HasValue)
        {
            claims.Add(new Claim(Claims.TenantId, user.TenantId.Value.ToString()));
        }

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddMinutes(Convert.ToDouble(_configuration["Jwt:ExpiryMinutes"])),
            Issuer = _configuration["Jwt:Issuer"],
            Audience = _configuration["Jwt:Audience"],
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }

    private async Task<User?> GetCurrentUserAsync()
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userId == null) return null;

        return await _userManager.FindByIdAsync(userId);
    }

    // Tenant Management Endpoints (Platform Owner only)
    
    [HttpGet("tenants")]
    [Authorize(Policy = Policies.PlatformOwnerOnly)]
    public async Task<ActionResult<IEnumerable<TenantDto>>> GetTenants()
    {
        try
        {
            var tenants = await _context.Tenants
                .Select(t => new TenantDto
                {
                    Id = t.Id,
                    CompanyName = t.CompanyName,
                    Address = t.Address,
                    ContactEmail = t.ContactEmail,
                    ContactPhone = t.ContactPhone,
                    MaxUserAccounts = t.MaxUserAccounts,
                    CurrentUserCount = t.Users.Count(),
                    SubscriptionPlan = t.SubscriptionPlan,
                    IsActive = t.IsActive,
                    SubscriptionExpiryDate = t.SubscriptionExpiryDate,
                    CreatedAt = t.CreatedAt
                })
                .ToListAsync();

            return Ok(tenants);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting tenants");
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpGet("tenants/{id}")]
    [Authorize]
    public async Task<ActionResult<TenantDto>> GetTenant(Guid id)
    {
        try
        {
            var currentUser = await GetCurrentUserAsync();
            
            // Platform Owner can view any tenant, Company Admin can only view their own
            if (currentUser?.Role != Roles.PlatformOwner && currentUser?.TenantId != id)
            {
                return Forbid("Cannot access other tenant information");
            }

            var tenant = await _context.Tenants
                .Where(t => t.Id == id)
                .Select(t => new TenantDto
                {
                    Id = t.Id,
                    CompanyName = t.CompanyName,
                    Address = t.Address,
                    ContactEmail = t.ContactEmail,
                    ContactPhone = t.ContactPhone,
                    MaxUserAccounts = t.MaxUserAccounts,
                    CurrentUserCount = t.Users.Count(),
                    SubscriptionPlan = t.SubscriptionPlan,
                    IsActive = t.IsActive,
                    SubscriptionExpiryDate = t.SubscriptionExpiryDate,
                    CreatedAt = t.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (tenant == null)
            {
                return NotFound();
            }

            return Ok(tenant);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting tenant {Id}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPut("tenants/{id}/user-limit")]
    [Authorize(Policy = Policies.PlatformOwnerOnly)]
    public async Task<ActionResult> UpdateTenantUserLimit(Guid id, [FromBody] UpdateUserLimitDto request)
    {
        try
        {
            var tenant = await _context.Tenants.FindAsync(id);
            if (tenant == null)
            {
                return NotFound();
            }

            var currentUserCount = await _context.Users.CountAsync(u => u.TenantId == id);
            if (request.MaxUserAccounts < currentUserCount)
            {
                return BadRequest($"Cannot set limit below current user count. Current users: {currentUserCount}");
            }

            tenant.MaxUserAccounts = request.MaxUserAccounts;
            await _context.SaveChangesAsync();

            return Ok(new { message = "User limit updated successfully" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating tenant user limit for tenant {Id}", id);
            return StatusCode(500, "Internal server error");
        }
    }

    [HttpPost("tenants")]
    [Authorize(Policy = Policies.PlatformOwnerOnly)]
    public async Task<ActionResult<TenantDto>> CreateTenant([FromBody] CreateTenantDto request)
    {
        try
        {
            var tenant = new Tenant
            {
                CompanyName = request.CompanyName,
                Address = request.Address,
                ContactEmail = request.ContactEmail,
                ContactPhone = request.ContactPhone,
                MaxUserAccounts = request.MaxUserAccounts,
                SubscriptionPlan = request.SubscriptionPlan,
                SubscriptionExpiryDate = request.SubscriptionExpiryDate,
                IsActive = true
            };

            _context.Tenants.Add(tenant);
            await _context.SaveChangesAsync();

            var tenantDto = new TenantDto
            {
                Id = tenant.Id,
                CompanyName = tenant.CompanyName,
                Address = tenant.Address,
                ContactEmail = tenant.ContactEmail,
                ContactPhone = tenant.ContactPhone,
                MaxUserAccounts = tenant.MaxUserAccounts,
                CurrentUserCount = 0,
                SubscriptionPlan = tenant.SubscriptionPlan,
                IsActive = tenant.IsActive,
                SubscriptionExpiryDate = tenant.SubscriptionExpiryDate,
                CreatedAt = tenant.CreatedAt
            };

            return CreatedAtAction(nameof(GetTenant), new { id = tenant.Id }, tenantDto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating tenant");
            return StatusCode(500, "Internal server error");
        }
    }

    private static bool CanAccessUser(User? currentUser, User targetUser)
    {
        if (currentUser == null) return false;

        // Platform owners can access all users
        if (currentUser.Role == Roles.PlatformOwner) return true;

        // Company admins and below can only access users in their tenant
        return currentUser.TenantId == targetUser.TenantId;
    }
}
