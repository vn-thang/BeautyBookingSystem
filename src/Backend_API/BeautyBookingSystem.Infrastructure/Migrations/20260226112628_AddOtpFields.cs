using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BeautyBookingSystem.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddOtpFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "OtpExpiryTime",
                table: "Users",
                newName: "ResetPasswordOtpExpiry");

            migrationBuilder.RenameColumn(
                name: "OtpCode",
                table: "Users",
                newName: "ResetPasswordOtp");

            migrationBuilder.AlterColumn<string>(
                name: "Email",
                table: "Users",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ResetPasswordOtpExpiry",
                table: "Users",
                newName: "OtpExpiryTime");

            migrationBuilder.RenameColumn(
                name: "ResetPasswordOtp",
                table: "Users",
                newName: "OtpCode");

            migrationBuilder.AlterColumn<string>(
                name: "Email",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");
        }
    }
}
