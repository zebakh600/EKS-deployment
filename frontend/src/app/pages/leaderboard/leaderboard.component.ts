import { Component, OnInit } from '@angular/core';
import { QuizService } from '../../services/quiz.service';
import { AuthService } from '../../services/auth.service';
import { LeaderboardEntry } from '../../models/models';

@Component({
  selector: 'app-leaderboard',
  standalone: true,
  template: `
    <div class="container page-enter" style="padding: 40px 24px;">
      <div class="lb-header">
        <div>
          <h1 class="text-mono">// LEADERBOARD</h1>
          <p class="text-muted" style="font-size:14px; margin-top:4px;">Global all-time rankings</p>
        </div>
        <span class="badge badge-purple">{{ entries.length }} players</span>
      </div>

      @if (loading) {
        <div style="display:flex;justify-content:center;padding:80px"><div class="spinner"></div></div>
      } @else {
        <!-- Top 3 podium -->
        @if (entries.length >= 3) {
          <div class="podium">
            <div class="podium-item silver">
              <div class="podium-rank text-mono">#2</div>
              <div class="podium-avatar">{{ getInitial(entries[1].username) }}</div>
              <div class="podium-name">{{ entries[1].username }}</div>
              <div class="podium-score text-mono">{{ entries[1].totalScore }}</div>
            </div>
            <div class="podium-item gold">
              <div class="podium-crown">👑</div>
              <div class="podium-rank text-mono">#1</div>
              <div class="podium-avatar large">{{ getInitial(entries[0].username) }}</div>
              <div class="podium-name">{{ entries[0].username }}</div>
              <div class="podium-score text-mono text-green">{{ entries[0].totalScore }}</div>
            </div>
            <div class="podium-item bronze">
              <div class="podium-rank text-mono">#3</div>
              <div class="podium-avatar">{{ getInitial(entries[2].username) }}</div>
              <div class="podium-name">{{ entries[2].username }}</div>
              <div class="podium-score text-mono">{{ entries[2].totalScore }}</div>
            </div>
          </div>
        }

        <!-- Full table -->
        <div class="lb-table">
          <div class="lb-table-head">
            <span class="col-rank text-mono">RANK</span>
            <span class="col-player text-mono">PLAYER</span>
            <span class="col-quizzes text-mono">QUIZZES</span>
            <span class="col-passed text-mono">PASSED</span>
            <span class="col-accuracy text-mono">ACCURACY</span>
            <span class="col-score text-mono">SCORE</span>
          </div>
          @for (entry of entries; track entry.userId) {
            <div class="lb-row" [class.my-row]="entry.userId === currentUserId" [class.top-row]="entry.rank <= 3">
              <span class="col-rank">
                @if (entry.rank === 1) { 🥇 }
                @else if (entry.rank === 2) { 🥈 }
                @else if (entry.rank === 3) { 🥉 }
                @else { <span class="text-mono text-muted">#{{ entry.rank }}</span> }
              </span>
              <span class="col-player">
                <div class="player-avatar">{{ getInitial(entry.username) }}</div>
                <span class="player-name" [class.text-green]="entry.userId === currentUserId">{{ entry.username }}</span>
                @if (entry.userId === currentUserId) { <span class="badge badge-green" style="font-size:10px">YOU</span> }
              </span>
              <span class="col-quizzes text-mono">{{ entry.totalQuizzes }}</span>
              <span class="col-passed text-mono text-green">{{ entry.totalPassed }}</span>
              <span class="col-accuracy text-mono">{{ entry.accuracyPercent }}%</span>
              <span class="col-score text-mono" style="font-weight:700">{{ entry.totalScore }}</span>
            </div>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .lb-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 40px; }
    h1 { font-size: 24px; }

    .podium { display: flex; justify-content: center; align-items: flex-end; gap: 16px; margin-bottom: 48px; }
    .podium-item {
      display: flex; flex-direction: column; align-items: center; gap: 6px;
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: var(--radius-lg); padding: 24px 20px; min-width: 140px;
    }
    .podium-item.gold { border-color: rgba(255,215,0,0.4); transform: translateY(-16px); background: rgba(255,215,0,0.05); }
    .podium-item.silver { border-color: rgba(192,192,192,0.3); }
    .podium-item.bronze { border-color: rgba(205,127,50,0.3); }
    .podium-crown { font-size: 24px; }
    .podium-rank { font-size: 12px; color: var(--text-secondary); letter-spacing: 0.1em; }
    .podium-avatar {
      width: 48px; height: 48px; border-radius: 50%;
      background: var(--border); display: flex; align-items: center; justify-content: center;
      font-family: var(--font-mono); font-size: 18px; font-weight: 700; color: var(--accent-green);
    }
    .podium-avatar.large { width: 60px; height: 60px; font-size: 22px; }
    .podium-name { font-size: 14px; font-weight: 600; }
    .podium-score { font-size: 18px; font-weight: 700; }

    .lb-table { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); overflow: hidden; }
    .lb-table-head, .lb-row {
      display: grid;
      grid-template-columns: 64px 1fr 90px 90px 100px 100px;
      padding: 12px 20px; align-items: center;
    }
    .lb-table-head { font-size: 11px; color: var(--text-muted); background: var(--bg-secondary); border-bottom: 1px solid var(--border); }
    .lb-row { border-bottom: 1px solid rgba(30,58,95,0.4); transition: var(--transition); }
    .lb-row:last-child { border-bottom: none; }
    .lb-row:hover { background: var(--bg-card-hover); }
    .lb-row.my-row { background: rgba(0,255,157,0.05); }
    .lb-row.top-row { }
    .col-rank { font-size: 18px; }
    .col-player { display: flex; align-items: center; gap: 12px; }
    .player-avatar {
      width: 34px; height: 34px; border-radius: 50%; background: var(--border);
      display: flex; align-items: center; justify-content: center;
      font-family: var(--font-mono); font-size: 14px; font-weight: 700; color: var(--accent-green);
      flex-shrink: 0;
    }
    .player-name { font-size: 14px; font-weight: 500; }
    .col-quizzes, .col-passed, .col-accuracy, .col-score { font-size: 14px; }
  `]
})
export class LeaderboardComponent implements OnInit {
  entries: LeaderboardEntry[] = [];
  loading = true;
  currentUserId = '';

  constructor(private quiz: QuizService, private auth: AuthService) {}

  ngOnInit() {
    this.currentUserId = this.auth.currentUser()?.id || '';
    this.quiz.getLeaderboard().subscribe(e => { this.entries = e; this.loading = false; });
  }

  getInitial(name: string): string { return name.charAt(0).toUpperCase(); }
}
