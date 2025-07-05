using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SecurityGuardPlatform.Core.Constants;
using SecurityGuardPlatform.Core.Entities;
using SecurityGuardPlatform.Infrastructure.Data;
using Serilog;
using System.Collections;
using System.Linq;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .CreateLogger();

builder.Host.UseSerilog();

// Add services to the container.
// Configure Database - Use PostgreSQL in production, SQLite in development
var databaseUrl = Environment.GetEnvironmentVariable("DATABASE_URL");

if (builder.Environment.IsProduction() && !string.IsNullOrEmpty(databaseUrl))
{
    // Production with PostgreSQL - Convert URI to connection string
    Console.WriteLine($"Environment: {builder.Environment.EnvironmentName}");
    Console.WriteLine($"Using PostgreSQL connection");
    Console.WriteLine($"Database URL length: {databaseUrl.Length}");
    Console.WriteLine($"Database URL starts with: '{databaseUrl.Substring(0, Math.Min(50, databaseUrl.Length))}'");
    
    // Parse the DATABASE_URL and convert to Npgsql connection string
    var uri = new Uri(databaseUrl);
    
    // Try to resolve IPv4 address to avoid IPv6 connectivity issues
    var hostEntry = System.Net.Dns.GetHostEntry(uri.Host);
    var ipv4Address = hostEntry.AddressList.FirstOrDefault(addr => addr.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork);
    var actualHost = ipv4Address?.ToString() ?? uri.Host;
    
    Console.WriteLine($"Original host: {uri.Host}");
    if (ipv4Address != null)
    {
        Console.WriteLine($"Resolved IPv4 address: {actualHost}");
    }
    
    var connectionString = $"Host={actualHost};Port={uri.Port};Database={uri.LocalPath.Substring(1)};Username={uri.UserInfo.Split(':')[0]};Password={uri.UserInfo.Split(':')[1]};SSL Mode=Require;Trust Server Certificate=true;Include Error Detail=true;Timeout=30;Command Timeout=30";
    
    Console.WriteLine($"Converted connection string starts with: 'Host={actualHost};Port={uri.Port}'");
    
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseNpgsql(connectionString));
}
else
{
    // Development or Production without DATABASE_URL - Use SQLite
    Console.WriteLine($"Environment: {builder.Environment.EnvironmentName}");
    Console.WriteLine($"Using SQLite connection (DATABASE_URL: {databaseUrl ?? "NULL"})");
    
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));
}

// Configure Identity
builder.Services.AddIdentity<User, IdentityRole<Guid>>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequiredLength = 8;
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Configure JWT Authentication
var jwtKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? 
            builder.Configuration["Jwt:Key"] ?? 
            throw new InvalidOperationException("JWT Key is not configured");
var key = Encoding.ASCII.GetBytes(jwtKey);

builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false;
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true,
        ValidIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? 
                     builder.Configuration["Jwt:Issuer"] ?? 
                     "SecurityGuardPlatform",
        ValidateAudience = true,
        ValidAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? 
                       builder.Configuration["Jwt:Audience"] ?? 
                       "SecurityGuardPlatformUsers",
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

// Configure Authorization Policies
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy(Policies.PlatformOwnerOnly, policy =>
        policy.RequireRole(Roles.PlatformOwner));
    
    options.AddPolicy(Policies.CompanyAdminAndAbove, policy =>
        policy.RequireRole(Roles.PlatformOwner, Roles.CompanyAdmin));
    
    options.AddPolicy(Policies.SupervisorAndAbove, policy =>
        policy.RequireRole(Roles.PlatformOwner, Roles.CompanyAdmin, Roles.Supervisor));
    
    options.AddPolicy(Policies.AllRoles, policy =>
        policy.RequireRole(Roles.PlatformOwner, Roles.CompanyAdmin, Roles.Supervisor, Roles.Guard));
});

builder.Services.AddControllers();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Security Guard Platform API", Version = "v1" });
    
    // Configure JWT for Swagger
    c.AddSecurityDefinition("Bearer", new()
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Enter 'Bearer' [space] and then your token"
    });
    
    c.AddSecurityRequirement(new()
    {
        {
            new()
            {
                Reference = new() { Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            new string[] { }
        }
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    context.Database.EnsureCreated();
}

app.Run();
