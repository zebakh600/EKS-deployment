namespace QuizService.DTOs;

public record TopicDto(Guid Id, string Name, string Slug, string? Description, string? Icon, string? Color, int QuestionCount);

public record QuestionDto(
    Guid Id,
    Guid TopicId,
    string QuestionText,
    string OptionA,
    string OptionB,
    string OptionC,
    string OptionD,
    string Difficulty,
    int QuestionNumber
);

public record QuestionResultDto(
    Guid Id,
    string QuestionText,
    string OptionA,
    string OptionB,
    string OptionC,
    string OptionD,
    string CorrectOption,
    string? Explanation,
    string? SelectedOption,
    bool IsCorrect
);

public record StartSessionRequest(Guid TopicId);

public record SessionDto(
    Guid SessionId,
    Guid TopicId,
    string TopicName,
    List<QuestionDto> Questions,
    DateTime StartedAt
);

public record SubmitAnswerRequest(Guid QuestionId, string? SelectedOption, int TimeTakenSeconds);

public record CompleteSessionRequest(
    List<SubmitAnswerRequest> Answers,
    int TotalTimeTakenSeconds
);

public record SessionResultDto(
    Guid SessionId,
    string TopicName,
    int TotalQuestions,
    int CorrectAnswers,
    int Score,
    bool Passed,
    int TimeTakenSeconds,
    List<QuestionResultDto> Results
);

public record LeaderboardEntryDto(
    int Rank,
    Guid UserId,
    string Username,
    string? AvatarUrl,
    int TotalQuizzes,
    int TotalPassed,
    int BestScore,
    long TotalScore,
    double AccuracyPercent
);

public record UserProgressDto(
    int TotalQuizzes,
    int TotalPassed,
    int TotalFailed,
    long TotalScore,
    int BestScore,
    double AccuracyPercent,
    int CurrentStreak,
    int BestStreak,
    List<RecentSessionDto> RecentSessions
);

public record RecentSessionDto(
    Guid SessionId,
    string TopicName,
    string? TopicIcon,
    string? TopicColor,
    int Score,
    bool Passed,
    DateTime CompletedAt
);
