import React, { useState, useEffect } from 'react';
import { StyleSheet, ScrollView, View } from 'react-native';
import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { MonthlyReport } from '@/types/budget';
import { getMonthlyReports } from '@/services/storage';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { useFocusEffect } from 'expo-router';

export default function ReportsScreen() {
  const [reports, setReports] = useState<MonthlyReport[]>([]);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const loadReports = async () => {
    const monthlyReports = await getMonthlyReports();
    setReports(monthlyReports);
  };

  // Reload reports when screen comes into focus
  useFocusEffect(
    React.useCallback(() => {
      loadReports();
    }, [])
  );

  useEffect(() => {
    loadReports();
  }, []);

  const formatMonthYear = (monthStr: string) => {
    const [year, month] = monthStr.split('-');
    const monthNames = [
      'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Jun',
      'Jul', 'Avgust', 'Septembar', 'Oktobar', 'Novembar', 'Decembar'
    ];
    return `${monthNames[parseInt(month) - 1]} ${year}`;
  };

  return (
    <ScrollView style={[styles.container, isDark && styles.containerDark]}>
      <ThemedView style={styles.header}>
        <ThemedText type="title" style={styles.headerTitle}>
          Izveštaji
        </ThemedText>
        <ThemedText style={styles.headerSubtitle}>
          Arhiva mesečnih budžeta (poslednja godina)
        </ThemedText>
      </ThemedView>

      {reports.length === 0 ? (
        <ThemedView style={styles.emptyState}>
          <ThemedText style={styles.emptyStateText}>
            Nema sačuvanih izveštaja
          </ThemedText>
          <ThemedText style={styles.emptyStateSubtext}>
            Izveštaji se automatski čuvaju svakog 1. u mesecu
          </ThemedText>
        </ThemedView>
      ) : (
        <ThemedView style={styles.reportsContainer}>
          {reports.map((report) => (
            <ThemedView key={report.id} style={styles.reportCard}>
              {/* Month Header */}
              <View style={styles.monthHeader}>
                <ThemedText type="defaultSemiBold" style={styles.monthTitle}>
                  {formatMonthYear(report.month)}
                </ThemedText>
                <ThemedText style={styles.savedDate}>
                  Sačuvano: {new Date(report.savedAt).toLocaleDateString('sr-RS')}
                </ThemedText>
              </View>

              {/* Summary Stats */}
              <View style={styles.summaryContainer}>
                <View style={styles.summaryRow}>
                  <ThemedText style={styles.summaryLabel}>Ukupan budžet:</ThemedText>
                  <ThemedText style={styles.summaryValue}>
                    {report.totalBudget.toLocaleString()} din
                  </ThemedText>
                </View>
                <View style={styles.summaryRow}>
                  <ThemedText style={styles.summaryLabel}>Ukupno potrošeno:</ThemedText>
                  <ThemedText style={[styles.summaryValue, styles.spentText]}>
                    {report.totalSpent.toLocaleString()} din
                  </ThemedText>
                </View>
                <View style={[styles.summaryRow, styles.remainingRow]}>
                  <ThemedText style={styles.summaryLabelBold}>Preostalo na kraju:</ThemedText>
                  <ThemedText
                    style={[
                      styles.summaryValueBold,
                      report.totalRemaining >= 0 ? styles.positiveText : styles.negativeText,
                    ]}
                  >
                    {report.totalRemaining.toLocaleString()} din
                  </ThemedText>
                </View>

                {/* Percentage Summary */}
                <View style={styles.percentageContainer}>
                  <ThemedText style={styles.percentageText}>
                    Potrošeno: {((report.totalSpent / report.totalBudget) * 100).toFixed(1)}%
                  </ThemedText>
                </View>
              </View>

              {/* Categories Breakdown */}
              <View style={styles.categoriesBreakdown}>
                <ThemedText style={styles.breakdownTitle}>Po kategorijama:</ThemedText>
                {report.categories.map((category) => {
                  const remaining = category.budget - category.spent;
                  const percentage = (category.spent / category.budget) * 100;

                  return (
                    <View key={category.id} style={styles.categoryRow}>
                      <View style={styles.categoryRowHeader}>
                        <View style={[styles.colorDot, { backgroundColor: category.color }]} />
                        <ThemedText style={styles.categoryRowName}>{category.name}</ThemedText>
                      </View>
                      <View style={styles.categoryRowStats}>
                        <ThemedText style={styles.categoryRowStat}>
                          {category.spent.toLocaleString()} / {category.budget.toLocaleString()} din
                        </ThemedText>
                        <ThemedText
                          style={[
                            styles.categoryRowRemaining,
                            remaining >= 0 ? styles.positiveSmall : styles.negativeSmall,
                          ]}
                        >
                          ({percentage.toFixed(0)}%)
                        </ThemedText>
                      </View>
                    </View>
                  );
                })}
              </View>
            </ThemedView>
          ))}
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
    marginBottom: 8,
  },
  headerSubtitle: {
    fontSize: 14,
    opacity: 0.7,
  },
  emptyState: {
    padding: 40,
    alignItems: 'center',
  },
  emptyStateText: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
    textAlign: 'center',
  },
  emptyStateSubtext: {
    fontSize: 14,
    opacity: 0.6,
    textAlign: 'center',
  },
  reportsContainer: {
    paddingHorizontal: 20,
  },
  reportCard: {
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: 'rgba(100, 100, 100, 0.2)',
  },
  monthHeader: {
    marginBottom: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(100, 100, 100, 0.2)',
  },
  monthTitle: {
    fontSize: 20,
    marginBottom: 4,
  },
  savedDate: {
    fontSize: 12,
    opacity: 0.6,
  },
  summaryContainer: {
    marginBottom: 16,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  summaryLabel: {
    fontSize: 14,
  },
  summaryValue: {
    fontSize: 14,
    fontWeight: '600',
  },
  summaryLabelBold: {
    fontSize: 15,
    fontWeight: '700',
  },
  summaryValueBold: {
    fontSize: 15,
    fontWeight: '700',
  },
  remainingRow: {
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: 'rgba(100, 100, 100, 0.2)',
  },
  spentText: {
    color: '#FFA07A',
  },
  positiveText: {
    color: '#52B788',
  },
  negativeText: {
    color: '#E63946',
  },
  positiveSmall: {
    color: '#52B788',
  },
  negativeSmall: {
    color: '#E63946',
  },
  percentageContainer: {
    marginTop: 8,
    padding: 8,
    backgroundColor: 'rgba(100, 100, 100, 0.1)',
    borderRadius: 6,
    alignItems: 'center',
  },
  percentageText: {
    fontSize: 13,
    fontWeight: '600',
  },
  categoriesBreakdown: {
    marginTop: 8,
  },
  breakdownTitle: {
    fontSize: 13,
    fontWeight: '600',
    marginBottom: 8,
    opacity: 0.7,
  },
  categoryRow: {
    marginBottom: 10,
  },
  categoryRowHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  colorDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 8,
  },
  categoryRowName: {
    fontSize: 14,
    fontWeight: '600',
  },
  categoryRowStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingLeft: 20,
  },
  categoryRowStat: {
    fontSize: 13,
    opacity: 0.8,
  },
  categoryRowRemaining: {
    fontSize: 13,
    fontWeight: '600',
  },
  bottomPadding: {
    height: 40,
  },
});
