using BeautyBookingSystem.Domain.Common;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using System.Reflection;

Console.WriteLine("==============================================");
Console.WriteLine("   BEAUTY BOOKING - DATA MIGRATION");
Console.WriteLine("   SQL Server -> Neon PostgreSQL");
Console.WriteLine("==============================================");
Console.WriteLine();

// ======================================================
// 1. CONNECTION STRINGS
// ======================================================

var sqlServerConnection =
    "Server=localhost;Database=BeautyBookingDb;Trusted_Connection=True;TrustServerCertificate=True;";

var postgresConnection =
    Environment.GetEnvironmentVariable("NEON_CONNECTION_STRING");

if (string.IsNullOrWhiteSpace(postgresConnection))
{
    Console.WriteLine("ERROR: Chua co NEON_CONNECTION_STRING.");
    Console.WriteLine();
    Console.WriteLine("Hay set bien moi truong truoc khi chay:");
    Console.WriteLine();
    Console.WriteLine("$env:NEON_CONNECTION_STRING=\"Host=...;Port=5432;Database=neondb;Username=...;Password=...;SSL Mode=Require\"");
    Console.WriteLine();
    return;
}

// ======================================================
// 2. CREATE DB CONTEXTS
// ======================================================

var sqlOptions = new DbContextOptionsBuilder<AppDbContext>()
    .UseSqlServer(sqlServerConnection)
    .Options;

var postgresOptions = new DbContextOptionsBuilder<AppDbContext>()
    .UseNpgsql(postgresConnection)
    .Options;

await using var sourceDb = new AppDbContext(sqlOptions);

await using var targetDb = new AppDbContext(postgresOptions);

// Quan trọng:
// Không tự động thay đổi CreatedAt / UpdatedAt khi migration.
targetDb.SkipAuditTimestamps = true;

// ======================================================
// 3. TEST CONNECTION
// ======================================================

Console.WriteLine("[1/5] Kiem tra ket noi SQL Server...");

try
{
    if (!await sourceDb.Database.CanConnectAsync())
    {
        Console.WriteLine("ERROR: Khong ket noi duoc SQL Server.");
        return;
    }

    Console.WriteLine("      SQL Server: OK");
}
catch (Exception ex)
{
    Console.WriteLine("ERROR SQL Server:");
    Console.WriteLine(ex.Message);
    return;
}

Console.WriteLine();

Console.WriteLine("[2/5] Kiem tra ket noi Neon PostgreSQL...");

try
{
    if (!await targetDb.Database.CanConnectAsync())
    {
        Console.WriteLine("ERROR: Khong ket noi duoc Neon PostgreSQL.");
        return;
    }

    Console.WriteLine("      Neon PostgreSQL: OK");
}
catch (Exception ex)
{
    Console.WriteLine("ERROR Neon:");
    Console.WriteLine(ex.Message);
    return;
}

Console.WriteLine();

// ======================================================
// 4. CHECK TARGET DATA - SUPPORT RESUME
// ======================================================

Console.WriteLine("[3/5] Kiem tra du lieu tren Neon...");
Console.WriteLine();

var migrationItems = new[]
{
    ("Users", typeof(User)),
    ("Stores", typeof(Store)),
    ("StoreBanners", typeof(StoreBanner)),
    ("StoreOperatingHours", typeof(StoreOperatingHour)),
    ("Staffs", typeof(Staff)),
    ("GlobalCategories", typeof(GlobalCategory)),
    ("ServiceGroups", typeof(ServiceGroup)),
    ("Services", typeof(Service)),
    ("Vouchers", typeof(Voucher)),
    ("UserVouchers", typeof(UserVoucher)),
    ("Bookings", typeof(Booking)),
    ("BookingDetails", typeof(BookingDetail)),
    ("Payments", typeof(Payment)),
    ("CustomerFavorites", typeof(CustomerFavorite)),
    ("SearchHistories", typeof(SearchHistory)),
    ("Reviews", typeof(Review)),
    ("Notifications", typeof(Notification)),
    ("SystemContents", typeof(SystemContent)),
    ("ChatSessions", typeof(ChatSession)),
    ("ChatMessages", typeof(ChatMessage)),
    ("WalletTransactions", typeof(WalletTransaction)),
    ("WithdrawalRequests", typeof(WithdrawalRequest)),
    ("StaffSchedules", typeof(StaffSchedule)),
    ("StaffLeaves", typeof(StaffLeave))
};

