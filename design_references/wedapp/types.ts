
export enum AppTab {
  DISCOVER = 'discover',
  TALENT = 'talent',
  PLANNER = 'planner',
  MASTERMIND = 'mastermind',
  REGISTRY = 'registry',
  AGENT = 'agent',
  AR_SHOWROOM = 'ar'
}

export interface Talent {
  id: string;
  name: string;
  genre: string;
  image: string;
  compatibility: number;
  rate: string;
  technical: string;
}

export interface ChecklistItem {
  id: string;
  task: string;
  dueDate: string;
  completed: boolean;
  priority?: boolean;
  shopLink?: boolean;
}
