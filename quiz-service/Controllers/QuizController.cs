using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using QuizService.DTOs;
using QuizService.Services;
using System.Security.Claims;

namespace QuizService.Controllers;

[ApiController]
[Route("api/quiz")]
[Authorize]
public class QuizController : ControllerBase
{
    private readonly IQuizService _quiz;
    private readonly ILogger<QuizController> _logger;

    public QuizController(IQuizService quiz, ILogger<QuizController> logger)
    {
        _quiz = quiz;
        _logger = logger;
    }

    // BUG FIX: Use "sub" directly since DefaultInboundClaimTypeMap is cleared
    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }

    [HttpGet("topics")]
    [AllowAnonymous]
    public async Task<IActionResult> GetTopics()
    {
        var topics = await _quiz.GetTopicsAsync();
        return Ok(topics);
    }

    [HttpPost("sessions/start")]
    public async Task<IActionResult> StartSession([FromBody] StartSessionRequest req)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized(new { message = "Invalid token." });

        await _quiz.EnsureUserStatsAsync(userId);
        var session = await _quiz.StartSessionAsync(userId, req.TopicId);
        if (session == null)
            return BadRequest(new { message = "Topic not found or insufficient questions." });

        _logger.LogInformation("Session started: User {UserId}, Topic {TopicId}", userId, req.TopicId);
        return Ok(session);
    }

    [HttpPost("sessions/{sessionId}/complete")]
    public async Task<IActionResult> CompleteSession(Guid sessionId, [FromBody] CompleteSessionRequest req)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized(new { message = "Invalid token." });

        var result = await _quiz.CompleteSessionAsync(userId, sessionId, req);
        if (result == null)
            return NotFound(new { message = "Session not found or already completed." });

        _logger.LogInformation("Session completed: {SessionId}, Score: {Score}, Passed: {Passed}",
            sessionId, result.Score, result.Passed);
        return Ok(result);
    }

    [HttpGet("leaderboard")]
    [AllowAnonymous]
    public async Task<IActionResult> GetLeaderboard([FromQuery] int limit = 50)
    {
        var leaderboard = await _quiz.GetLeaderboardAsync(Math.Min(limit, 100));
        return Ok(leaderboard);
    }

    [HttpGet("progress")]
    public async Task<IActionResult> GetProgress()
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized(new { message = "Invalid token." });

        var progress = await _quiz.GetUserProgressAsync(userId);
        return Ok(progress);
    }

    [HttpGet("sessions")]
    public async Task<IActionResult> GetSessions()
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized(new { message = "Invalid token." });

        var sessions = await _quiz.GetUserSessionsAsync(userId);
        return Ok(sessions);
    }

    [HttpGet("health")]
    [AllowAnonymous]
    public IActionResult Health() => Ok(new { status = "healthy", service = "quiz-service", timestamp = DateTime.UtcNow });
}