var hasPartialData = false;

foreach (var (name, type) in migrationItems)
{
    var sourceCount = await GetCountAsync(
        sourceDb,
        type);

    var targetCount = await GetCountAsync(
        targetDb,
        type);

    // ==================================================
    // Target đã có đủ dữ liệu -> sẽ SKIP
    // ==================================================
    if (targetCount == sourceCount)
    {
        Console.WriteLine(
            $"SKIP : {name,-25} SQL={sourceCount,-6} Neon={targetCount}");
    }

    // ==================================================
    // Target chưa có dữ liệu -> sẵn sàng COPY
    // ==================================================
    else if (targetCount == 0)
    {
        Console.WriteLine(
            $"READY: {name,-25} SQL={sourceCount,-6} Neon=0 -> COPY");
    }

    // ==================================================
    // Target có một phần dữ liệu -> DỪNG
    // ==================================================
    else if (targetCount < sourceCount)
    {
        Console.WriteLine(
            $"WARNING: {name} dang co {targetCount}/{sourceCount} record.");

        hasPartialData = true;
    }

    // ==================================================
    // Target nhiều dữ liệu hơn source -> DỪNG
    // ==================================================
    else
    {
        Console.WriteLine(
            $"WARNING: {name} dang co {targetCount} record, " +
            $"nhieu hon SQL Server ({sourceCount}).");

        hasPartialData = true;
    }
}

// ======================================================
// 5. ABORT IF PARTIAL DATA EXISTS
// ======================================================

if (hasPartialData)
{
    Console.WriteLine();
    Console.WriteLine("==============================================");
    Console.WriteLine("KHONG THE TIEP TUC");
    Console.WriteLine("==============================================");
    Console.WriteLine();

    Console.WriteLine(
        "Phat hien bang dang co du lieu KHONG DAY DU.");

    Console.WriteLine(
        "Tool dung lai de tranh copy trung du lieu.");

    Console.WriteLine();

    Console.WriteLine(
        "Neu bang da co du du lieu thi se duoc SKIP.");

    Console.WriteLine();

    return;
}

Console.WriteLine();
Console.WriteLine(
    "      Neon san sang de RESUME migration.");

Console.WriteLine();

// ======================================================
// 6. CONFIRM
// ======================================================

Console.WriteLine("==============================================");
Console.WriteLine("SAN SANG COPY DU LIEU");
Console.WriteLine("==============================================");
Console.WriteLine();

Console.WriteLine("Nguon : SQL Server BeautyBookingDb");
Console.WriteLine("Dich  : Neon PostgreSQL");
Console.WriteLine();

Console.WriteLine(
    "Tool se KHONG XOA hoac thay doi SQL Server.");

Console.WriteLine(
    "Cac bang da copy day du se duoc BO QUA.");

Console.WriteLine();

Console.Write(
    "Nhan ENTER de bat dau, hoac Ctrl+C de huy...");

Console.ReadLine();

Console.WriteLine();
Console.WriteLine("Bat dau migration...");
Console.WriteLine();

// ======================================================
// 7. MIGRATION ORDER
// ======================================================

// Phải copy theo thứ tự FK.
//
// User
//   ↓
// Store / Category
//   ↓
// ServiceGroup / Staff
//   ↓
// Service
//   ↓
// Voucher
//   ↓
// Booking
//   ↓
// BookingDetail / Payment / Review
//   ↓
// Chat / Wallet / Notification...

var migrationOrder = new (string Name, Type Type)[]
{
    ("Users", typeof(User)),

    ("GlobalCategories", typeof(GlobalCategory)),

    ("Stores", typeof(Store)),

    ("ServiceGroups", typeof(ServiceGroup)),

    ("Staffs", typeof(Staff)),

    ("StoreBanners", typeof(StoreBanner)),

    ("StoreOperatingHours", typeof(StoreOperatingHour)),

    ("StaffSchedules", typeof(StaffSchedule)),

    ("StaffLeaves", typeof(StaffLeave)),

    ("Services", typeof(Service)),

    ("Vouchers", typeof(Voucher)),

    ("UserVouchers", typeof(UserVoucher)),

    ("CustomerFavorites", typeof(CustomerFavorite)),

    ("SearchHistories", typeof(SearchHistory)),

    ("Bookings", typeof(Booking)),

    ("BookingDetails", typeof(BookingDetail)),

    ("Payments", typeof(Payment)),

    ("Reviews", typeof(Review)),

    ("Notifications", typeof(Notification)),

    ("SystemContents", typeof(SystemContent)),

    ("ChatSessions", typeof(ChatSession)),

    ("ChatMessages", typeof(ChatMessage)),

    ("WalletTransactions", typeof(WalletTransaction)),

    ("WithdrawalRequests", typeof(WithdrawalRequest))
};

