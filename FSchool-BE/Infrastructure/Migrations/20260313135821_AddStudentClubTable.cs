using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddStudentClubTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Events_Clubs_ClubId",
                table: "Events");

            migrationBuilder.DropTable(
                name: "ClubStudent");

            migrationBuilder.AlterColumn<int>(
                name: "ClubId",
                table: "Events",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<decimal>(
                name: "Budget",
                table: "Events",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "MaxParticipants",
                table: "Events",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RoomId",
                table: "Events",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "Events",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "AdvisorStaffId",
                table: "Clubs",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "FoundedDate",
                table: "Clubs",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "Clubs",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "EventRegistrations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    EventId = table.Column<int>(type: "int", nullable: false),
                    StudentId = table.Column<int>(type: "int", nullable: false),
                    RegistrationDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    AttendanceStatus = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventRegistrations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EventRegistrations_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_EventRegistrations_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "StudentClubs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StudentId = table.Column<int>(type: "int", nullable: false),
                    ClubId = table.Column<int>(type: "int", nullable: false),
                    ClubRole = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    JoinDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    LeftDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StudentClubs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StudentClubs_Clubs_ClubId",
                        column: x => x.ClubId,
                        principalTable: "Clubs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_StudentClubs_Students_StudentId",
                        column: x => x.StudentId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Events_RoomId",
                table: "Events",
                column: "RoomId");

            migrationBuilder.CreateIndex(
                name: "IX_Clubs_AdvisorStaffId",
                table: "Clubs",
                column: "AdvisorStaffId");

            migrationBuilder.CreateIndex(
                name: "IX_EventRegistrations_EventId_StudentId",
                table: "EventRegistrations",
                columns: new[] { "EventId", "StudentId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_EventRegistrations_StudentId",
                table: "EventRegistrations",
                column: "StudentId");

            migrationBuilder.CreateIndex(
                name: "IX_StudentClubs_ClubId",
                table: "StudentClubs",
                column: "ClubId");

            migrationBuilder.CreateIndex(
                name: "IX_StudentClubs_StudentId_ClubId",
                table: "StudentClubs",
                columns: new[] { "StudentId", "ClubId" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Clubs_Staffs_AdvisorStaffId",
                table: "Clubs",
                column: "AdvisorStaffId",
                principalTable: "Staffs",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Events_Clubs_ClubId",
                table: "Events",
                column: "ClubId",
                principalTable: "Clubs",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Events_Rooms_RoomId",
                table: "Events",
                column: "RoomId",
                principalTable: "Rooms",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Clubs_Staffs_AdvisorStaffId",
                table: "Clubs");

            migrationBuilder.DropForeignKey(
                name: "FK_Events_Clubs_ClubId",
                table: "Events");

            migrationBuilder.DropForeignKey(
                name: "FK_Events_Rooms_RoomId",
                table: "Events");

            migrationBuilder.DropTable(
                name: "EventRegistrations");

            migrationBuilder.DropTable(
                name: "StudentClubs");

            migrationBuilder.DropIndex(
                name: "IX_Events_RoomId",
                table: "Events");

            migrationBuilder.DropIndex(
                name: "IX_Clubs_AdvisorStaffId",
                table: "Clubs");

            migrationBuilder.DropColumn(
                name: "Budget",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "MaxParticipants",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "RoomId",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "AdvisorStaffId",
                table: "Clubs");

            migrationBuilder.DropColumn(
                name: "FoundedDate",
                table: "Clubs");

            migrationBuilder.DropColumn(
                name: "Status",
                table: "Clubs");

            migrationBuilder.AlterColumn<int>(
                name: "ClubId",
                table: "Events",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.CreateTable(
                name: "ClubStudent",
                columns: table => new
                {
                    ClubsId = table.Column<int>(type: "int", nullable: false),
                    StudentsId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClubStudent", x => new { x.ClubsId, x.StudentsId });
                    table.ForeignKey(
                        name: "FK_ClubStudent_Clubs_ClubsId",
                        column: x => x.ClubsId,
                        principalTable: "Clubs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ClubStudent_Students_StudentsId",
                        column: x => x.StudentsId,
                        principalTable: "Students",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ClubStudent_StudentsId",
                table: "ClubStudent",
                column: "StudentsId");

            migrationBuilder.AddForeignKey(
                name: "FK_Events_Clubs_ClubId",
                table: "Events",
                column: "ClubId",
                principalTable: "Clubs",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
