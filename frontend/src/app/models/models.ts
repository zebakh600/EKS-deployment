export interface User {
  id: string;
  username: string;
  email: string;
  avatarUrl?: string;
  createdAt: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}

export interface Topic {
  id: string;
  name: string;
  slug: string;
  description?: string;
  icon?: string;
  color?: string;
  questionCount: number;
}

export interface QuizQuestion {
  id: string;
  topicId: string;
  questionText: string;
  optionA: string;
  optionB: string;
  optionC: string;
  optionD: string;
  difficulty: string;
  questionNumber: number;
}

export interface QuizSession {
  sessionId: string;
  topicId: string;
  topicName: string;
  questions: QuizQuestion[];
  startedAt: string;
}

export interface QuestionResult {
  id: string;
  questionText: string;
  optionA: string;
  optionB: string;
  optionC: string;
  optionD: string;
  correctOption: string;
  explanation?: string;
  selectedOption?: string;
  isCorrect: boolean;
}

export interface SessionResult {
  sessionId: string;
  topicName: string;
  totalQuestions: number;
  correctAnswers: number;
  score: number;
  passed: boolean;
  timeTakenSeconds: number;
  results: QuestionResult[];
}

export interface LeaderboardEntry {
  rank: number;
  userId: string;
  username: string;
  avatarUrl?: string;
  totalQuizzes: number;
  totalPassed: number;
  bestScore: number;
  totalScore: number;
  accuracyPercent: number;
}

export interface RecentSession {
  sessionId: string;
  topicName: string;
  topicIcon?: string;
  topicColor?: string;
  score: number;
  passed: boolean;
  completedAt: string;
}

export interface UserProgress {
  totalQuizzes: number;
  totalPassed: number;
  totalFailed: number;
  totalScore: number;
  bestScore: number;
  accuracyPercent: number;
  currentStreak: number;
  bestStreak: number;
  recentSessions: RecentSession[];
}
