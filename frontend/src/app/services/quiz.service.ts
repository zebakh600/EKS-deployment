import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Topic, QuizSession, SessionResult, LeaderboardEntry, UserProgress } from '../models/models';
import { environment } from '../../environments/environment';

export interface SubmitAnswer { questionId: string; selectedOption: string | null; timeTakenSeconds: number; }

@Injectable({ providedIn: 'root' })
export class QuizService {
  constructor(private http: HttpClient) {}

  getTopics() {
    return this.http.get<Topic[]>(`${environment.quizServiceUrl}/topics`);
  }

  startSession(topicId: string) {
    return this.http.post<QuizSession>(`${environment.quizServiceUrl}/sessions/start`, { topicId });
  }

  completeSession(sessionId: string, answers: SubmitAnswer[], totalTimeTakenSeconds: number) {
    return this.http.post<SessionResult>(
      `${environment.quizServiceUrl}/sessions/${sessionId}/complete`,
      { answers, totalTimeTakenSeconds }
    );
  }

  getLeaderboard() {
    return this.http.get<LeaderboardEntry[]>(`${environment.quizServiceUrl}/leaderboard`);
  }

  getProgress() {
    return this.http.get<UserProgress>(`${environment.quizServiceUrl}/progress`);
  }
}
