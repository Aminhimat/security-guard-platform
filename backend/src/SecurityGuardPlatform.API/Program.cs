using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using SecurityGuardPlatform.Core.Constants;
using SecurityGuardPlatform.Core.Entities;
using SecurityGuardPlatform.Infrastructure.Data;
using Serilog;
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
if (builder.Environment.IsProduction())
{
    // Production: Use PostgreSQL
    var connectionString = builder.Configuration.GetConnectionString("DATABASE_URL") ?? 
                          Environment.GetEnvironmentVariable("DATABASE_URL") ??
                          builder.Configuration.GetConnectionString("PostgreSQLConnection");
    
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseNpgsql(connectionString));
}
else
{
    // Development: Use SQLite
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
var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("JWT Key is not configured");
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
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidateAudience = true,
        ValidAudience = builder.Configuration["Jwt:Audience"],
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
