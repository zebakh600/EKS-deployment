using Microsoft.EntityFrameworkCore;
using QuizService.Data;
using QuizService.DTOs;
using QuizService.Models;

namespace QuizService.Services;

public interface IQuizService
{
    Task<List<TopicDto>> GetTopicsAsync();
    Task<SessionDto?> StartSessionAsync(Guid userId, Guid topicId);
    Task<SessionResultDto?> CompleteSessionAsync(Guid userId, Guid sessionId, CompleteSessionRequest req);
    Task<List<LeaderboardEntryDto>> GetLeaderboardAsync(int limit);
    Task<UserProgressDto?> GetUserProgressAsync(Guid userId);
    Task<List<RecentSessionDto>> GetUserSessionsAsync(Guid userId);
    Task EnsureUserStatsAsync(Guid userId);
}

public class QuizServiceImpl : IQuizService
{
    private readonly QuizDbContext _db;

    public QuizServiceImpl(QuizDbContext db) => _db = db;

    public async Task<List<TopicDto>> GetTopicsAsync()
    {
        return await _db.Topics
            .Where(t => t.IsActive)
            .Select(t => new TopicDto(
                t.Id, t.Name, t.Slug, t.Description, t.Icon, t.Color,
                t.Questions.Count(q => q.IsActive)))
            .ToListAsync();
    }

    public async Task<SessionDto?> StartSessionAsync(Guid userId, Guid topicId)
    {
        var topic = await _db.Topics.FindAsync(topicId);
        if (topic == null || !topic.IsActive) return null;

        // BUG FIX: EF.Functions.Random() translates to RANDOM() in PostgreSQL
        // Guid.NewGuid() in OrderBy is NOT translatable to SQL
        var questions = await _db.Questions
            .Where(q => q.TopicId == topicId && q.IsActive)
            .OrderBy(q => EF.Functions.Random())
            .Take(10)
            .ToListAsync();

        if (questions.Count < 5) return null;

        var session = new QuizSession
        {
            UserId = userId,
            TopicId = topicId,
            TotalQuestions = questions.Count
        };
        _db.QuizSessions.Add(session);
        await _db.SaveChangesAsync();

        var questionDtos = questions.Select((q, i) => new QuestionDto(
            q.Id, q.TopicId, q.QuestionText,
            q.OptionA, q.OptionB, q.OptionC, q.OptionD, q.Difficulty, i + 1)).ToList();

        return new SessionDto(session.Id, topic.Id, topic.Name, questionDtos, session.StartedAt);
    }

    public async Task<SessionResultDto?> CompleteSessionAsync(Guid userId, Guid sessionId, CompleteSessionRequest req)
    {
        var session = await _db.QuizSessions
            .Include(s => s.Topic)
            .FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId && !s.IsCompleted);

        if (session == null) return null;

        var questionIds = req.Answers.Select(a => a.QuestionId).ToList();
        var questions = await _db.Questions
            .Where(q => questionIds.Contains(q.Id))
            .ToDictionaryAsync(q => q.Id);

        var results = new List<QuestionResultDto>();
        int correct = 0;

        foreach (var answer in req.Answers)
        {
            if (!questions.TryGetValue(answer.QuestionId, out var question)) continue;
            var isCorrect = string.Equals(answer.SelectedOption, question.CorrectOption, StringComparison.OrdinalIgnoreCase);
            if (isCorrect) correct++;

            _db.SessionAnswers.Add(new SessionAnswer
            {
                SessionId = sessionId,
                QuestionId = answer.QuestionId,
                SelectedOption = answer.SelectedOption?.ToUpper(),
                IsCorrect = isCorrect,
                TimeTakenSeconds = answer.TimeTakenSeconds
            });

            results.Add(new QuestionResultDto(
                question.Id, question.QuestionText,
                question.OptionA, question.OptionB, question.OptionC, question.OptionD,
                question.CorrectOption, question.Explanation,
                answer.SelectedOption?.ToUpper(), isCorrect));
        }

        int score = session.TotalQuestions > 0
            ? (int)Math.Round((double)correct / session.TotalQuestions * 100) : 0;

        session.CorrectAnswers = correct;
        session.Score = score;
        session.TimeTakenSeconds = req.TotalTimeTakenSeconds;
        session.IsCompleted = true;
        session.Passed = score >= session.PassThreshold;
        session.CompletedAt = DateTime.UtcNow;

