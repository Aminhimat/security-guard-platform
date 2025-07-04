using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using SecurityGuardPlatform.Core.Entities;

namespace SecurityGuardPlatform.Infrastructure.Data;

public class ApplicationDbContext : IdentityDbContext<User, IdentityRole<Guid>, Guid>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    // DbSets for all entities
    public DbSet<Tenant> Tenants { get; set; }
    public DbSet<Site> Sites { get; set; }
    public DbSet<Checkpoint> Checkpoints { get; set; }
    public DbSet<Shift> Shifts { get; set; }
    public DbSet<CheckIn> CheckIns { get; set; }
    public DbSet<LocationLog> LocationLogs { get; set; }
    public DbSet<IncidentReport> IncidentReports { get; set; }
    public DbSet<IncidentMedia> IncidentMedia { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure entity relationships and constraints
        ConfigureIdentityTables(modelBuilder);
        ConfigureTenantRelationships(modelBuilder);
        ConfigureEntityConstraints(modelBuilder);
        ConfigureGlobalQueryFilters(modelBuilder);
        SeedData(modelBuilder);
    }

    private void ConfigureIdentityTables(ModelBuilder modelBuilder)
    {
        // Customize Identity table names
        modelBuilder.Entity<User>().ToTable("Users");
        modelBuilder.Entity<IdentityRole<Guid>>().ToTable("Roles");
        modelBuilder.Entity<IdentityUserRole<Guid>>().ToTable("UserRoles");
        modelBuilder.Entity<IdentityUserClaim<Guid>>().ToTable("UserClaims");
        modelBuilder.Entity<IdentityRoleClaim<Guid>>().ToTable("RoleClaims");
        modelBuilder.Entity<IdentityUserLogin<Guid>>().ToTable("UserLogins");
        modelBuilder.Entity<IdentityUserToken<Guid>>().ToTable("UserTokens");
    }

    private void ConfigureTenantRelationships(ModelBuilder modelBuilder)
    {
        // User-Tenant relationship
        modelBuilder.Entity<User>()
            .HasOne(u => u.Tenant)
            .WithMany(t => t.Users)
            .HasForeignKey(u => u.TenantId)
            .OnDelete(DeleteBehavior.Restrict);

        // Site-Tenant relationship
        modelBuilder.Entity<Site>()
            .HasOne(s => s.Tenant)
            .WithMany(t => t.Sites)
            .HasForeignKey(s => s.TenantId)
            .OnDelete(DeleteBehavior.Cascade);

        // Checkpoint-Site relationship
        modelBuilder.Entity<Checkpoint>()
            .HasOne(c => c.Site)
            .WithMany(s => s.Checkpoints)
            .HasForeignKey(c => c.SiteId)
            .OnDelete(DeleteBehavior.Cascade);

        // Shift relationships
        modelBuilder.Entity<Shift>()
            .HasOne(s => s.Guard)
            .WithMany(u => u.Shifts)
            .HasForeignKey(s => s.GuardId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<Shift>()
            .HasOne(s => s.Site)
            .WithMany(site => site.Shifts)
            .HasForeignKey(s => s.SiteId)
            .OnDelete(DeleteBehavior.Restrict);

        // CheckIn relationships
        modelBuilder.Entity<CheckIn>()
            .HasOne(c => c.Guard)
            .WithMany(u => u.CheckIns)
            .HasForeignKey(c => c.GuardId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<CheckIn>()
            .HasOne(c => c.Shift)
            .WithMany(s => s.CheckIns)
            .HasForeignKey(c => c.ShiftId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<CheckIn>()
            .HasOne(c => c.Checkpoint)
            .WithMany(cp => cp.CheckIns)
            .HasForeignKey(c => c.CheckpointId)
            .OnDelete(DeleteBehavior.SetNull);

        // LocationLog relationships
        modelBuilder.Entity<LocationLog>()
            .HasOne(l => l.Guard)
            .WithMany()
            .HasForeignKey(l => l.GuardId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<LocationLog>()
            .HasOne(l => l.Shift)
            .WithMany(s => s.LocationLogs)
            .HasForeignKey(l => l.ShiftId)
            .OnDelete(DeleteBehavior.Cascade);

        // IncidentReport relationships
        modelBuilder.Entity<IncidentReport>()
            .HasOne(i => i.Guard)
            .WithMany(u => u.IncidentReports)
            .HasForeignKey(i => i.GuardId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<IncidentReport>()
            .HasOne(i => i.Site)
            .WithMany(s => s.IncidentReports)
            .HasForeignKey(i => i.SiteId)
            .OnDelete(DeleteBehavior.Restrict);

        modelBuilder.Entity<IncidentReport>()
            .HasOne(i => i.Shift)
            .WithMany()
            .HasForeignKey(i => i.ShiftId)
            .OnDelete(DeleteBehavior.SetNull);

        // IncidentMedia relationship
        modelBuilder.Entity<IncidentMedia>()
            .HasOne(m => m.IncidentReport)
            .WithMany(i => i.IncidentMedia)
            .HasForeignKey(m => m.IncidentReportId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private void ConfigureEntityConstraints(ModelBuilder modelBuilder)
    {
        // Unique constraints
        modelBuilder.Entity<Tenant>()
            .HasIndex(t => t.ContactEmail)
            .IsUnique();

        modelBuilder.Entity<Checkpoint>()
            .HasIndex(c => c.CheckpointCode)
            .IsUnique();

        // Precision for decimal/double fields
        modelBuilder.Entity<Site>()
            .Property(s => s.Latitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<Site>()
            .Property(s => s.Longitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<Checkpoint>()
            .Property(c => c.Latitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<Checkpoint>()
            .Property(c => c.Longitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<CheckIn>()
            .Property(c => c.Latitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<CheckIn>()
            .Property(c => c.Longitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<LocationLog>()
            .Property(l => l.Latitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<LocationLog>()
            .Property(l => l.Longitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<IncidentReport>()
            .Property(i => i.Latitude)
            .HasPrecision(18, 6);

        modelBuilder.Entity<IncidentReport>()
            .Property(i => i.Longitude)
            .HasPrecision(18, 6);
    }

    private void ConfigureGlobalQueryFilters(ModelBuilder modelBuilder)
    {
        // Global query filter for soft deletes
        modelBuilder.Entity<Tenant>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<Site>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<Checkpoint>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<Shift>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<CheckIn>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<LocationLog>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<IncidentReport>().HasQueryFilter(e => !e.IsDeleted);
        modelBuilder.Entity<IncidentMedia>().HasQueryFilter(e => !e.IsDeleted);
    }

    private void SeedData(ModelBuilder modelBuilder)
    {
        // Seed default roles
        var platformOwnerRoleId = Guid.Parse("11111111-1111-1111-1111-111111111111");
        var companyAdminRoleId = Guid.Parse("22222222-2222-2222-2222-222222222222");
        var supervisorRoleId = Guid.Parse("33333333-3333-3333-3333-333333333333");
        var guardRoleId = Guid.Parse("44444444-4444-4444-4444-444444444444");

        modelBuilder.Entity<IdentityRole<Guid>>().HasData(
            new IdentityRole<Guid>
            {
                Id = platformOwnerRoleId,
                Name = "PlatformOwner",
                NormalizedName = "PLATFORMOWNER",
                ConcurrencyStamp = Guid.NewGuid().ToString()
            },
            new IdentityRole<Guid>
            {
                Id = companyAdminRoleId,
                Name = "CompanyAdmin",
                NormalizedName = "COMPANYADMIN",
                ConcurrencyStamp = Guid.NewGuid().ToString()
            },
            new IdentityRole<Guid>
            {
                Id = supervisorRoleId,
                Name = "Supervisor",
                NormalizedName = "SUPERVISOR",
                ConcurrencyStamp = Guid.NewGuid().ToString()
            },
            new IdentityRole<Guid>
            {
                Id = guardRoleId,
                Name = "Guard",
                NormalizedName = "GUARD",
                ConcurrencyStamp = Guid.NewGuid().ToString()
            }
        );

        // Seed test tenant
        var testTenantId = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
        modelBuilder.Entity<Tenant>().HasData(
            new Tenant
            {
                Id = testTenantId,
                CompanyName = "Test Security Company",
                ContactEmail = "admin@testsecurity.com",
                ContactPhone = "+1234567890",
                Address = "123 Test Street, Test City, TC 12345",
                IsActive = true,
                SubscriptionPlan = "Premium",
                MaxUserAccounts = 50,
                CreatedAt = DateTime.UtcNow
            }
        );

        // Seed test users with hashed passwords
        var passwordHasher = new PasswordHasher<User>();
        
        // Platform Owner user
        var platformOwnerId = Guid.Parse("10000000-0000-0000-0000-000000000001");
        var platformOwner = new User
        {
            Id = platformOwnerId,
            UserName = "platformowner",
            NormalizedUserName = "PLATFORMOWNER",
            Email = "owner@platform.com",
            NormalizedEmail = "OWNER@PLATFORM.COM",
            EmailConfirmed = true,
            FirstName = "Platform",
            LastName = "Owner",
            Role = "PlatformOwner",
            TenantId = null,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            SecurityStamp = Guid.NewGuid().ToString(),
            ConcurrencyStamp = Guid.NewGuid().ToString()
        };
        platformOwner.PasswordHash = passwordHasher.HashPassword(platformOwner, "Platform123!");

        // Company Admin user
        var companyAdminId = Guid.Parse("20000000-0000-0000-0000-000000000001");
        var companyAdmin = new User
        {
            Id = companyAdminId,
            UserName = "companyadmin",
            NormalizedUserName = "COMPANYADMIN",
            Email = "admin@testsecurity.com",
            NormalizedEmail = "ADMIN@TESTSECURITY.COM",
            EmailConfirmed = true,
            FirstName = "Company",
            LastName = "Admin",
            Role = "CompanyAdmin",
            TenantId = testTenantId,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            SecurityStamp = Guid.NewGuid().ToString(),
            ConcurrencyStamp = Guid.NewGuid().ToString()
        };
        companyAdmin.PasswordHash = passwordHasher.HashPassword(companyAdmin, "Admin123!");

        // Test Guard user
        var guardId = Guid.Parse("30000000-0000-0000-0000-000000000001");
        var guard = new User
        {
            Id = guardId,
            UserName = "testguard",
            NormalizedUserName = "TESTGUARD",
            Email = "guard@testsecurity.com",
            NormalizedEmail = "GUARD@TESTSECURITY.COM",
            EmailConfirmed = true,
            FirstName = "Test",
            LastName = "Guard",
            Role = "Guard",
            TenantId = testTenantId,
            EmployeeId = "EMP001",
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            SecurityStamp = Guid.NewGuid().ToString(),
            ConcurrencyStamp = Guid.NewGuid().ToString()
        };
        guard.PasswordHash = passwordHasher.HashPassword(guard, "Guard123!");

        modelBuilder.Entity<User>().HasData(platformOwner, companyAdmin, guard);

        // Seed user roles
        modelBuilder.Entity<IdentityUserRole<Guid>>().HasData(
            new IdentityUserRole<Guid> { UserId = platformOwnerId, RoleId = platformOwnerRoleId },
            new IdentityUserRole<Guid> { UserId = companyAdminId, RoleId = companyAdminRoleId },
            new IdentityUserRole<Guid> { UserId = guardId, RoleId = guardRoleId }
        );
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Automatically set UpdatedAt for modified entities
        var entries = ChangeTracker.Entries()
            .Where(e => e.Entity is BaseEntity && e.State == EntityState.Modified);

        foreach (var entry in entries)
        {
            ((BaseEntity)entry.Entity).UpdatedAt = DateTime.UtcNow;
        }

        return await base.SaveChangesAsync(cancellationToken);
    }
}
