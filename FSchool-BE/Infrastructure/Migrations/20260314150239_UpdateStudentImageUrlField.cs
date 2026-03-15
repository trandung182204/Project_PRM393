using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Migrations
{
    public partial class UpdateStudentImageUrlField : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Lệnh này ép SQL Server phải chuyển cột AvatarUrl sang cho phép NULL
            migrationBuilder.AlterColumn<string>(
                name: "AvatarUrl",
                table: "Students",
                type: "nvarchar(max)",
                nullable: true, // <--- ĐÂY LÀ CHÌA KHÓA: Cho phép NULL
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Lệnh này dùng để rollback (quay xe) lại trạng thái NOT NULL nếu cần
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