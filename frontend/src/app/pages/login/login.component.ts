import { Component, OnInit, signal } from '@angular/core';
import { FormBuilder, FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule, ReactiveFormsModule],
  template: `
    <div class="auth-page">
      <div class="auth-bg-text">DevOps</div>

      <div class="auth-card page-enter">

        <!-- Logo -->
        <div class="auth-header">
          <div class="logo-wrap">
            <span class="logo-icon">⚙</span>
          </div>
          <h1 class="brand">DevOps<span class="text-green">Quiz</span></h1>
          <p class="tagline text-muted">Master DevOps. One question at a time.</p>
        </div>

        <!-- Tab Switcher -->
        <div class="tab-switcher">
          <button class="tab-btn" [class.active]="mode() === 'login'" (click)="setMode('login')" type="button">
            Sign In
          </button>
          <button class="tab-btn" [class.active]="mode() === 'register'" (click)="setMode('register')" type="button">
            Sign Up
          </button>
        </div>

        <!-- LOGIN FORM -->
        @if (mode() === 'login') {
          <form class="auth-form" (ngSubmit)="onLogin()">
            <div class="form-group">
              <label class="form-label">Email</label>
              <input class="form-control" type="email" name="login_email"
                [(ngModel)]="loginEmail" placeholder="you@company.com"
                autocomplete="email" required />
            </div>
            <div class="form-group">
              <label class="form-label">Password</label>
              <input class="form-control" type="password" name="login_password"
                [(ngModel)]="loginPassword" placeholder="••••••••"
                autocomplete="current-password" required />
            </div>
            @if (error()) {
              <div class="alert alert-error">{{ error() }}</div>
            }
            <button class="btn btn-primary btn-full" type="submit" [disabled]="loading()">
              @if (loading()) {
                <span class="spinner-sm"></span>&nbsp;Signing in...
              } @else {
                Sign In →
              }
            </button>
          </form>
        }

        <!-- REGISTER FORM -->
        @if (mode() === 'register') {
          <form class="auth-form" (ngSubmit)="onRegister()">
            <div class="form-group">
              <label class="form-label">Username</label>
              <input class="form-control" type="text" name="reg_username"
                [(ngModel)]="regUsername" placeholder="devops_ninja"
                autocomplete="username" required minlength="3" />
            </div>
            <div class="form-group">
              <label class="form-label">Email</label>
              <input class="form-control" type="email" name="reg_email"
                [(ngModel)]="regEmail" placeholder="you@company.com"
                autocomplete="email" required />
            </div>
            <div class="form-group">
              <label class="form-label">Password</label>
              <input class="form-control" type="password" name="reg_password"
                [(ngModel)]="regPassword" placeholder="min 6 characters"
                autocomplete="new-password" required minlength="6" />
            </div>
            @if (error()) {
              <div class="alert alert-error">{{ error() }}</div>
            }
            <button class="btn btn-primary btn-full" type="submit" [disabled]="loading()">
              @if (loading()) {
                <span class="spinner-sm"></span>&nbsp;Creating account...
              } @else {
                Create Account →
              }
            </button>
          </form>
        }

        <!-- Topics preview -->
        <div class="topics-preview">
          @for (t of topics; track t) {
            <span class="topic-pill">{{ t }}</span>
          }
        </div>

      </div>
    </div>
  `,
  styles: [`
    .auth-page {
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      padding: 24px; position: relative; overflow: hidden;
    }
    .auth-bg-text {
      position: fixed; bottom: -60px; right: -30px;
      font-size: 320px; font-family: var(--font-mono); font-weight: 700;
      color: rgba(0,255,157,0.025); pointer-events: none; user-select: none; line-height: 1;
    }
    .auth-card {
      width: 100%; max-width: 440px;
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 24px; padding: 40px;
      position: relative; z-index: 1;
      box-shadow: 0 24px 64px rgba(0,0,0,0.4);
    }
    .auth-card::before {
      content: '';
      position: absolute; top: 0; left: 50%; transform: translateX(-50%);
      width: 50%; height: 1px;
      background: linear-gradient(90deg, transparent, var(--accent-green), transparent);
    }
    .auth-header { text-align: center; margin-bottom: 28px; }
    .logo-wrap {
      display: inline-flex; align-items: center; justify-content: center;
      width: 64px; height: 64px; border-radius: 16px;
      background: rgba(0,255,157,0.08); border: 1px solid rgba(0,255,157,0.2);
      margin-bottom: 16px;
    }
    .logo-icon { font-size: 32px; display: inline-block; animation: spin 8s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }
    .brand { font-family: var(--font-mono); font-size: 26px; font-weight: 700; margin-bottom: 6px; }
    .tagline { font-size: 13px; }
    .tab-switcher {
      display: grid; grid-template-columns: 1fr 1fr;
      background: var(--bg-secondary); border: 1px solid var(--border);
      border-radius: 12px; padding: 4px; margin-bottom: 28px; gap: 4px;
    }
    .tab-btn {
      padding: 11px; border-radius: 9px; border: none;
      background: transparent; color: var(--text-secondary);
      font-family: var(--font-mono); font-size: 13px; font-weight: 700;
      text-transform: uppercase; letter-spacing: 0.06em;
      cursor: pointer; transition: var(--transition);
    }
    .tab-btn:hover:not(.active) { color: var(--text-primary); background: rgba(255,255,255,0.04); }
    .tab-btn.active { background: var(--accent-green); color: #000; box-shadow: 0 2px 12px rgba(0,255,157,0.35); }
    .auth-form { display: flex; flex-direction: column; gap: 16px; }
    .btn-full { width: 100%; justify-content: center; padding: 14px; font-size: 14px; margin-top: 4px; }
    .spinner-sm {
      width: 15px; height: 15px;
      border: 2px solid rgba(0,0,0,0.25); border-top-color: #000;
      border-radius: 50%; animation: spin 0.7s linear infinite; display: inline-block;
    }
    .topics-preview {
      display: flex; flex-wrap: wrap; gap: 6px;
      margin-top: 28px; padding-top: 20px; border-top: 1px solid var(--border);
      justify-content: center;
    }
    .topic-pill {
      padding: 3px 10px; border-radius: 100px;
      background: rgba(0,180,255,0.08); border: 1px solid rgba(0,180,255,0.2);
      font-family: var(--font-mono); font-size: 10px; color: var(--accent-blue);
      text-transform: uppercase; letter-spacing: 0.06em;
    }
  `]
})
export class LoginComponent implements OnInit {
  mode = signal<'login' | 'register'>('login');
  loading = signal(false);
  error = signal('');