        await UpdateUserStatsAsync(userId, session);
        await _db.SaveChangesAsync();

        return new SessionResultDto(
            session.Id, session.Topic.Name, session.TotalQuestions,
            correct, score, session.Passed, req.TotalTimeTakenSeconds, results);
    }

    private async Task UpdateUserStatsAsync(Guid userId, QuizSession session)
    {
        var stats = await _db.UserStats.FirstOrDefaultAsync(u => u.UserId == userId);
        if (stats == null)
        {
            stats = new UserStat { UserId = userId };
            _db.UserStats.Add(stats);
        }

        stats.TotalQuizzes++;
        stats.TotalQuestionsAnswered += session.TotalQuestions;
        stats.TotalCorrectAnswers += session.CorrectAnswers;
        stats.TotalScore += session.Score;
        stats.LastQuizAt = DateTime.UtcNow;
        stats.UpdatedAt = DateTime.UtcNow;
        if (session.Score > stats.BestScore) stats.BestScore = session.Score;
        if (session.Passed)
        {
            stats.TotalPassed++;
            stats.CurrentStreak++;
            if (stats.CurrentStreak > stats.BestStreak) stats.BestStreak = stats.CurrentStreak;
        }
        else
        {
            stats.TotalFailed++;
            stats.CurrentStreak = 0;
        }
    }

    public async Task<List<LeaderboardEntryDto>> GetLeaderboardAsync(int limit = 50)
    {
        var data = await _db.UserStats
            .Join(_db.LeaderboardUsers, us => us.UserId, u => u.Id, (us, u) => new { us, u })
            .Where(x => x.u.IsActive)
            .OrderByDescending(x => x.us.TotalScore)
            .ThenByDescending(x => x.us.TotalPassed)
            .Take(limit)
            .Select(x => new
            {
                x.u.Id,
                x.u.Username,
                x.u.AvatarUrl,
                x.us.TotalQuizzes,
                x.us.TotalPassed,
                x.us.BestScore,
                x.us.TotalScore,
                x.us.TotalCorrectAnswers,
                x.us.TotalQuestionsAnswered
            })
            .ToListAsync();

        return data.Select((x, i) => new LeaderboardEntryDto(
            i + 1, x.Id, x.Username, x.AvatarUrl,
            x.TotalQuizzes, x.TotalPassed, x.BestScore, x.TotalScore,
            x.TotalQuestionsAnswered > 0
                ? Math.Round((double)x.TotalCorrectAnswers / x.TotalQuestionsAnswered * 100, 1) : 0
        )).ToList();
    }

    public async Task<UserProgressDto?> GetUserProgressAsync(Guid userId)
    {
        var stats = await _db.UserStats.FirstOrDefaultAsync(u => u.UserId == userId);
        var recent = await GetUserSessionsAsync(userId);
        if (stats == null)
            return new UserProgressDto(0, 0, 0, 0, 0, 0, 0, 0, recent);

        double accuracy = stats.TotalQuestionsAnswered > 0
            ? Math.Round((double)stats.TotalCorrectAnswers / stats.TotalQuestionsAnswered * 100, 1) : 0;

        return new UserProgressDto(
            stats.TotalQuizzes, stats.TotalPassed, stats.TotalFailed,
            stats.TotalScore, stats.BestScore, accuracy,
            stats.CurrentStreak, stats.BestStreak, recent);
    }

    public async Task<List<RecentSessionDto>> GetUserSessionsAsync(Guid userId)
    {
        return await _db.QuizSessions
            .Include(s => s.Topic)
            .Where(s => s.UserId == userId && s.IsCompleted)
            .OrderByDescending(s => s.CompletedAt)
            .Take(20)
            .Select(s => new RecentSessionDto(
                s.Id, s.Topic.Name, s.Topic.Icon, s.Topic.Color,
                s.Score, s.Passed, s.CompletedAt ?? s.StartedAt))
            .ToListAsync();
    }

    public async Task EnsureUserStatsAsync(Guid userId)
    {
        if (!await _db.UserStats.AnyAsync(u => u.UserId == userId))
        {
            _db.UserStats.Add(new UserStat { UserId = userId, UpdatedAt = DateTime.UtcNow });
            await _db.SaveChangesAsync();
        }
    }
}
