using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BeautyBookingSystem.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddChatTablesAndUpdateBaseEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "Vouchers",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "Vouchers",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "UserVouchers",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "UserVouchers",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "SystemContents",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "SystemContents",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "Stores",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "Stores",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "StoreOperatingHours",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "StoreOperatingHours",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "Staffs",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "Staffs",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "Services",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "Services",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "ServiceGroups",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "ServiceGroups",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "SearchHistories",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "SearchHistories",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "Reviews",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "Reviews",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "Payments",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "Payments",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "Notifications",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "Notifications",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "GlobalCategories",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "GlobalCategories",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "CustomerFavorites",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "CustomerFavorites",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "Bookings",
            //     type: "datetime2",
            //     nullable: true);

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "CreatedAt",
            //     table: "BookingDetails",
            //     type: "datetime2",
            //     nullable: false,
            //     defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            // migrationBuilder.AddColumn<DateTime>(
            //     name: "UpdatedAt",
            //     table: "BookingDetails",
            //     type: "datetime2",
            //     nullable: true);

            migrationBuilder.CreateTable(
                name: "ChatSessions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    SessionKey = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    LastActivityAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatSessions_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ChatMessages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ChatSessionId = table.Column<int>(type: "int", nullable: false),
                    Role = table.Column<int>(type: "int", nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ToolName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    MetadataJson = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatMessages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatMessages_ChatSessions_ChatSessionId",
                        column: x => x.ChatSessionId,
                        principalTable: "ChatSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_ChatSessionId",
                table: "ChatMessages",
                column: "ChatSessionId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatSessions_UserId_SessionKey",
                table: "ChatSessions",
                columns: new[] { "UserId", "SessionKey" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ChatMessages");

            migrationBuilder.DropTable(
                name: "ChatSessions");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "Vouchers");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "Vouchers");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "UserVouchers");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "UserVouchers");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "SystemContents");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "SystemContents");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "Stores");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "Stores");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "StoreOperatingHours");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "StoreOperatingHours");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "Staffs");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "Staffs");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "Services");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "Services");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "ServiceGroups");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "ServiceGroups");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "SearchHistories");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "SearchHistories");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "Reviews");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "Reviews");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "Payments");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "Payments");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "Notifications");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "Notifications");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "GlobalCategories");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "GlobalCategories");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "CustomerFavorites");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "CustomerFavorites");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "Bookings");

            // migrationBuilder.DropColumn(
            //     name: "CreatedAt",
            //     table: "BookingDetails");

            // migrationBuilder.DropColumn(
            //     name: "UpdatedAt",
            //     table: "BookingDetails");
        }
    }
}