  // Plain two-way bound fields — no FormGroup, no Validators.email blocking submit
  loginEmail = '';
  loginPassword = '';
  regUsername = '';
  regEmail = '';
  regPassword = '';

  topics = ['Linux', 'Git', 'Docker', 'K8s', 'Jenkins', 'Ansible', 'CI/CD', 'GitHub Actions', 'Prometheus'];

  constructor(private fb: FormBuilder, private auth: AuthService, private router: Router) {}

  ngOnInit() {
    // If already logged in, skip straight to dashboard
    if (this.auth.isLoggedIn()) {
      this.router.navigate(['/dashboard']);
    }
  }

  setMode(m: 'login' | 'register') {
    this.mode.set(m);
    this.error.set('');
  }

  onLogin() {
    const email = this.loginEmail.trim();
    const password = this.loginPassword;

    if (!email || !password) {
      this.error.set('Please enter your email and password.');
      return;
    }

    this.loading.set(true);
    this.error.set('');

    this.auth.login(email, password).subscribe({
      next: () => {
        this.loading.set(false);
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.loading.set(false);
        this.error.set(err?.error?.message || 'Invalid email or password. Please try again.');
      }
    });
  }

  onRegister() {
    const username = this.regUsername.trim();
    const email = this.regEmail.trim();
    const password = this.regPassword;

    if (!username || username.length < 3) {
      this.error.set('Username must be at least 3 characters.');
      return;
    }
    if (!email) {
      this.error.set('Please enter your email.');
      return;
    }
    if (!password || password.length < 6) {
      this.error.set('Password must be at least 6 characters.');
      return;
    }

    this.loading.set(true);
    this.error.set('');

    this.auth.register(username, email, password).subscribe({
      next: () => {
        this.loading.set(false);
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.loading.set(false);
        this.error.set(err?.error?.message || 'Registration failed. That email or username may already be taken.');
      }
    });
  }
}
