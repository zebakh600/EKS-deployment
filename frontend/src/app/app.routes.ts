import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  // Root: unauthenticated users see the auth page directly
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  // Single auth page with Sign In / Sign Up tabs
  { path: 'login', loadComponent: () => import('./pages/login/login.component').then(m => m.LoginComponent) },
  // Keep /register as alias — redirects to /login (Sign Up tab is there)
  { path: 'register', redirectTo: '/login', pathMatch: 'full' },
  // Protected routes
  { path: 'dashboard', canActivate: [authGuard], loadComponent: () => import('./pages/dashboard/dashboard.component').then(m => m.DashboardComponent) },
  { path: 'quiz/:topicId', canActivate: [authGuard], loadComponent: () => import('./pages/quiz/quiz.component').then(m => m.QuizComponent) },
  { path: 'results/:sessionId', canActivate: [authGuard], loadComponent: () => import('./pages/results/results.component').then(m => m.ResultsComponent) },
  { path: 'leaderboard', canActivate: [authGuard], loadComponent: () => import('./pages/leaderboard/leaderboard.component').then(m => m.LeaderboardComponent) },
  { path: '**', redirectTo: '/login' }
];
