namespace Infrastructure.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<Account> Accounts { get; set; }
        public DbSet<Student> Students { get; set; }
        public DbSet<Staff> Staffs { get; set; }
        public DbSet<SchoolClass> Classes { get; set; }
        public DbSet<Subject> Subjects { get; set; }
        public DbSet<Room> Rooms { get; set; }
        public DbSet<Semester> Semesters { get; set; }
        public DbSet<Shift> Shifts { get; set; }
        public DbSet<Slot> Slots { get; set; }
        public DbSet<Schedule> Schedules { get; set; }
        public DbSet<Attendance> Attendances { get; set; }
        public DbSet<Grade> Grades { get; set; }
        public DbSet<AbsenceRequest> AbsenceRequests { get; set; }
        public DbSet<Event> Events { get; set; }
        public DbSet<Club> Clubs { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<StudentClub> StudentClubs { get; set; }
        public DbSet<EventRegistration> EventRegistrations { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Cấu hình N-N cho Account - Role
            modelBuilder.Entity<Account>()
                .HasMany(a => a.Roles)
                .WithMany(r => r.Accounts)
                .UsingEntity(j => j.ToTable("AccountRoles"));

            // Cấu hình 1-1 cho Account - Student
            modelBuilder.Entity<Student>()
                .HasOne(s => s.Account)
                .WithOne(a => a.Student)
                .HasForeignKey<Student>(s => s.AccountId);

            // Cấu hình 1-1 cho Account - Staff
            modelBuilder.Entity<Staff>()
                .HasOne(s => s.Account)
                .WithOne(a => a.Staff)
                .HasForeignKey<Staff>(s => s.AccountId);

            modelBuilder.Entity<Attendance>()
                .HasOne(a => a.Student)
                .WithMany(s => s.Attendances)
                .HasForeignKey(a => a.StudentId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Attendance>()
                .HasOne(a => a.Schedule)
                .WithMany(s => s.Attendances)
                .HasForeignKey(a => a.ScheduleId)
                .OnDelete(DeleteBehavior.Restrict);

            // StudentClub: unique constraint on (StudentId, ClubId)
            modelBuilder.Entity<StudentClub>()
                .HasIndex(sc => new { sc.StudentId, sc.ClubId })
                .IsUnique();

            modelBuilder.Entity<StudentClub>()
                .HasOne(sc => sc.Student)
                .WithMany(s => s.StudentClubs)
                .HasForeignKey(sc => sc.StudentId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<StudentClub>()
                .HasOne(sc => sc.Club)
                .WithMany(c => c.StudentClubs)
                .HasForeignKey(sc => sc.ClubId)
                .OnDelete(DeleteBehavior.Restrict);

            // EventRegistration: unique constraint on (EventId, StudentId)
            modelBuilder.Entity<EventRegistration>()
                .HasIndex(er => new { er.EventId, er.StudentId })
                .IsUnique();

            modelBuilder.Entity<EventRegistration>()
                .HasOne(er => er.Event)
                .WithMany(e => e.Registrations)
                .HasForeignKey(er => er.EventId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<EventRegistration>()
                .HasOne(er => er.Student)
                .WithMany(s => s.EventRegistrations)
                .HasForeignKey(er => er.StudentId)
                .OnDelete(DeleteBehavior.Restrict);

            // Club - AdvisorStaff (optional)
            modelBuilder.Entity<Club>()
                .HasOne(c => c.AdvisorStaff)
                .WithMany()
                .HasForeignKey(c => c.AdvisorStaffId)
                .OnDelete(DeleteBehavior.SetNull);

            base.OnModelCreating(modelBuilder);
        }
    }
}
