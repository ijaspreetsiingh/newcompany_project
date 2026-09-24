import { useEffect } from 'react';
import { View, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { Text, Chip, ActivityIndicator } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useBookingStore } from '../../../src/store/bookingStore';
import { COLORS, iOS, TYPOGRAPHY } from '../../../src/theme/theme';

const FILTERS = [
  { key: 'all', label: 'All' },
  { key: 'pending', label: 'Pending' },
  { key: 'accepted', label: 'Accepted' },
  { key: 'ongoing', label: 'Ongoing' },
  { key: 'completed', label: 'Completed' },
  { key: 'canceled', label: 'Canceled' },
];

export default function BookingsScreen() {
  const router = useRouter();
  const {
    bookings, isLoading, isRefreshing, currentFilter,
    fetchBookings, setFilter, totalCount,
  } = useBookingStore();

  useEffect(() => {
    fetchBookings(true);
  }, [currentFilter]);

  const getStatusColor = (status) => {
    switch (status) {
      case 'pending': return COLORS.warning;
      case 'accepted': return COLORS.primary;
      case 'ongoing': return COLORS.purple;
      case 'completed': return COLORS.success;
      case 'canceled': return COLORS.error;
      default: return COLORS.grey;
    }
  };

  const getStatusBgColor = (status) => {
    switch (status) {
      case 'pending': return COLORS.warningAlpha;
      case 'accepted': return COLORS.primaryAlpha;
      case 'ongoing': return COLORS.purpleAlpha;
      case 'completed': return COLORS.successAlpha;
      case 'canceled': return COLORS.errorAlpha;
      default: return COLORS.greyLight;
    }
  };

  const renderBooking = ({ item }) => (
    <TouchableOpacity
      style={styles.bookingCard}
      onPress={() => router.push(`/(main)/bookings/${item.id}`)}
      activeOpacity={0.7}
    >
      <View style={styles.cardHeader}>
        <View style={styles.cardHeaderLeft}>
          <Text style={styles.bookingId}>#{item.readable_id}</Text>
          <Text style={styles.bookingDate}>
            {item.created_at ? new Date(item.created_at).toLocaleDateString('en-US', {
              month: 'short', day: 'numeric', year: 'numeric'
            }) : ''}
          </Text>
        </View>
        <View style={[styles.statusChip, { backgroundColor: getStatusBgColor(item.booking_status) }]}>
          <Text style={[styles.statusText, { color: getStatusColor(item.booking_status) }]}>
            {item.booking_status?.toUpperCase()}
          </Text>
        </View>
      </View>

      <View style={styles.cardBody}>
        <View style={styles.infoRow}>
          <View style={[styles.infoIconBg, { backgroundColor: COLORS.primaryAlpha }]}>
            <Ionicons name="person-outline" size={16} color={COLORS.primary} />
          </View>
          <Text style={styles.infoText} numberOfLines={1}>
            {item.customer?.fName || 'Customer'}
          </Text>
        </View>
        <View style={styles.infoRow}>
          <View style={[styles.infoIconBg, { backgroundColor: COLORS.errorAlpha }]}>
            <Ionicons name="location-outline" size={16} color={COLORS.error} />
          </View>
          <Text style={styles.infoText} numberOfLines={1}>
            {item.service_address?.address || 'Address not available'}
          </Text>
        </View>
        <View style={styles.infoRow}>
          <View style={[styles.infoIconBg, { backgroundColor: COLORS.successAlpha }]}>
            <Ionicons name="cash-outline" size={16} color={COLORS.success} />
          </View>
          <Text style={styles.infoText}>
            {item.total_booking_amount ? `$${item.total_booking_amount}` : 'N/A'}
          </Text>
        </View>
      </View>

      <View style={styles.cardFooter}>
        <Text style={styles.viewDetails}>View Details</Text>
        <Ionicons name="chevron-forward" size={16} color={COLORS.primary} />
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>My Bookings</Text>
        <View style={styles.countBadge}>
          <Text style={styles.count}>{totalCount}</Text>
        </View>
      </View>

      {/* Filter Chips */}
      <View style={styles.filterContainer}>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={FILTERS}
          keyExtractor={(item) => item.key}
          contentContainerStyle={styles.filterList}
          renderItem={({ item }) => (
            <Chip
              selected={currentFilter === item.key}
              onPress={() => setFilter(item.key)}
              style={[
                styles.filterChip,
                currentFilter === item.key && styles.filterChipActive,
              ]}
              textStyle={[
                styles.filterChipText,
                currentFilter === item.key && styles.filterChipTextActive,
              ]}
              showSelectedOverlay={false}
              elevation={currentFilter === item.key ? 2 : 0}
            >
              {item.label}
            </Chip>
          )}
        />
      </View>

      {/* Booking List */}
      {isLoading && bookings.length === 0 ? (
        <View style={styles.loader}>
          <ActivityIndicator size="large" color={COLORS.primary} />
          <Text style={styles.loaderText}>Loading bookings...</Text>
        </View>
      ) : (
        <FlatList
          data={bookings}
          keyExtractor={(item) => item.id?.toString() || Math.random().toString()}
          renderItem={renderBooking}
          contentContainerStyle={styles.listContent}
          refreshControl={
            <RefreshControl
              refreshing={isRefreshing}
              onRefresh={() => fetchBookings(true)}
              tintColor={COLORS.primary}
              colors={[COLORS.primary]}
            />
          }
          onEndReached={() => fetchBookings(false)}
          onEndReachedThreshold={0.3}
          showsVerticalScrollIndicator={false}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Ionicons name="calendar-outline" size={64} color={COLORS.greyLight} />
              <Text style={styles.emptyText}>No bookings found</Text>
              <Text style={styles.emptySubtext}>Bookings will appear here once assigned</Text>
            </View>
          }
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingTop: iOS.spacing.xxxxxl,
    paddingBottom: iOS.spacing.lg,
  },
  title: {
    fontSize: TYPOGRAPHY.fontSize.xxxl,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.textPrimary,
  },
  countBadge: {
    backgroundColor: COLORS.primary,
    paddingHorizontal: iOS.spacing.md,
    paddingVertical: iOS.spacing.xs,
    borderRadius: iOS.borderRadius.full,
    ...iOS.shadowSmall,
  },
  count: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.white,
  },
  filterContainer: {
    marginBottom: iOS.spacing.md,
  },
  filterList: {
    paddingHorizontal: iOS.screenPadding.horizontal,
    gap: iOS.spacing.sm,
  },
  filterChip: {
    backgroundColor: COLORS.surface,
    borderRadius: iOS.borderRadius.xl,
    borderWidth: 1,
    borderColor: COLORS.separator,
  },
  filterChipActive: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  filterChipText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    color: COLORS.textSecondary,
  },
  filterChipTextActive: {
    color: COLORS.white,
  },
  listContent: {
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingBottom: iOS.spacing.xxxxxl,
    gap: iOS.spacing.md,
  },
  bookingCard: {
    backgroundColor: COLORS.surface,
    borderRadius: iOS.borderRadius.xl,
    padding: iOS.spacing.lg,
    ...iOS.shadowSmall,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: iOS.spacing.md,
  },
  cardHeaderLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.sm,
  },
  bookingId: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.primary,
  },
  bookingDate: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textSecondary,
  },
  statusChip: {
    paddingHorizontal: iOS.spacing.md,
    paddingVertical: iOS.spacing.xs,
    borderRadius: iOS.borderRadius.base,
  },
  statusText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  cardBody: {
    gap: iOS.spacing.sm,
    marginBottom: iOS.spacing.md,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.sm,
  },
  infoIconBg: {
    width: 32,
    height: 32,
    borderRadius: iOS.borderRadius.base,
    justifyContent: 'center',
    alignItems: 'center',
  },
  infoText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    flex: 1,
  },
  cardFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingTop: iOS.spacing.sm,
    borderTopWidth: 1,
    borderTopColor: COLORS.separatorLight,
  },
  viewDetails: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.primary,
  },
  loader: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: iOS.spacing.md,
  },
  loaderText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
  },
  emptyContainer: {
    alignItems: 'center',
    paddingTop: iOS.spacing.xxxxxl,
    gap: iOS.spacing.md,
  },
  emptyText: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.textSecondary,
  },
  emptySubtext: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textTertiary,
  },
});
