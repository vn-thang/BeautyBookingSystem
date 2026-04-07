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

            migrationBuilder.AddColumn<decimal>(
                name: "DepositAmount",
                table: "Bookings",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);


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
                name: "DepositAmount",
                table: "Bookings");
        }
    }
}
