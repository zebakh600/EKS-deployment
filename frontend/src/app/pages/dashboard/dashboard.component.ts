import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { QuizService } from '../../services/quiz.service';
import { AuthService } from '../../services/auth.service';
import { Topic, UserProgress } from '../../models/models';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="container page-enter" style="padding-top: 40px; padding-bottom: 60px;">
      <!-- Header -->
      <div class="dash-header">
        <div>
          <div class="greeting text-muted">Welcome back,</div>
          <h1 class="username-heading">{{ auth.currentUser()?.username }}<span class="text-green">.</span></h1>
        </div>
        <div class="header-tags">
          <span class="badge badge-green">{{ progress?.totalPassed || 0 }} Passed</span>
          <span class="badge badge-blue">{{ progress?.currentStreak || 0 }} Streak 🔥</span>
        </div>
      </div>

      <!-- Stats Row -->
      @if (progress) {
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-value text-mono">{{ progress.totalQuizzes }}</div>
            <div class="stat-label text-muted">Total Quizzes</div>
          </div>
          <div class="stat-card">
            <div class="stat-value text-mono text-green">{{ progress.totalPassed }}</div>
            <div class="stat-label text-muted">Passed</div>
          </div>
          <div class="stat-card">
            <div class="stat-value text-mono">{{ progress.accuracyPercent }}%</div>
            <div class="stat-label text-muted">Accuracy</div>
          </div>
          <div class="stat-card">
            <div class="stat-value text-mono text-green">{{ progress.bestScore }}</div>
            <div class="stat-label text-muted">Best Score</div>
          </div>
        </div>
      }

      <!-- Topics Section -->
      <div class="section-header">
        <h2 class="section-title text-mono">// SELECT TOPIC</h2>
        <span class="badge badge-blue">{{ topics.length }} topics</span>
      </div>

      @if (loadingTopics) {
        <div style="display:flex; justify-content:center; padding:60px"><div class="spinner"></div></div>
      } @else {
        <div class="topics-grid">
          @for (topic of topics; track topic.id) {
            <a [routerLink]="['/quiz', topic.id]" class="topic-card" [style.--topic-color]="topic.color || '#00ff9d'">
              <div class="topic-icon">{{ getIcon(topic.icon) }}</div>
              <div class="topic-name">{{ topic.name }}</div>
              <div class="topic-count text-muted">{{ topic.questionCount }} questions</div>
              <div class="topic-arrow">→</div>
              <div class="topic-glow"></div>
            </a>
          }
        </div>
      }

      <!-- Recent Sessions -->
      @if (progress?.recentSessions?.length) {
        <div class="section-header" style="margin-top: 48px;">
          <h2 class="section-title text-mono">// RECENT ACTIVITY</h2>
        </div>
        <div class="sessions-list">
          @for (session of progress!.recentSessions.slice(0, 5); track session.sessionId) {
            <div class="session-row">
              <div class="session-topic">{{ session.topicName }}</div>
              <div class="session-score">
                <span class="text-mono" [class.text-green]="session.passed" [class.text-red]="!session.passed">
                  {{ session.score }}%
                </span>
              </div>
              <span class="badge" [class.badge-green]="session.passed" [class.badge-red]="!session.passed">
                {{ session.passed ? 'PASSED' : 'FAILED' }}
              </span>
            </div>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .dash-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 32px; flex-wrap: wrap; gap: 16px; }
    .greeting { font-size: 14px; margin-bottom: 4px; }
    .username-heading { font-family: var(--font-mono); font-size: 32px; font-weight: 700; }
    .header-tags { display: flex; gap: 8px; }

    .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 48px; }
    @media(max-width:768px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
    .stat-card {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: var(--radius-lg); padding: 20px; text-align: center;
    }
    .stat-value { font-size: 28px; font-weight: 700; }
    .stat-label { font-size: 12px; margin-top: 4px; text-transform: uppercase; letter-spacing: 0.08em; }

    .section-header { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; }
    .section-title { font-size: 14px; color: var(--text-secondary); }

    .topics-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 16px; }
    .topic-card {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: var(--radius-lg); padding: 24px 20px;
      display: flex; flex-direction: column; gap: 6px;
      transition: var(--transition); cursor: pointer; position: relative; overflow: hidden;
      text-decoration: none; color: inherit;
    }
    .topic-card:hover { border-color: var(--topic-color); transform: translateY(-3px); text-decoration: none; }
    .topic-card:hover .topic-glow { opacity: 1; }
    .topic-card:hover .topic-arrow { color: var(--topic-color); transform: translateX(4px); }
    .topic-glow {
      position: absolute; inset: 0; opacity: 0; transition: var(--transition);
      background: radial-gradient(circle at 50% 0%, var(--topic-color, var(--accent-green)) 0%, transparent 60%);
      opacity: 0; mix-blend-mode: screen;
    }
    .topic-icon { font-size: 28px; margin-bottom: 6px; }
    .topic-name { font-family: var(--font-mono); font-size: 15px; font-weight: 700; }
    .topic-count { font-size: 12px; }
    .topic-arrow { font-size: 18px; margin-top: 8px; transition: var(--transition); color: var(--text-muted); }

    .sessions-list { display: flex; flex-direction: column; gap: 8px; }
    .session-row {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: var(--radius); padding: 14px 20px;
      display: flex; align-items: center; gap: 16px;
    }
    .session-topic { flex: 1; font-size: 14px; }
    .session-score { font-size: 18px; font-weight: 700; }
  `]
})
export class DashboardComponent implements OnInit {
  topics: Topic[] = [];
  progress: UserProgress | null = null;
  loadingTopics = true;

  constructor(public auth: AuthService, private quiz: QuizService) {}

  ngOnInit() {
    this.quiz.getTopics().subscribe(t => { this.topics = t; this.loadingTopics = false; });
    this.quiz.getProgress().subscribe(p => this.progress = p);
  }

  getIcon(icon?: string): string {
    const icons: Record<string, string> = {
      terminal: '💻', 'git-branch': '🌿', box: '📦', settings: '⚙️',
      cloud: '☸️', github: '🐙', zap: '⚡', server: '🤖',
      activity: '📊', 'bar-chart': '📈', repeat: '🔄'
    };
    return icons[icon || ''] || '🛠️';
  }
}
