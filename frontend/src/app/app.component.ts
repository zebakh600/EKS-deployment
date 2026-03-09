import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { NavbarComponent } from './components/navbar/navbar.component';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NavbarComponent],
  template: `
    <div class="app-shell">
      @if (auth.isLoggedIn()) {
        <app-navbar />
      }
      <main class="main-content" [class.with-nav]="auth.isLoggedIn()">
        <router-outlet />
      </main>
    </div>
  `,
  styles: [`
    .app-shell { min-height: 100vh; display: flex; flex-direction: column; position: relative; z-index: 1; }
    .main-content { flex: 1; }
    .main-content.with-nav { padding-top: 64px; }
  `]
})
export class AppComponent {
  constructor(public auth: AuthService) {}
}
