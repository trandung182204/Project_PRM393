using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Migrations
{
    public partial class UpdateStudentImageUrlField : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // L?nh này ép SQL Server ph?i chuy?n c?t AvatarUrl sang cho phép NULL
            migrationBuilder.AlterColumn<string>(
                name: "AvatarUrl",
                table: "Students",
                type: "nvarchar(max)",
                nullable: true, // <--- ÐÂY LÀ CH?A KHÓA: Cho phép NULL
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // L?nh này dùng ð? rollback (quay xe) l?i tr?ng thái NOT NULL n?u c?n
            migrationBuilder.AlterColumn<string>(
                name: "AvatarUrl",
                table: "Students",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);
        }
    }
}
