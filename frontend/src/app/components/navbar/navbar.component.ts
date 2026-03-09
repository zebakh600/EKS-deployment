import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [RouterLink, RouterLinkActive],
  template: `
    <nav class="navbar">
      <div class="nav-brand">
        <span class="brand-icon">⚙</span>
        <span class="brand-text">DevOps<span class="text-green">Quiz</span></span>
      </div>
      <div class="nav-links">
        <a routerLink="/dashboard" routerLinkActive="active">Dashboard</a>
        <a routerLink="/leaderboard" routerLinkActive="active">Leaderboard</a>
      </div>
      <div class="nav-user">
        <span class="username">{{ auth.currentUser()?.username }}</span>
        <button class="btn-logout" (click)="auth.logout()">Logout</button>
      </div>
    </nav>
  `,
  styles: [`
    .navbar {
      position: fixed; top: 0; left: 0; right: 0; z-index: 100;
      height: 64px; display: flex; align-items: center; justify-content: space-between;
      padding: 0 32px;
      background: rgba(10, 14, 26, 0.95);
      border-bottom: 1px solid var(--border);
      backdrop-filter: blur(12px);
    }
    .nav-brand { display: flex; align-items: center; gap: 10px; }
    .brand-icon { font-size: 22px; animation: spin 6s linear infinite; display: inline-block; }
    @keyframes spin { to { transform: rotate(360deg); } }
    .brand-text { font-family: var(--font-mono); font-size: 18px; font-weight: 700; color: var(--text-primary); }
    .nav-links { display: flex; gap: 8px; }
    .nav-links a {
      padding: 6px 16px; border-radius: var(--radius); color: var(--text-secondary);
      font-family: var(--font-mono); font-size: 13px; transition: var(--transition);
    }
    .nav-links a:hover, .nav-links a.active {
      color: var(--accent-green); background: rgba(0,255,157,0.08);
      text-decoration: none;
    }
    .nav-user { display: flex; align-items: center; gap: 12px; }
    .username { font-family: var(--font-mono); font-size: 13px; color: var(--text-secondary); }
    .btn-logout {
      padding: 6px 14px; border-radius: var(--radius);
      background: transparent; border: 1px solid var(--border);
      color: var(--text-secondary); font-family: var(--font-mono); font-size: 12px;
      cursor: pointer; transition: var(--transition); text-transform: uppercase;
    }
    .btn-logout:hover { border-color: var(--accent-red); color: var(--accent-red); }
  `]
})
export class NavbarComponent {
  constructor(public auth: AuthService) {}
}
