namespace QuizService.Models;

public class Topic
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Icon { get; set; }
    public string? Color { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public ICollection<Question> Questions { get; set; } = new List<Question>();
}

public class Question
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid TopicId { get; set; }
    public string QuestionText { get; set; } = string.Empty;
    public string OptionA { get; set; } = string.Empty;
    public string OptionB { get; set; } = string.Empty;
    public string OptionC { get; set; } = string.Empty;
    public string OptionD { get; set; } = string.Empty;
    public string CorrectOption { get; set; } = string.Empty;
    public string? Explanation { get; set; }
    public string Difficulty { get; set; } = "medium";
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public Topic Topic { get; set; } = null!;
}

public class QuizSession
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public Guid TopicId { get; set; }
    public int TotalQuestions { get; set; } = 10;
    public int CorrectAnswers { get; set; } = 0;
    public int Score { get; set; } = 0;
    public int TimeTakenSeconds { get; set; } = 0;
    public bool IsCompleted { get; set; } = false;
    public bool Passed { get; set; } = false;
    public int PassThreshold { get; set; } = 60;
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;
    public DateTime? CompletedAt { get; set; }
    public Topic Topic { get; set; } = null!;
    public ICollection<SessionAnswer> Answers { get; set; } = new List<SessionAnswer>();
}

public class SessionAnswer
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid SessionId { get; set; }
    public Guid QuestionId { get; set; }
    public string? SelectedOption { get; set; }
    public bool IsCorrect { get; set; } = false;
    public int TimeTakenSeconds { get; set; } = 0;
    public DateTime AnsweredAt { get; set; } = DateTime.UtcNow;
    public QuizSession Session { get; set; } = null!;
    public Question Question { get; set; } = null!;
}

// BUG FIX: Added Guid.NewGuid() default to prevent Guid.Empty on insert
public class UserStat
{
    public Guid Id { get; set; } = Guid.NewGuid();
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
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
