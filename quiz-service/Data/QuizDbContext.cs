using Microsoft.EntityFrameworkCore;
using QuizService.Models;

namespace QuizService.Data;

public class LeaderboardUser
{
    public Guid Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public bool IsActive { get; set; }
}

public class QuizDbContext : DbContext
{
    public QuizDbContext(DbContextOptions<QuizDbContext> options) : base(options) { }

    public DbSet<Topic> Topics { get; set; }
    public DbSet<Question> Questions { get; set; }
    public DbSet<QuizSession> QuizSessions { get; set; }
    public DbSet<SessionAnswer> SessionAnswers { get; set; }
    public DbSet<UserStat> UserStats { get; set; }
    public DbSet<LeaderboardUser> LeaderboardUsers { get; set; }

    protected override void OnModelCreating(ModelBuilder m)
    {
        m.Entity<Topic>(e => {
            e.ToTable("topics");
            e.HasKey(t => t.Id); e.Property(t => t.Id).HasColumnName("id");
            e.Property(t => t.Name).HasColumnName("name"); e.Property(t => t.Slug).HasColumnName("slug");
            e.Property(t => t.Description).HasColumnName("description"); e.Property(t => t.Icon).HasColumnName("icon");
            e.Property(t => t.Color).HasColumnName("color"); e.Property(t => t.IsActive).HasColumnName("is_active");
            e.Property(t => t.CreatedAt).HasColumnName("created_at");
        });
        m.Entity<Question>(e => {
            e.ToTable("questions");
            e.HasKey(q => q.Id); e.Property(q => q.Id).HasColumnName("id");
            e.Property(q => q.TopicId).HasColumnName("topic_id");
            e.Property(q => q.QuestionText).HasColumnName("question_text");
            e.Property(q => q.OptionA).HasColumnName("option_a"); e.Property(q => q.OptionB).HasColumnName("option_b");
            e.Property(q => q.OptionC).HasColumnName("option_c"); e.Property(q => q.OptionD).HasColumnName("option_d");
            e.Property(q => q.CorrectOption).HasColumnName("correct_option");
            e.Property(q => q.Explanation).HasColumnName("explanation");
            e.Property(q => q.Difficulty).HasColumnName("difficulty");
            e.Property(q => q.IsActive).HasColumnName("is_active"); e.Property(q => q.CreatedAt).HasColumnName("created_at");
            e.HasOne(q => q.Topic).WithMany(t => t.Questions).HasForeignKey(q => q.TopicId);
        });
        m.Entity<QuizSession>(e => {
            e.ToTable("quiz_sessions");
            e.HasKey(s => s.Id); e.Property(s => s.Id).HasColumnName("id");
            e.Property(s => s.UserId).HasColumnName("user_id"); e.Property(s => s.TopicId).HasColumnName("topic_id");
            e.Property(s => s.TotalQuestions).HasColumnName("total_questions");
            e.Property(s => s.CorrectAnswers).HasColumnName("correct_answers");
            e.Property(s => s.Score).HasColumnName("score"); e.Property(s => s.TimeTakenSeconds).HasColumnName("time_taken_seconds");
            e.Property(s => s.IsCompleted).HasColumnName("is_completed"); e.Property(s => s.Passed).HasColumnName("passed");
            e.Property(s => s.PassThreshold).HasColumnName("pass_threshold");
            e.Property(s => s.StartedAt).HasColumnName("started_at"); e.Property(s => s.CompletedAt).HasColumnName("completed_at");
            e.HasOne(s => s.Topic).WithMany().HasForeignKey(s => s.TopicId);
        });
        m.Entity<SessionAnswer>(e => {
            e.ToTable("session_answers");
            e.HasKey(a => a.Id); e.Property(a => a.Id).HasColumnName("id");
            e.Property(a => a.SessionId).HasColumnName("session_id"); e.Property(a => a.QuestionId).HasColumnName("question_id");
            e.Property(a => a.SelectedOption).HasColumnName("selected_option");
            e.Property(a => a.IsCorrect).HasColumnName("is_correct");
            e.Property(a => a.TimeTakenSeconds).HasColumnName("time_taken_seconds");
            e.Property(a => a.AnsweredAt).HasColumnName("answered_at");
            e.HasOne(a => a.Session).WithMany(s => s.Answers).HasForeignKey(a => a.SessionId);
            e.HasOne(a => a.Question).WithMany().HasForeignKey(a => a.QuestionId);
        });
        m.Entity<UserStat>(e => {
            e.ToTable("user_stats");
            e.HasKey(u => u.Id); e.Property(u => u.Id).HasColumnName("id");
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
        m.Entity<LeaderboardUser>(e => {
            e.ToTable("users");
            e.HasKey(u => u.Id); e.Property(u => u.Id).HasColumnName("id");
            e.Property(u => u.Username).HasColumnName("username");
            e.Property(u => u.AvatarUrl).HasColumnName("avatar_url");
            e.Property(u => u.IsActive).HasColumnName("is_active");
        });
    }
}
