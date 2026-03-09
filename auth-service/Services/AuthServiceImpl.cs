using Microsoft.EntityFrameworkCore;
using AuthService.Data;
using AuthService.DTOs;
using AuthService.Models;

namespace AuthService.Services;

public interface IAuthService
{
    Task<AuthResponse?> RegisterAsync(RegisterRequest req);
    Task<AuthResponse?> LoginAsync(LoginRequest req);
    Task<UserDto?> GetUserByIdAsync(Guid id);
}

public class AuthServiceImpl : IAuthService
{
    private readonly AuthDbContext _db;
    private readonly IJwtService _jwt;

    public AuthServiceImpl(AuthDbContext db, IJwtService jwt)
    {
        _db = db;
        _jwt = jwt;
    }

    public async Task<AuthResponse?> RegisterAsync(RegisterRequest req)
    {
        if (await _db.Users.AnyAsync(u => u.Email == req.Email || u.Username == req.Username))
            return null;

        var user = new User
        {
            Username = req.Username,
            Email = req.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(req.Password)
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        var token = _jwt.GenerateToken(user.Id, user.Username, user.Email);
        return new AuthResponse(token, ToDto(user));
    }

    public async Task<AuthResponse?> LoginAsync(LoginRequest req)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == req.Email && u.IsActive);
        if (user == null || !BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
            return null;

        var token = _jwt.GenerateToken(user.Id, user.Username, user.Email);
        return new AuthResponse(token, ToDto(user));
    }

    public async Task<UserDto?> GetUserByIdAsync(Guid id)
    {
        var user = await _db.Users.FindAsync(id);
        return user == null ? null : ToDto(user);
    }

    private static UserDto ToDto(User u) =>
        new(u.Id, u.Username, u.Email, u.AvatarUrl, u.CreatedAt);
}
