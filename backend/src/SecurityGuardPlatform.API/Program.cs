using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SecurityGuardPlatform.Core.Constants;
using SecurityGuardPlatform.Core.Entities;
using SecurityGuardPlatform.Infrastructure.Data;
using Serilog;
using System.Collections;
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
// Temporarily use SQLite for testing until PostgreSQL is set up
var connectionString = Environment.GetEnvironmentVariable("DATABASE_URL");

if (builder.Environment.IsProduction() && !string.IsNullOrEmpty(connectionString))
{
    // Production with PostgreSQL
    Console.WriteLine($"Environment: {builder.Environment.EnvironmentName}");
    Console.WriteLine($"Using PostgreSQL connection");
    Console.WriteLine($"Connection string length: {connectionString.Length}");
    Console.WriteLine($"Connection string starts with: '{connectionString.Substring(0, Math.Min(50, connectionString.Length))}'");
    
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseNpgsql(connectionString));
}
else
{
    // Development or Production without DATABASE_URL - Use SQLite
    Console.WriteLine($"Environment: {builder.Environment.EnvironmentName}");
    Console.WriteLine($"Using SQLite connection (DATABASE_URL: {connectionString ?? "NULL"})");
    
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
