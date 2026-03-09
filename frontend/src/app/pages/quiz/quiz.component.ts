import { Component, OnInit, OnDestroy } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { QuizService, SubmitAnswer } from '../../services/quiz.service';
import { ResultsStateService } from '../../services/results-state.service';
import { QuizSession, QuizQuestion } from '../../models/models';

@Component({
  selector: 'app-quiz',
  standalone: true,
  template: `
    <div class="quiz-wrapper">
      @if (loading) {
        <div class="loading-screen">
          <div class="spinner"></div>
          <p class="text-muted" style="margin-top:16px">Loading quiz...</p>
        </div>
      } @else if (error) {
        <div class="loading-screen">
          <p class="text-muted">{{ error }}</p>
          <a href="/dashboard" class="btn btn-secondary" style="margin-top:16px">← Back to Dashboard</a>
        </div>
      } @else if (session) {
        <!-- Header -->
        <div class="quiz-header">
          <div class="quiz-meta">
            <span class="text-mono text-green">{{ session.topicName }}</span>
            <span class="text-muted">Question {{ currentIndex + 1 }} / {{ session.questions.length }}</span>
          </div>
          <div class="timer-wrap" [class.timer-urgent]="timeLeft <= 10">
            <div class="timer-circle">
              <svg viewBox="0 0 40 40">
                <circle cx="20" cy="20" r="17" fill="none" stroke="var(--border)" stroke-width="3"/>
                <circle cx="20" cy="20" r="17" fill="none"
                  [attr.stroke]="timeLeft <= 10 ? 'var(--accent-red)' : 'var(--accent-green)'"
                  stroke-width="3" stroke-linecap="round"
                  stroke-dasharray="106.81"
                  [attr.stroke-dashoffset]="106.81 - (timeLeft / 30 * 106.81)"
                  transform="rotate(-90 20 20)"
                  style="transition: stroke-dashoffset 1s linear, stroke 0.3s"/>
              </svg>
              <span class="timer-text" [class.text-red]="timeLeft <= 10">{{ timeLeft }}</span>
            </div>
          </div>
        </div>

        <!-- Progress -->
        <div class="progress-bar" style="margin-bottom: 32px;">
          <div class="progress-fill" [style.width.%]="(currentIndex / session.questions.length) * 100"></div>
        </div>

        <!-- Question Card -->
        <div class="question-card">
          <div class="q-number text-mono text-muted">Q{{ currentIndex + 1 }}</div>
          <div class="q-text">{{ currentQuestion?.questionText }}</div>
          <div class="q-difficulty">
            <span class="badge"
              [class.badge-green]="currentQuestion?.difficulty === 'easy'"
              [class.badge-blue]="currentQuestion?.difficulty === 'medium'"
              [class.badge-purple]="currentQuestion?.difficulty === 'hard'">
              {{ currentQuestion?.difficulty }}
            </span>
          </div>

          <div class="options-grid">
            @for (opt of options; track opt.key) {
              <button class="option-btn"
                [class.selected]="selectedAnswer === opt.key"
                [class.timeout]="timedOut"
                (click)="selectAnswer(opt.key)"
                [disabled]="timedOut">
                <span class="opt-key text-mono">{{ opt.key }}</span>
                <span class="opt-text">{{ opt.value }}</span>
              </button>
            }
          </div>

          <!-- Next button shows as soon as an option is selected; hint shown before -->
          <div class="next-area">
            @if (timedOut && !selectedAnswer) {
              <div class="alert alert-error" style="margin: 0; flex: 1">⏰ Time's up!</div>
            } @else if (!selectedAnswer) {
              <span class="hint-text text-muted">← Select an option</span>
            }
            <button class="btn btn-primary next-btn"
              (click)="nextQuestion()"
              [disabled]="!selectedAnswer && !timedOut">
              {{ currentIndex < session.questions.length - 1 ? 'Next Question →' : 'See Results →' }}
            </button>
          </div>
        </div>
      }
    </div>
  `,
  styles: [`
    .quiz-wrapper { min-height: 100vh; max-width: 720px; margin: 0 auto; padding: 32px 24px; }
    .loading-screen { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 60vh; }
    .quiz-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
    .quiz-meta { display: flex; flex-direction: column; gap: 4px; }
    .quiz-meta span:first-child { font-size: 18px; font-weight: 700; }
    .quiz-meta span:last-child { font-size: 13px; }
    .timer-wrap { position: relative; }
    .timer-circle { position: relative; width: 60px; height: 60px; }
    .timer-circle svg { width: 100%; height: 100%; }
    .timer-text {
      position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
      font-family: var(--font-mono); font-size: 16px; font-weight: 700;
    }
    .timer-urgent .timer-text { animation: blink 0.5s ease-in-out infinite alternate; }
    @keyframes blink { from { opacity: 1; } to { opacity: 0.4; } }
    .question-card {
      background: var(--bg-card); border: 1px solid var(--border);
      border-radius: 20px; padding: 32px; position: relative;
    }
    .question-card::before {
      content: ''; position: absolute; top: 0; left: 32px; right: 32px; height: 1px;
      background: linear-gradient(90deg, transparent, var(--accent-green), transparent);
    }
    .q-number { font-size: 12px; margin-bottom: 12px; }
    .q-text { font-size: 20px; font-weight: 500; line-height: 1.5; margin-bottom: 12px; }
    .q-difficulty { margin-bottom: 28px; }
    .options-grid { display: flex; flex-direction: column; gap: 12px; }
    .option-btn {
      display: flex; align-items: center; gap: 16px; width: 100%;
      background: var(--bg-secondary); border: 1px solid var(--border);
      border-radius: var(--radius); padding: 16px 20px;
      color: var(--text-primary); text-align: left; cursor: pointer;
      transition: var(--transition); font-family: var(--font-body); font-size: 15px;
    }
    .option-btn:hover:not(:disabled) { border-color: var(--accent-green); background: rgba(0,255,157,0.05); }
    .option-btn.selected { border-color: var(--accent-green); background: rgba(0,255,157,0.1); }
    .option-btn.timeout { border-color: var(--accent-red); opacity: 0.6; cursor: not-allowed; }
    .opt-key {
      min-width: 30px; height: 30px; display: flex; align-items: center; justify-content: center;
      border-radius: 6px; background: var(--border); font-size: 12px; font-weight: 700; color: var(--accent-green);
    }
    .option-btn.selected .opt-key { background: var(--accent-green); color: #000; }
    .opt-text { flex: 1; }
    .next-area {
      display: flex; align-items: center; gap: 16px; margin-top: 24px;
      flex-wrap: wrap; min-height: 44px;
    }
    .hint-text { font-size: 13px; flex: 1; }
    .next-btn { margin-left: auto; }
    .next-btn:disabled { opacity: 0.35; cursor: not-allowed; }
  `]
})
export class QuizComponent implements OnInit, OnDestroy {
  session: QuizSession | null = null;
  loading = true;
  error = '';
  currentIndex = 0;
  selectedAnswer: string | null = null;
  timeLeft = 30;
  timedOut = false;
  private timer: any;
  private answers: SubmitAnswer[] = [];
  private questionStartTime = 0;
  private sessionStartTime = 0;
  private topicId = '';

