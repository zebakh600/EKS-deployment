namespace UserService.DTOs;

public record UserProfileDto(
    Guid Id, string Username, string Email,
    string? AvatarUrl, DateTime CreatedAt,
    UserStatsDto? Stats
);

public record UserStatsDto(
    int TotalQuizzes, int TotalPassed, int TotalFailed,
    long TotalScore, int BestScore, double AccuracyPercent,
    int CurrentStreak, int BestStreak, DateTime? LastQuizAt
);

public record UpdateProfileRequest(string? AvatarUrl);
