// Data models for budget tracking app

export interface Category {
  id: string;
  name: string;
  budget: number; // Total budget for this category
  spent: number; // Total amount spent
  color: string; // Random color for visual distinction
  createdAt: string; // ISO date string
}

export interface MonthlyReport {
  id: string;
  month: string; // Format: "YYYY-MM" (e.g., "2025-11")
  categories: Category[];
  totalBudget: number;
  totalSpent: number;
  totalRemaining: number;
  savedAt: string; // ISO date string when the month was saved
}

export interface AppData {
  currentCategories: Category[];
  monthlyReports: MonthlyReport[];
  lastResetDate: string; // ISO date string of last reset
}
