using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BeautyBookingSystem.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddTypeAndGroupToSystemConfig : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Group",
                table: "SystemConfigs",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Type",
                table: "SystemConfigs",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

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
                columns: new[] { "CreatedAt", "Group", "Type" },
                values: new object[] { new DateTime(2026, 3, 28, 2, 49, 48, 697, DateTimeKind.Utc).AddTicks(9168), "General", "string" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Group",
                table: "SystemConfigs");

            migrationBuilder.DropColumn(
                name: "Type",
                table: "SystemConfigs");

            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 25, 3, 50, 34, 762, DateTimeKind.Utc).AddTicks(2691));

            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 25, 3, 50, 34, 762, DateTimeKind.Utc).AddTicks(3323));

            migrationBuilder.UpdateData(
                table: "SystemConfigs",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 25, 3, 50, 34, 762, DateTimeKind.Utc).AddTicks(3324));
        }
    }
}