// ======================================================
// 8. COPY DATA
// ======================================================

var totalCopied = 0;

foreach (var (name, type) in migrationOrder)
{
    var sourceCount = await GetCountAsync(
        sourceDb,
        type);

    var targetCount = await GetCountAsync(
        targetDb,
        type);

    // Đã copy đầy đủ -> bỏ qua
    if (targetCount == sourceCount)
    {
        Console.WriteLine("----------------------------------------------");
        Console.WriteLine(
            $"SKIP: {name} da co du {targetCount} records.");

        continue;
    }

    // Target có dữ liệu nhưng chưa đầy đủ
    // Không copy để tránh duplicate
    if (targetCount > 0)
    {
        Console.WriteLine("----------------------------------------------");
        Console.WriteLine(
            $"WARNING: {name} dang co {targetCount}/{sourceCount} records.");

        Console.WriteLine(
            "Migration dung lai de tranh duplicate.");

        return;
    }

    Console.WriteLine("----------------------------------------------");
    Console.WriteLine($"Copying {name}...");

    try
    {
        var copied = await CopyEntityAsync(
            sourceDb,
            targetDb,
            type);

        totalCopied += copied;

        Console.WriteLine(
            $"OK: {name} -> {copied} records");
    }
    catch (Exception ex)
    {
        Console.WriteLine();
        Console.WriteLine($"ERROR khi copy {name}:");
        Console.WriteLine();

        // In toàn bộ exception + InnerException
        Console.WriteLine(ex.ToString());

        Console.WriteLine();
        Console.WriteLine(
            "Migration dung lai de tranh du lieu khong dong bo.");

        return;
    }
}

Console.WriteLine();

// ======================================================
// 9. RESET POSTGRESQL SEQUENCES
// ======================================================

Console.WriteLine("[4/5] Reset PostgreSQL sequences...");
Console.WriteLine();

foreach (var (_, type) in migrationOrder)
{
    try
    {
        await ResetSequenceAsync(targetDb, type);
    }
    catch (Exception ex)
    {
        Console.WriteLine(
            $"WARNING: Khong reset duoc sequence cho {type.Name}: {ex.Message}");
    }
}

// SystemConfig cũng có Id identity/sequence.
// Dù không copy dữ liệu nhưng vẫn reset sequence
// dựa trên 14 dòng seed hiện tại.

try
{
    await ResetSequenceAsync(
        targetDb,
        typeof(SystemConfig));
}
catch (Exception ex)
{
    Console.WriteLine(
        $"WARNING: Khong reset sequence SystemConfig: {ex.Message}");
}

// ======================================================
// 10. VERIFY
// ======================================================

Console.WriteLine();
Console.WriteLine("[5/5] Kiem tra lai so luong record...");
Console.WriteLine();

var verificationFailed = false;

foreach (var (name, type) in migrationOrder)
{
    var sourceCount = await GetCountAsync(
        sourceDb,
        type);

    var targetCount = await GetCountAsync(
        targetDb,
        type);

    var status =
        sourceCount == targetCount
            ? "OK"
            : "ERROR";

    Console.WriteLine(
        $"{status,-5} {name,-25} SQL={sourceCount,-6} Neon={targetCount}");

    if (sourceCount != targetCount)
    {
        verificationFailed = true;
    }
}

Console.WriteLine();
Console.WriteLine("==============================================");

if (verificationFailed)
{
    Console.WriteLine("MIGRATION CO THE CHUA HOAN TAT");
}
else
{
    Console.WriteLine("MIGRATION THANH CONG!");
}

Console.WriteLine("==============================================");
Console.WriteLine();
Console.WriteLine($"Tong record da copy: {totalCopied}");
Console.WriteLine();


// ======================================================
// FUNCTIONS
// ======================================================