  get currentQuestion(): QuizQuestion | undefined {
    return this.session?.questions[this.currentIndex];
  }

  get options() {
    const q = this.currentQuestion;
    if (!q) return [];
    return [
      { key: 'A', value: q.optionA },
      { key: 'B', value: q.optionB },
      { key: 'C', value: q.optionC },
      { key: 'D', value: q.optionD }
    ];
  }

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private quiz: QuizService,
    private resultsState: ResultsStateService
  ) {}

  ngOnInit() {
    this.topicId = this.route.snapshot.paramMap.get('topicId')!;
    this.quiz.startSession(this.topicId).subscribe({
      next: (session) => {
        this.session = session;
        this.loading = false;
        this.sessionStartTime = Date.now();
        this.startTimer();
      },
      error: (err) => {
        this.loading = false;
        this.error = err.error?.message || 'Failed to start quiz. Please go back and try again.';
      }
    });
  }

  startTimer() {
    this.timeLeft = 30;
    this.timedOut = false;
    this.selectedAnswer = null;
    this.questionStartTime = Date.now();
    clearInterval(this.timer);
    this.timer = setInterval(() => {
      this.timeLeft--;
      if (this.timeLeft <= 0) {
        clearInterval(this.timer);
        this.timedOut = true;
        // Auto-advance after timeout
        setTimeout(() => this.nextQuestion(), 1800);
      }
    }, 1000);
  }

  selectAnswer(key: string) {
    if (this.timedOut) return;
    // FIX: simply update the selection — timer keeps running, user can change their mind
    this.selectedAnswer = key;
  }

  nextQuestion() {
    if (!this.selectedAnswer && !this.timedOut) return;

    // FIX: record the answer only when moving to next, capturing final selection
    const timeTaken = Math.round((Date.now() - this.questionStartTime) / 1000);
    this.answers.push({
      questionId: this.currentQuestion!.id,
      selectedOption: this.selectedAnswer,
      timeTakenSeconds: Math.min(timeTaken, 30)
    });

    clearInterval(this.timer);

    if (this.currentIndex < (this.session?.questions.length ?? 0) - 1) {
      this.currentIndex++;
      this.startTimer();
    } else {
      this.submitQuiz();
    }
  }

  submitQuiz() {
    clearInterval(this.timer);
    const totalTime = Math.round((Date.now() - this.sessionStartTime) / 1000);
    this.quiz.completeSession(this.session!.sessionId, this.answers, totalTime).subscribe({
      next: (result) => {
        this.resultsState.setResult(result, this.topicId);
        this.router.navigate(['/results', result.sessionId]);
      },
      error: () => this.router.navigate(['/dashboard'])
    });
  }

  ngOnDestroy() { clearInterval(this.timer); }
}
