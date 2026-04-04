using Microsoft.EntityFrameworkCore;
using UserService.Models;

namespace UserService.Data;

public class UserDbContext : DbContext
{
    public UserDbContext(DbContextOptions<UserDbContext> options) : base(options) { }
    public DbSet<User> Users { get; set; }
    public DbSet<UserStat> UserStats { get; set; }

    protected override void OnModelCreating(ModelBuilder m)
    {
        m.Entity<User>(e => {
            e.ToTable("users");
            e.HasKey(u => u.Id);
            e.Property(u => u.Id).HasColumnName("id");
            e.Property(u => u.Username).HasColumnName("username");
            e.Property(u => u.Email).HasColumnName("email");
            e.Property(u => u.AvatarUrl).HasColumnName("avatar_url");
            e.Property(u => u.IsActive).HasColumnName("is_active");
            e.Property(u => u.CreatedAt).HasColumnName("created_at");
            e.Property(u => u.UpdatedAt).HasColumnName("updated_at");
        });
        m.Entity<UserStat>(e => {
            e.ToTable("user_stats");
            e.HasKey(u => u.Id);
            e.Property(u => u.Id).HasColumnName("id");
            e.Property(u => u.UserId).HasColumnName("user_id");
            e.Property(u => u.TotalQuizzes).HasColumnName("total_quizzes");
            e.Property(u => u.TotalPassed).HasColumnName("total_passed");
            e.Property(u => u.TotalFailed).HasColumnName("total_failed");
            e.Property(u => u.TotalScore).HasColumnName("total_score");
            e.Property(u => u.BestScore).HasColumnName("best_score");
            e.Property(u => u.TotalCorrectAnswers).HasColumnName("total_correct_answers");
            e.Property(u => u.TotalQuestionsAnswered).HasColumnName("total_questions_answered");
            e.Property(u => u.CurrentStreak).HasColumnName("current_streak");
            e.Property(u => u.BestStreak).HasColumnName("best_streak");
            e.Property(u => u.LastQuizAt).HasColumnName("last_quiz_at");
            e.Property(u => u.UpdatedAt).HasColumnName("updated_at");
        });
    }
}
