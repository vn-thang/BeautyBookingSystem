using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BeautyBookingSystem.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FixDecimalPrecision : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ServiceId",
                table: "Vouchers",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "DepositAmount",
                table: "Bookings",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.CreateIndex(
                name: "IX_Vouchers_ServiceId",
                table: "Vouchers",
                column: "ServiceId");

            migrationBuilder.AddForeignKey(
                name: "FK_Vouchers_Services_ServiceId",
                table: "Vouchers",
                column: "ServiceId",
                principalTable: "Services",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Vouchers_Services_ServiceId",
                table: "Vouchers");

            migrationBuilder.DropIndex(
                name: "IX_Vouchers_ServiceId",
                table: "Vouchers");

            migrationBuilder.DropColumn(
                name: "ServiceId",
                table: "Vouchers");

            migrationBuilder.DropColumn(
                name: "DepositAmount",
                table: "Bookings");
        }
    }
}
