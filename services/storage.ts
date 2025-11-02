import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppData, Category, MonthlyReport } from '@/types/budget';

const STORAGE_KEY = '@budget_app_data';

// Helper function to generate random colors
const COLORS = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8',
  '#F7DC6F', '#BB8FCE', '#85C1E2', '#F8B739', '#52B788',
  '#E07A5F', '#81B29A', '#F2CC8F', '#A8DADC', '#E63946'
];

export function getRandomColor(): string {
  return COLORS[Math.floor(Math.random() * COLORS.length)];
}

// Get current month in YYYY-MM format
function getCurrentMonth(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}

// Initialize default data structure
function getDefaultData(): AppData {
  return {
    currentCategories: [],
    monthlyReports: [],
    lastResetDate: new Date().toISOString(),
  };
}

// Load data from AsyncStorage
export async function loadData(): Promise<AppData> {
  try {
    const jsonValue = await AsyncStorage.getItem(STORAGE_KEY);
    if (jsonValue === null) {
      const defaultData = getDefaultData();
      await saveData(defaultData);
      return defaultData;
    }
    return JSON.parse(jsonValue);
  } catch (error) {
    console.error('Error loading data:', error);
    return getDefaultData();
  }
}

// Save data to AsyncStorage
export async function saveData(data: AppData): Promise<void> {
  try {
    const jsonValue = JSON.stringify(data);
    await AsyncStorage.setItem(STORAGE_KEY, jsonValue);
  } catch (error) {
    console.error('Error saving data:', error);
  }
}

// Check if reset is needed and perform it
export async function checkAndPerformReset(): Promise<AppData> {
  const data = await loadData();
  const lastReset = new Date(data.lastResetDate);

  // Check if we're in a new month compared to last reset
  const lastResetMonth = `${lastReset.getFullYear()}-${String(lastReset.getMonth() + 1).padStart(2, '0')}`;
  const currentMonth = getCurrentMonth();

  if (lastResetMonth !== currentMonth && data.currentCategories.length > 0) {
    // Save current month to reports
    const totalBudget = data.currentCategories.reduce((sum, cat) => sum + cat.budget, 0);
    const totalSpent = data.currentCategories.reduce((sum, cat) => sum + cat.spent, 0);

    const monthlyReport: MonthlyReport = {
      id: lastResetMonth,
      month: lastResetMonth,
      categories: [...data.currentCategories],
      totalBudget,
      totalSpent,
      totalRemaining: totalBudget - totalSpent,
      savedAt: new Date().toISOString(),
    };

    // Reset current categories (keep structure but reset spent to 0)
    const resetCategories = data.currentCategories.map(cat => ({
      ...cat,
      spent: 0,
    }));

    // Keep only last 12 months of reports
    const updatedReports = [monthlyReport, ...data.monthlyReports].slice(0, 12);

    const updatedData: AppData = {
      currentCategories: resetCategories,
      monthlyReports: updatedReports,
      lastResetDate: new Date().toISOString(),
    };

    await saveData(updatedData);
    return updatedData;
  }

  return data;
}

// Add a new category
export async function addCategory(name: string, budget: number): Promise<Category> {
  const data = await checkAndPerformReset();

  const newCategory: Category = {
    id: Date.now().toString(),
    name,
    budget,
    spent: 0,
    color: getRandomColor(),
    createdAt: new Date().toISOString(),
  };

  data.currentCategories.push(newCategory);
  await saveData(data);

  return newCategory;
}

// Update category (edit budget or name)
export async function updateCategory(id: string, updates: Partial<Pick<Category, 'name' | 'budget'>>): Promise<void> {
  const data = await checkAndPerformReset();

  const categoryIndex = data.currentCategories.findIndex(cat => cat.id === id);
  if (categoryIndex !== -1) {
    data.currentCategories[categoryIndex] = {
      ...data.currentCategories[categoryIndex],
      ...updates,
    };
    await saveData(data);
  }
}

// Delete a category
export async function deleteCategory(id: string): Promise<void> {
  const data = await checkAndPerformReset();

  data.currentCategories = data.currentCategories.filter(cat => cat.id !== id);
  await saveData(data);
}

// Add expense to a category
export async function addExpense(categoryId: string, amount: number): Promise<void> {
  const data = await checkAndPerformReset();

  const categoryIndex = data.currentCategories.findIndex(cat => cat.id === categoryId);
  if (categoryIndex !== -1) {
    data.currentCategories[categoryIndex].spent += amount;
    await saveData(data);
  }
}

// Get current categories
export async function getCurrentCategories(): Promise<Category[]> {
  const data = await checkAndPerformReset();
  return data.currentCategories;
}

// Get monthly reports
export async function getMonthlyReports(): Promise<MonthlyReport[]> {
  const data = await checkAndPerformReset();
  return data.monthlyReports;
}

// Get days remaining until next reset
export function getDaysUntilReset(): number {
  const now = new Date();
  const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);
  const diff = nextMonth.getTime() - now.getTime();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
}