static async Task<int> GetCountAsync(
    AppDbContext db,
    Type entityType)
{
    var setMethod = typeof(DbContext)
        .GetMethods(BindingFlags.Public | BindingFlags.Instance)
        .First(m =>
            m.Name == nameof(DbContext.Set) &&
            m.IsGenericMethodDefinition &&
            m.GetParameters().Length == 0);

    var genericSetMethod = setMethod.MakeGenericMethod(entityType);

    var queryable = genericSetMethod.Invoke(
        db,
        null)!;

    var countMethod = typeof(Queryable)
        .GetMethods(BindingFlags.Public | BindingFlags.Static)
        .First(m =>
            m.Name == nameof(Queryable.Count) &&
            m.IsGenericMethodDefinition &&
            m.GetParameters().Length == 1);

    var genericCountMethod =
        countMethod.MakeGenericMethod(entityType);

    return (int)genericCountMethod.Invoke(
        null,
        new[] { queryable })!;
}


static async Task<int> CopyEntityAsync(
    AppDbContext sourceDb,
    AppDbContext targetDb,
    Type entityType)
{
    // ==================================================
    // 1. Lấy DbSet<TEntity> của SQL Server
    // ==================================================

    var setMethod = typeof(DbContext)
        .GetMethods(BindingFlags.Public | BindingFlags.Instance)
        .First(m =>
            m.Name == nameof(DbContext.Set) &&
            m.IsGenericMethodDefinition &&
            m.GetParameters().Length == 0);

    var genericSetMethod =
        setMethod.MakeGenericMethod(entityType);

    var sourceSet =
        genericSetMethod.Invoke(sourceDb, null)!;


    // ==================================================
    // 2. ToListAsync<TEntity>()
    // ==================================================

    var toListMethod =
        typeof(EntityFrameworkQueryableExtensions)
            .GetMethods(
                BindingFlags.Public |
                BindingFlags.Static)
            .First(m =>
                m.Name == nameof(
                    EntityFrameworkQueryableExtensions.ToListAsync)
                && m.IsGenericMethodDefinition
                && m.GetParameters().Length == 2);

    var genericToListMethod =
        toListMethod.MakeGenericMethod(entityType);

    var task =
        (Task)genericToListMethod.Invoke(
            null,
            new object[]
            {
                sourceSet,
                CancellationToken.None
            })!;

    await task;

    var resultProperty =
        task.GetType().GetProperty("Result");

    var sourceEntities =
        (System.Collections.IList)
            resultProperty!.GetValue(task)!;


    // ==================================================
    // 3. Không có dữ liệu
    // ==================================================

    if (sourceEntities.Count == 0)
    {
        return 0;
    }


    // ==================================================
    // 4. Tạo entity mới
    //    CHỈ COPY SCALAR PROPERTIES
    //    KHÔNG COPY NAVIGATION PROPERTIES
    // ==================================================

    var cleanEntities =
        (System.Collections.IList)
            Activator.CreateInstance(
                typeof(List<>).MakeGenericType(entityType))!;

    var properties =
        entityType
            .GetProperties(
                BindingFlags.Public |
                BindingFlags.Instance)
            .Where(p =>
                p.CanRead &&
                p.CanWrite &&
                IsScalarProperty(p.PropertyType))
            .ToList();


    foreach (var sourceEntity in sourceEntities)
    {
        var newEntity =
            Activator.CreateInstance(entityType)!;

        foreach (var property in properties)
        {
            var value =
                property.GetValue(sourceEntity);

            property.SetValue(
                newEntity,
                value);
        }

        // Chuẩn hóa DateTime
        NormalizeDateTimes(newEntity);

        cleanEntities.Add(newEntity);
    }


    // ==================================================
    // 5. Add vào PostgreSQL
    // ==================================================

    var addEntitiesMethod =
        typeof(ProgramHelpers)
            .GetMethod(
                nameof(
                    ProgramHelpers.AddEntitiesAsync),
                BindingFlags.Public |
                BindingFlags.Static)!;

    var genericAddEntitiesMethod =
        addEntitiesMethod.MakeGenericMethod(entityType);

    var addTask =
        (Task)genericAddEntitiesMethod.Invoke(
            null,
            new object[]
            {
                targetDb,
                cleanEntities
            })!;

    await addTask;

    return cleanEntities.Count;
}


