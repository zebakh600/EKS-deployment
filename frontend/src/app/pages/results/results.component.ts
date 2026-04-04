import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ResultsStateService } from '../../services/results-state.service';
import { SessionResult, QuestionResult } from '../../models/models';

@Component({
  selector: 'app-results',
  standalone: true,
  imports: [RouterLink],
  template: `
    <div class="container page-enter" style="padding: 48px 24px; max-width: 760px;">
      @if (!result) {
        <div style="text-align:center; padding: 80px 0;">
          <p class="text-muted">No results found.</p>
          <a routerLink="/dashboard" class="btn btn-secondary" style="margin-top: 16px;">← Back to Dashboard</a>
        </div>
      } @else {
        <!-- Score Hero -->
        <div class="result-hero" [class.passed]="result.passed">
          <div class="result-status-icon">{{ result.passed ? '🏆' : '💪' }}</div>
          <div class="result-status text-mono">{{ result.passed ? 'PASSED' : 'TRY AGAIN' }}</div>
          <div class="result-score">{{ result.score }}<span class="result-pct">%</span></div>
          <div class="result-topic text-muted">{{ result.topicName }} Quiz</div>

          <div class="result-stats">
            <div class="rs">
              <span class="rs-val text-green text-mono">{{ result.correctAnswers }}/{{ result.totalQuestions }}</span>
              <span class="rs-lbl text-muted">Correct</span>
            </div>
            <div class="rs-divider"></div>
            <div class="rs">
              <span class="rs-val text-mono">{{ formatTime(result.timeTakenSeconds) }}</span>
              <span class="rs-lbl text-muted">Time</span>
            </div>
            <div class="rs-divider"></div>
            <div class="rs">
              <span class="rs-val text-mono">{{ result.totalQuestions - result.correctAnswers }}</span>
              <span class="rs-lbl text-muted">Wrong</span>
            </div>
          </div>
        </div>

        <!-- Review -->
        <div class="review-header text-mono" style="margin: 40px 0 16px;">// QUESTION REVIEW</div>
        <div class="review-list">
          @for (q of result.results; track q.id; let i = $index) {
            <div class="review-item" [class.correct]="q.isCorrect" [class.wrong]="!q.isCorrect">
              <div class="review-item-header">
                <span class="q-num text-mono text-muted">Q{{ i + 1 }}</span>
                <span class="badge" [class.badge-green]="q.isCorrect" [class.badge-red]="!q.isCorrect">
                  {{ q.isCorrect ? '✓ Correct' : '✗ Wrong' }}
                </span>
              </div>
              <div class="q-text">{{ q.questionText }}</div>
              @if (!q.isCorrect) {
                <div class="answer-reveal">
                  @if (q.selectedOption) {
                    <div class="your-answer">
                      <span class="text-muted text-mono">Your answer: </span>
                      <span class="text-red">{{ q.selectedOption }}. {{ getOption(q, q.selectedOption) }}</span>
                    </div>
                  } @else {
                    <div class="your-answer">
                      <span class="text-muted text-mono">Your answer: </span>
                      <span class="text-red">No answer (timed out)</span>
                    </div>
                  }
                  <div class="correct-answer">
                    <span class="text-muted text-mono">Correct: </span>
                    <span class="text-green">{{ q.correctOption }}. {{ getOption(q, q.correctOption) }}</span>
                  </div>
                  @if (q.explanation) {
                    <div class="explanation text-muted">💡 {{ q.explanation }}</div>
                  }
                </div>
              }
            </div>
          }
        </div>

        <!-- Actions -->
        <div class="result-actions">
          <a routerLink="/dashboard" class="btn btn-secondary">← Dashboard</a>
          @if (topicId) {
            <a [routerLink]="['/quiz', topicId]" class="btn btn-primary">Try Again ↺</a>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .result-hero {
      text-align: center; background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 20px; padding: 48px 32px; margin-bottom: 8px; position: relative; overflow: hidden;
    }
    .result-hero.passed { border-color: rgba(0,255,157,0.4); }
    .result-hero.passed::before {
      content: ''; position: absolute; inset: 0;
      background: radial-gradient(circle at 50% 0%, rgba(0,255,157,0.08) 0%, transparent 60%);
    }
    .result-status-icon { font-size: 56px; margin-bottom: 12px; }
    .result-status { font-size: 13px; color: var(--text-secondary); letter-spacing: 0.15em; margin-bottom: 12px; }
    .result-score { font-family: var(--font-mono); font-size: 80px; font-weight: 700; line-height: 1; color: var(--accent-green); }
    .result-pct { font-size: 36px; }
    .result-topic { font-size: 14px; margin-top: 8px; }
    .result-stats { display: flex; align-items: center; justify-content: center; gap: 24px; margin-top: 28px; }
    .rs { display: flex; flex-direction: column; gap: 4px; align-items: center; }
    .rs-val { font-size: 22px; font-weight: 700; }
    .rs-lbl { font-size: 11px; text-transform: uppercase; letter-spacing: 0.08em; }
    .rs-divider { width: 1px; height: 36px; background: var(--border); }
    .review-header { font-size: 13px; color: var(--text-secondary); }
    .review-list { display: flex; flex-direction: column; gap: 12px; }
    .review-item {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: var(--radius); padding: 16px 20px;
    }
    .review-item.correct { border-left: 3px solid var(--accent-green); }
    .review-item.wrong { border-left: 3px solid var(--accent-red); }
    .review-item-header { display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }
    .q-num { font-size: 12px; }
    .q-text { font-size: 14px; font-weight: 500; margin-bottom: 8px; }
    .answer-reveal {
      display: flex; flex-direction: column; gap: 6px;
      padding-top: 10px; border-top: 1px solid var(--border); font-size: 13px;
    }
    .explanation { margin-top: 6px; font-style: italic; }
    .result-actions { display: flex; gap: 12px; margin-top: 32px; flex-wrap: wrap; }
  `]
})
export class ResultsComponent implements OnInit {
  result: SessionResult | null = null;
  topicId = '';

  constructor(private resultsState: ResultsStateService) {}

  ngOnInit() {
    // BUG FIX: Read from state service instead of getCurrentNavigation() which is null in ngOnInit
    this.result = this.resultsState.getResult();
    this.topicId = this.resultsState.getTopicId();
    this.resultsState.clear();
  }

  getOption(q: QuestionResult, opt: string): string {
    if (!opt) return '';
    const map: Record<string, string> = {
      'A': q.optionA, 'B': q.optionB, 'C': q.optionC, 'D': q.optionD
    };
    return map[opt.toUpperCase()] ?? '';
  }

  formatTime(secs: number): string {
    const m = Math.floor(secs / 60);
    const s = secs % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  }
}
