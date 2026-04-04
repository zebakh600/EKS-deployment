using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using AuthService.DTOs;
using AuthService.Services;
using System.Security.Claims;

namespace AuthService.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _auth;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService auth, ILogger<AuthController> logger)
    {
        _auth = auth;
        _logger = logger;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest req)
    {
        var result = await _auth.RegisterAsync(req);
        if (result == null)
        {
            _logger.LogWarning("Registration failed for email {Email}", req.Email);
            return Conflict(new { message = "Email or username already exists." });
        }
        _logger.LogInformation("User registered: {Username}", req.Username);
        return Ok(result);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest req)
    {
        var result = await _auth.LoginAsync(req);
        if (result == null)
        {
            _logger.LogWarning("Failed login attempt for {Email}", req.Email);
            return Unauthorized(new { message = "Invalid credentials." });
        }
        _logger.LogInformation("User logged in: {Email}", req.Email);
        return Ok(result);
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<IActionResult> Me()
    {
        // BUG FIX: After clearing DefaultInboundClaimTypeMap, "sub" stays as "sub"
        var userIdStr = User.FindFirstValue("sub");
        if (!Guid.TryParse(userIdStr, out var userId))
            return Unauthorized(new { message = "Invalid token claims." });

        var user = await _auth.GetUserByIdAsync(userId);
        return user == null ? NotFound() : Ok(user);
    }

    [HttpGet("health")]
    public IActionResult Health() => Ok(new { status = "healthy", service = "auth-service", timestamp = DateTime.UtcNow });
}
