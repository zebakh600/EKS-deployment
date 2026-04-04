import { Injectable } from '@angular/core';
import { SessionResult } from '../models/models';

@Injectable({ providedIn: 'root' })
export class ResultsStateService {
  private _result: SessionResult | null = null;
  private _topicId: string = '';

  setResult(result: SessionResult, topicId: string) {
    this._result = result;
    this._topicId = topicId;
  }

  getResult(): SessionResult | null {
    return this._result;
  }

  getTopicId(): string {
    return this._topicId;
  }

  clear() {
    this._result = null;
    this._topicId = '';
  }
}
