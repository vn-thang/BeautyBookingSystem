using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace BeautyBookingSystem.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedMoreSystemConfigs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "Group", "Type" },
                values: new object[] { new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(3985), "Finance", "number" });

            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "Group", "Type" },
                values: new object[] { new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4929), "Finance", "number" });

            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "Type" },
                values: new object[] { new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4932), "number" });

            migrationBuilder.InsertData(
                table: "SystemConfigs",
                columns: new[] { "Id", "CreatedAt", "Description", "Group", "Key", "Type", "UpdatedAt", "Value" },
                values: new object[,]
                {
                    { 4, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4934), "Bật/tắt chế độ bảo trì toàn hệ thống", "General", "MAINTENANCE_MODE", "boolean", null, "false" },
                    { 5, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4935), "Số điện thoại tổng đài hỗ trợ", "General", "HOTLINE", "string", null, "1900 1234" },
                    { 6, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4936), "Email hỗ trợ khách hàng", "General", "SUPPORT_EMAIL", "string", null, "support@beautybooking.com" },
                    { 7, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4931), "Tỷ lệ phí Admin thu trên tiền cọc khi khách bùng lịch (%)", "Finance", "PENALTY_COMMISSION_PERCENT", "number", null, "15" },
                    { 8, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4937), "Khách hàng phải đặt trước tối thiểu bao nhiêu giờ", "Booking", "BOOKING_MIN_HOURS", "number", null, "1" },
                    { 9, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4938), "Số giờ tối thiểu để hủy lịch mà không bị phạt (mất cọc)", "Booking", "CANCEL_BEFORE_HOURS", "number", null, "2" },
                    { 10, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4939), "Thời gian giữ chỗ (phút) cho phép khách hàng đến trễ", "Booking", "GRACE_PERIOD_MINUTES", "number", null, "15" },
                    { 11, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4940), "Số lần tối đa khách hàng được phép hủy lịch trong 1 ngày", "Behavior", "MAX_CANCEL_PER_DAY", "number", null, "5" },
                    { 12, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4941), "Số lần 'Boom hàng' (No-show) tối đa trước khi bị khóa", "Behavior", "NOSHOW_LIMIT", "number", null, "5" },
                    { 13, new DateTime(2026, 3, 28, 3, 40, 24, 562, DateTimeKind.Utc).AddTicks(4942), "Tự động khóa tài khoản khách hàng nếu vượt giới hạn Boom hàng", "Behavior", "BLOCK_USER_IF_NOSHOW", "boolean", null, "true" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAt", "Group", "Type" },
                values: new object[] { new DateTime(2026, 3, 28, 2, 49, 48, 697, DateTimeKind.Utc).AddTicks(7700), "General", "string" });

            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAt", "Group", "Type" },
                values: new object[] { new DateTime(2026, 3, 28, 2, 49, 48, 697, DateTimeKind.Utc).AddTicks(9164), "General", "string" });

            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAt", "Type" },
                values: new object[] { new DateTime(2026, 3, 28, 2, 49, 48, 697, DateTimeKind.Utc).AddTicks(9168), "string" });
        }
    }
}
