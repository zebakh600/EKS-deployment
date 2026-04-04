using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UserService.Data;
using UserService.DTOs;
using System.Security.Claims;

namespace UserService.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UserController : ControllerBase
{
    private readonly UserDbContext _db;

    public UserController(UserDbContext db) => _db = db;

    // BUG FIX: Use "sub" directly since DefaultInboundClaimTypeMap is cleared
    private Guid GetUserId()
    {
        var idStr = User.FindFirstValue("sub");
        return Guid.TryParse(idStr, out var id) ? id : Guid.Empty;
    }

    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized(new { message = "Invalid token." });

        var user = await _db.Users.FindAsync(userId);
        if (user == null) return NotFound(new { message = "User not found." });

        var stats = await _db.UserStats.FirstOrDefaultAsync(s => s.UserId == userId);
        var statsDto = stats == null ? null : new UserStatsDto(
            stats.TotalQuizzes, stats.TotalPassed, stats.TotalFailed,
            stats.TotalScore, stats.BestScore,
            stats.TotalQuestionsAnswered > 0
                ? Math.Round((double)stats.TotalCorrectAnswers / stats.TotalQuestionsAnswered * 100, 1) : 0,
            stats.CurrentStreak, stats.BestStreak, stats.LastQuizAt);

        return Ok(new UserProfileDto(user.Id, user.Username, user.Email,
            user.AvatarUrl, user.CreatedAt, statsDto));
    }

    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest req)
    {
        var userId = GetUserId();
        if (userId == Guid.Empty) return Unauthorized(new { message = "Invalid token." });

        var user = await _db.Users.FindAsync(userId);
        if (user == null) return NotFound(new { message = "User not found." });

        if (req.AvatarUrl != null) user.AvatarUrl = req.AvatarUrl;
        user.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(new { message = "Profile updated." });
    }

    [HttpGet("health")]
    [AllowAnonymous]
    public IActionResult Health() => Ok(new { status = "healthy", service = "user-service", timestamp = DateTime.UtcNow });
}
