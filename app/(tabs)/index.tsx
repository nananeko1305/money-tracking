import React, { useState, useEffect, useCallback } from 'react';
import {
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
  Alert,
  View,
  RefreshControl,
} from 'react-native';
import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Category } from '@/types/budget';
import {
  getCurrentCategories,
  addCategory,
  addExpense,
  deleteCategory,
  getDaysUntilReset,
} from '@/services/storage';
import { useColorScheme } from '@/hooks/use-color-scheme';

export default function DashboardScreen() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [daysRemaining, setDaysRemaining] = useState<number>(0);
  const [refreshing, setRefreshing] = useState(false);
  const [showAddCategory, setShowAddCategory] = useState(false);
  const [newCategoryName, setNewCategoryName] = useState('');
  const [newCategoryBudget, setNewCategoryBudget] = useState('');
  const [expenseInputs, setExpenseInputs] = useState<{ [key: string]: string }>({});

  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const loadCategories = useCallback(async () => {
    const cats = await getCurrentCategories();
    setCategories(cats);
    setDaysRemaining(getDaysUntilReset());
  }, []);

  useEffect(() => {
    loadCategories();
  }, [loadCategories]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadCategories();
    setRefreshing(false);
  }, [loadCategories]);

  const handleAddCategory = async () => {
    if (!newCategoryName.trim()) {
      Alert.alert('Greška', 'Unesi naziv kategorije');
      return;
    }

    const budget = parseFloat(newCategoryBudget);
    if (isNaN(budget) || budget <= 0) {
      Alert.alert('Greška', 'Unesi validan budžet');
      return;
    }

    await addCategory(newCategoryName.trim(), budget);
    setNewCategoryName('');
    setNewCategoryBudget('');
    setShowAddCategory(false);
    await loadCategories();
  };

  const handleAddExpense = async (categoryId: string) => {
    const amountStr = expenseInputs[categoryId];
    if (!amountStr) return;

    const amount = parseFloat(amountStr);
    if (isNaN(amount) || amount <= 0) {
      Alert.alert('Greška', 'Unesi validan iznos');
      return;
    }

    await addExpense(categoryId, amount);
    setExpenseInputs({ ...expenseInputs, [categoryId]: '' });
    await loadCategories();
  };

  const handleDeleteCategory = (category: Category) => {
    Alert.alert(
      'Obriši kategoriju',
      `Da li si siguran da želiš da obrišeš "${category.name}"?`,
      [
        { text: 'Otkaži', style: 'cancel' },
        {
          text: 'Obriši',
          style: 'destructive',
          onPress: async () => {
            await deleteCategory(category.id);
            await loadCategories();
          },
        },
      ]
    );
  };

  const getTotalStats = () => {
    const totalBudget = categories.reduce((sum, cat) => sum + cat.budget, 0);
    const totalSpent = categories.reduce((sum, cat) => sum + cat.spent, 0);
    const totalRemaining = totalBudget - totalSpent;
    return { totalBudget, totalSpent, totalRemaining };
  };

  const stats = getTotalStats();

  return (
    <ScrollView
      style={[styles.container, isDark && styles.containerDark]}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
    >
      {/* Header with days remaining */}
      <ThemedView style={styles.header}>
        <ThemedText type="title" style={styles.headerTitle}>
          Budžet Tracker
        </ThemedText>
        <ThemedView style={styles.daysContainer}>
          <ThemedText style={styles.daysText}>
            {daysRemaining} {daysRemaining === 1 ? 'dan' : 'dana'} do reseta
          </ThemedText>
        </ThemedView>
      </ThemedView>

      {/* Total Stats */}
      {categories.length > 0 && (
        <ThemedView style={styles.statsContainer}>
          <View style={styles.statRow}>
            <ThemedText style={styles.statLabel}>Ukupan budžet:</ThemedText>
            <ThemedText style={styles.statValue}>{stats.totalBudget.toLocaleString()} din</ThemedText>
          </View>
          <View style={styles.statRow}>
            <ThemedText style={styles.statLabel}>Ukupno potrošeno:</ThemedText>
            <ThemedText style={[styles.statValue, styles.spentText]}>
              {stats.totalSpent.toLocaleString()} din
            </ThemedText>
          </View>
          <View style={styles.statRow}>
            <ThemedText style={styles.statLabel}>Preostalo:</ThemedText>
            <ThemedText
              style={[
                styles.statValue,
                styles.remainingText,
                stats.totalRemaining < 0 && styles.negativeText,
              ]}
            >
              {stats.totalRemaining.toLocaleString()} din
            </ThemedText>
          </View>
        </ThemedView>
      )}

      {/* Categories List */}
      <ThemedView style={styles.categoriesContainer}>
        {categories.map((category) => {
          const remaining = category.budget - category.spent;
          const percentageSpent = (category.spent / category.budget) * 100;

          return (
            <ThemedView key={category.id} style={styles.categoryCard}>
              {/* Category Header */}
              <View style={styles.categoryHeader}>
                <View style={[styles.colorIndicator, { backgroundColor: category.color }]} />
                <ThemedText type="defaultSemiBold" style={styles.categoryName}>
                  {category.name}
                </ThemedText>
                <TouchableOpacity
                  onPress={() => handleDeleteCategory(category)}
                  style={styles.deleteButton}
                >
                  <ThemedText style={styles.deleteButtonText}>✕</ThemedText>
                </TouchableOpacity>
              </View>

              {/* Budget Info */}
              <View style={styles.budgetInfo}>
                <View style={styles.budgetRow}>
                  <ThemedText style={styles.budgetLabel}>Budžet:</ThemedText>
                  <ThemedText style={styles.budgetValue}>
                    {category.budget.toLocaleString()} din
                  </ThemedText>
                </View>
                <View style={styles.budgetRow}>
                  <ThemedText style={styles.budgetLabel}>Potrošeno:</ThemedText>
                  <ThemedText style={[styles.budgetValue, styles.spentText]}>
                    {category.spent.toLocaleString()} din ({percentageSpent.toFixed(0)}%)
                  </ThemedText>
                </View>
                <View style={styles.budgetRow}>
                  <ThemedText style={styles.budgetLabel}>Preostalo:</ThemedText>
                  <ThemedText
                    style={[
                      styles.budgetValue,
                      styles.remainingText,
                      remaining < 0 && styles.negativeText,
                    ]}
                  >
                    {remaining.toLocaleString()} din
                  </ThemedText>
                </View>
              </View>

              {/* Progress Bar */}
              <View style={styles.progressBarContainer}>
                <View
                  style={[
                    styles.progressBar,
                    {
                      width: `${Math.min(percentageSpent, 100)}%`,
                      backgroundColor:
                        percentageSpent > 100 ? '#E63946' : percentageSpent > 80 ? '#FFA07A' : category.color,
                    },
                  ]}
                />
              </View>

              {/* Expense Input */}
              <View style={styles.expenseInput}>
                <TextInput
                  style={[
                    styles.input,
                    isDark ? styles.inputDark : styles.inputLight,
                  ]}
                  placeholder="Unesi trošak..."
                  placeholderTextColor={isDark ? '#999' : '#666'}
                  keyboardType="numeric"
                  value={expenseInputs[category.id] || ''}
                  onChangeText={(text) =>
                    setExpenseInputs({ ...expenseInputs, [category.id]: text })
                  }
                  onSubmitEditing={() => handleAddExpense(category.id)}
                  returnKeyType="done"
                />
                <TouchableOpacity
                  style={[styles.addExpenseButton, { backgroundColor: category.color }]}
                  onPress={() => handleAddExpense(category.id)}
                >
                  <ThemedText style={styles.addExpenseButtonText}>+</ThemedText>
                </TouchableOpacity>
              </View>
            </ThemedView>
          );
        })}
      </ThemedView>

      {/* Add Category Section */}
      {!showAddCategory ? (
        <TouchableOpacity
          style={styles.addCategoryButton}
          onPress={() => setShowAddCategory(true)}
        >
          <ThemedText style={styles.addCategoryButtonText}>+ Dodaj kategoriju</ThemedText>
        </TouchableOpacity>
      ) : (
        <ThemedView style={styles.addCategoryForm}>
          <ThemedText type="defaultSemiBold" style={styles.formTitle}>
            Nova kategorija
          </ThemedText>
          <TextInput
            style={[styles.input, isDark ? styles.inputDark : styles.inputLight]}
            placeholder="Naziv (npr. Hrana)"
            placeholderTextColor={isDark ? '#999' : '#666'}
            value={newCategoryName}
            onChangeText={setNewCategoryName}
          />
          <TextInput
            style={[styles.input, isDark ? styles.inputDark : styles.inputLight]}
            placeholder="Budžet (npr. 40000)"
            placeholderTextColor={isDark ? '#999' : '#666'}
            keyboardType="numeric"
            value={newCategoryBudget}
            onChangeText={setNewCategoryBudget}
          />
          <View style={styles.formButtons}>
            <TouchableOpacity
              style={[styles.formButton, styles.cancelButton]}
              onPress={() => {
                setShowAddCategory(false);
                setNewCategoryName('');
                setNewCategoryBudget('');
              }}
            >
              <ThemedText>Otkaži</ThemedText>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.formButton, styles.saveButton]}
              onPress={handleAddCategory}
            >
              <ThemedText style={styles.saveButtonText}>Sačuvaj</ThemedText>
            </TouchableOpacity>
          </View>
        </ThemedView>
      )}

      <View style={styles.bottomPadding} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  containerDark: {
    backgroundColor: '#000',
  },
  header: {
    padding: 20,
    paddingTop: 60,
  },
  headerTitle: {
    marginBottom: 10,
  },
  daysContainer: {
    padding: 12,
    borderRadius: 8,
    backgroundColor: 'rgba(78, 205, 196, 0.2)',
  },
  daysText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#4ECDC4',
    textAlign: 'center',
  },
  statsContainer: {
    marginHorizontal: 20,
    padding: 16,
    borderRadius: 12,
    backgroundColor: 'rgba(100, 100, 100, 0.1)',
    marginBottom: 20,
  },
  statRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  statLabel: {
    fontSize: 14,
  },
  statValue: {
    fontSize: 14,
    fontWeight: '600',
  },
  spentText: {
    color: '#FFA07A',
  },
  remainingText: {
    color: '#52B788',
  },
  negativeText: {
    color: '#E63946',
  },
  categoriesContainer: {
    paddingHorizontal: 20,
  },
  categoryCard: {
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: 'rgba(100, 100, 100, 0.2)',
  },
  categoryHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  colorIndicator: {
    width: 20,
    height: 20,
    borderRadius: 10,
    marginRight: 10,
  },
  categoryName: {
    flex: 1,
    fontSize: 18,
  },
  deleteButton: {
    padding: 4,
  },
  deleteButtonText: {
    fontSize: 20,
    color: '#E63946',
  },
  budgetInfo: {
    marginBottom: 12,
  },
  budgetRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 6,
  },
  budgetLabel: {
    fontSize: 14,
  },
  budgetValue: {
    fontSize: 14,
    fontWeight: '600',
  },
  progressBarContainer: {
    height: 8,
    backgroundColor: 'rgba(100, 100, 100, 0.2)',
    borderRadius: 4,
    marginBottom: 12,
    overflow: 'hidden',
  },
  progressBar: {
    height: '100%',
    borderRadius: 4,
  },
  expenseInput: {
    flexDirection: 'row',
    gap: 8,
  },
  input: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    fontSize: 16,
    borderWidth: 1,
  },
  inputLight: {
    backgroundColor: '#fff',
    borderColor: '#ddd',
    color: '#000',
  },
  inputDark: {
    backgroundColor: '#1a1a1a',
    borderColor: '#333',
    color: '#fff',
  },
  addExpenseButton: {
    width: 44,
    height: 44,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  addExpenseButtonText: {
    fontSize: 24,
    color: '#fff',
    fontWeight: 'bold',
  },
  addCategoryButton: {
    marginHorizontal: 20,
    padding: 16,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#4ECDC4',
    borderStyle: 'dashed',
    alignItems: 'center',
    marginTop: 10,
  },
  addCategoryButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#4ECDC4',
  },
  addCategoryForm: {
    marginHorizontal: 20,
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(100, 100, 100, 0.2)',
    marginTop: 10,
  },
  formTitle: {
    fontSize: 18,
    marginBottom: 12,
  },
  formButtons: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 12,
  },
  formButton: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  cancelButton: {
    backgroundColor: 'rgba(100, 100, 100, 0.2)',
  },
  saveButton: {
    backgroundColor: '#4ECDC4',
  },
  saveButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
  bottomPadding: {
    height: 40,
  },
});
