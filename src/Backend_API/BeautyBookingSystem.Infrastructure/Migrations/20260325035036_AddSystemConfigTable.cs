using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace BeautyBookingSystem.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddSystemConfigTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_StoreOperatingHours_Stores_StoreId",
                table: "StoreOperatingHours");

            migrationBuilder.CreateTable(
                name: "SystemConfigs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Key = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Value = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SystemConfigs", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "SystemConfigs",
                columns: new[] { "Id", "CreatedAt", "Description", "Key", "UpdatedAt", "Value" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 3, 25, 3, 50, 34, 762, DateTimeKind.Utc).AddTicks(2691), "Tỷ lệ hoa hồng mặc định (%)", "DefaultCommissionRate", null, "10" },
                    { 2, new DateTime(2026, 3, 25, 3, 50, 34, 762, DateTimeKind.Utc).AddTicks(3323), "Phí duy trì mặc định hàng tháng (VNĐ)", "DefaultMonthlyAppFee", null, "50000" },
                    { 3, new DateTime(2026, 3, 25, 3, 50, 34, 762, DateTimeKind.Utc).AddTicks(3324), "Số ngày dùng thử miễn phí cho Cửa hàng mới duyệt", "FreeTrialDays", null, "30" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_SystemConfigs_Key",
                table: "SystemConfigs",
                column: "Key",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_StoreOperatingHours_Stores_StoreId",
                table: "StoreOperatingHours",
                column: "StoreId",
                principalTable: "Stores",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_StoreOperatingHours_Stores_StoreId",
                table: "StoreOperatingHours");

            migrationBuilder.DropTable(
                name: "SystemConfigs");

            migrationBuilder.AddForeignKey(
                name: "FK_StoreOperatingHours_Stores_StoreId",
                table: "StoreOperatingHours",
                column: "StoreId",
                principalTable: "Stores",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
