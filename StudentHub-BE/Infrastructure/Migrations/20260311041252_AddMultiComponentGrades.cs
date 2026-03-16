using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddMultiComponentGrades : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "FinalTestScore",
                table: "Grades",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "MiddleTestScore",
                table: "Grades",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "OralScore",
                table: "Grades",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "SmallTestScore",
                table: "Grades",
                type: "float",
                nullable: false,
                defaultValue: 0.0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FinalTestScore",
                table: "Grades");

            migrationBuilder.DropColumn(
                name: "MiddleTestScore",
                table: "Grades");

            migrationBuilder.DropColumn(
                name: "OralScore",
                table: "Grades");

            migrationBuilder.DropColumn(
                name: "SmallTestScore",
                table: "Grades");
        }
    }
}
