namespace UserService.Models;

public class User
{
    public Guid Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class UserStat
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public int TotalQuizzes { get; set; }
    public int TotalPassed { get; set; }
    public int TotalFailed { get; set; }
    public long TotalScore { get; set; }
    public int BestScore { get; set; }
    public int TotalCorrectAnswers { get; set; }
    public int TotalQuestionsAnswered { get; set; }
    public int CurrentStreak { get; set; }
    public int BestStreak { get; set; }
    public DateTime? LastQuizAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
