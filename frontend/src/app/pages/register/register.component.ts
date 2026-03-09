import { Component } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  template: `
    <div class="auth-page">
      <div class="auth-card page-enter">
        <div class="auth-header">
          <div class="logo">⚙</div>
          <h1>Create Account</h1>
          <p class="subtitle text-muted">Join the DevOps Quiz community</p>
        </div>
        <form [formGroup]="form" (ngSubmit)="onSubmit()" class="auth-form">
          <div class="form-group">
            <label class="form-label">Username</label>
            <input class="form-control" formControlName="username" placeholder="devops_ninja" />
          </div>
          <div class="form-group">
            <label class="form-label">Email</label>
            <input class="form-control" type="email" formControlName="email" placeholder="you@company.com" />
          </div>
          <div class="form-group">
            <label class="form-label">Password</label>
            <input class="form-control" type="password" formControlName="password" placeholder="min 6 characters" />
          </div>
          @if (error) { <div class="alert alert-error">{{ error }}</div> }
          <button class="btn btn-primary w-full" type="submit" [disabled]="loading || form.invalid">
            @if (loading) { <span class="spinner-sm"></span> }
            {{ loading ? 'Creating account...' : 'Sign Up' }}
          </button>
        </form>
        <p class="auth-footer text-muted">Already have an account? <a routerLink="/login">Login</a></p>
      </div>
    </div>
  `,
  styles: [`
    .auth-page { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 24px; }
    .auth-card {
      width: 100%; max-width: 420px; background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 20px; padding: 40px; position: relative;
    }
    .auth-card::before {
      content: ''; position: absolute; top: 0; left: 50%; transform: translateX(-50%);
      width: 60%; height: 1px; background: linear-gradient(90deg, transparent, var(--accent-blue), transparent);
    }
    .auth-header { text-align: center; margin-bottom: 32px; }
    .logo { font-size: 48px; animation: spin 6s linear infinite; display: inline-block; margin-bottom: 12px; }
    @keyframes spin { to { transform: rotate(360deg); } }
    h1 { font-family: var(--font-mono); font-size: 26px; font-weight: 700; margin-bottom: 6px; }
    .subtitle { font-size: 14px; }
    .auth-form { display: flex; flex-direction: column; gap: 16px; }
    .w-full { width: 100%; justify-content: center; padding: 14px; }
    .spinner-sm { width: 16px; height: 16px; border: 2px solid rgba(0,0,0,0.3); border-top-color: #000; border-radius: 50%; animation: spin 0.8s linear infinite; }
    .auth-footer { text-align: center; margin-top: 20px; font-size: 14px; }
  `]
})
export class RegisterComponent {
  form = this.fb.group({
    username: ['', [Validators.required, Validators.minLength(3)]],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]]
  });
  loading = false; error = '';

  constructor(private fb: FormBuilder, private auth: AuthService, private router: Router) {}

  onSubmit() {
    if (this.form.invalid) return;
    this.loading = true; this.error = '';
    const { username, email, password } = this.form.value;
    this.auth.register(username!, email!, password!).subscribe({
      next: () => this.router.navigate(['/dashboard']),
      error: (err) => { this.error = err.error?.message || 'Registration failed'; this.loading = false; }
    });
  }
}