static void NormalizeDateTimes(object entity)
{
    var properties = entity
        .GetType()
        .GetProperties(
            BindingFlags.Public |
            BindingFlags.Instance)
        .Where(p => p.CanRead && p.CanWrite);

    foreach (var property in properties)
    {
        if (property.PropertyType == typeof(DateTime))
        {
            var value =
                (DateTime)property.GetValue(entity)!;

            if (value != default)
            {
                property.SetValue(
                    entity,
                    DateTime.SpecifyKind(
                        value,
                        DateTimeKind.Utc));
            }
        }
        else if (
            property.PropertyType == typeof(DateTime?))
        {
            var value =
                (DateTime?)property.GetValue(entity);

            if (value.HasValue)
            {
                property.SetValue(
                    entity,
                    DateTime.SpecifyKind(
                        value.Value,
                        DateTimeKind.Utc));
            }
        }
    }
}


static async Task ResetSequenceAsync(
    AppDbContext db,
    Type entityType)
{
    var entityTypeMetadata =
        db.Model.FindEntityType(entityType);

    if (entityTypeMetadata == null)
    {
        return;
    }

    var tableName =
        entityTypeMetadata.GetTableName();

    var schema =
        entityTypeMetadata.GetSchema()
        ?? "public";

    if (string.IsNullOrWhiteSpace(tableName))
    {
        return;
    }

    // BaseEntity của project dùng Id làm primary key.
    var idProperty =
        entityTypeMetadata.FindProperty("Id");

    if (idProperty == null)
    {
        return;
    }

    var quotedTable =
        $"{QuoteIdentifier(schema)}.{QuoteIdentifier(tableName)}";

    await using var connection =
        new NpgsqlConnection(
            db.Database.GetConnectionString());

    await connection.OpenAsync();

    // Lấy sequence tương ứng với Id.
    await using var sequenceCommand =
        new NpgsqlCommand(
            $"""
            SELECT pg_get_serial_sequence(
                '{EscapeSqlLiteral(quotedTable)}',
                'Id'
            );
            """,
            connection);

    var sequenceResult =
        await sequenceCommand.ExecuteScalarAsync();

    if (sequenceResult == null ||
        sequenceResult == DBNull.Value)
    {
        return;
    }

    var sequenceName =
        sequenceResult.ToString();

    if (string.IsNullOrWhiteSpace(sequenceName))
    {
        return;
    }

    // Nếu MAX(Id) = 100
    // thì sequence được đặt thành 101,
    // next INSERT sẽ dùng 101.
    var sql =
        $"""
        SELECT setval(
            '{EscapeSqlLiteral(sequenceName)}',
            COALESCE(
                (
                    SELECT MAX("Id")
                    FROM {quotedTable}
                ),
                0
            ) + 1,
            false
        );
        """;

    await using var command =
        new NpgsqlCommand(
            sql,
            connection);

    await command.ExecuteScalarAsync();
}


static string QuoteIdentifier(string identifier)
{
    return "\"" +
           identifier.Replace("\"", "\"\"") +
           "\"";
}


static string EscapeSqlLiteral(string value)
{
    return value.Replace("'", "''");
}
static bool IsScalarProperty(Type type)
{
    type = Nullable.GetUnderlyingType(type) ?? type;

    return
        type.IsPrimitive ||
        type.IsEnum ||
        type == typeof(string) ||
        type == typeof(decimal) ||
        type == typeof(DateTime) ||
        type == typeof(DateTimeOffset) ||
        type == typeof(TimeSpan) ||
        type == typeof(Guid) ||
        type == typeof(byte[]);
}
static class ProgramHelpers
{
    public static async Task AddEntitiesAsync<TEntity>(
        AppDbContext targetDb,
        System.Collections.IList entities)
        where TEntity : class
    {
        var targetSet =
            targetDb.Set<TEntity>();

        const int batchSize = 500;

        for (var i = 0; i < entities.Count; i += batchSize)
        {
            var count = Math.Min(
                batchSize,
                entities.Count - i);

            var batch = new List<TEntity>(count);

            for (var j = 0; j < count; j++)
            {
                batch.Add(
                    (TEntity)entities[i + j]!);
            }

            targetSet.AddRange(batch);

            try
{
    await targetDb.SaveChangesAsync();
}
catch (Exception ex)
{
    Console.WriteLine();
    Console.WriteLine("===== CHI TIET LOI DATABASE =====");
    Console.WriteLine(ex.ToString());
    Console.WriteLine("=================================");
    Console.WriteLine();

    throw;
}

            targetDb.ChangeTracker.Clear();
        }
    }
}