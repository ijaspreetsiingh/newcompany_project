import { useEffect } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { Text, Card, Avatar } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useBookingStore } from '../../src/store/bookingStore';
import { useAuthStore } from '../../src/store/authStore';
import { COLORS, iOS, TYPOGRAPHY } from '../../src/theme/theme';

export default function DashboardScreen() {
  const router = useRouter();
  const { dashboardData, fetchDashboard, isLoading } = useBookingStore();
  const { user } = useAuthStore();

  useEffect(() => {
    fetchDashboard();
  }, []);

  const topCards = dashboardData?.top_cards || {};
  const recentBookings = dashboardData?.recent_bookings?.data || [];

  const statCards = [
    {
      title: 'Pending',
      count: topCards.pending_booking ?? 0,
      icon: 'time-outline',
      color: COLORS.warning,
      bgColor: COLORS.warningAlpha,
    },
    {
      title: 'Accepted',
      count: topCards.accepted_booking ?? 0,
      icon: 'checkmark-circle-outline',
      color: COLORS.primary,
      bgColor: COLORS.primaryAlpha,
    },
    {
      title: 'Ongoing',
      count: topCards.ongoing_booking ?? 0,
      icon: 'pulse-outline',
      color: COLORS.purple,
      bgColor: COLORS.purpleAlpha,
    },
    {
      title: 'Completed',
      count: topCards.completed_booking ?? 0,
      icon: 'checkmark-done-circle-outline',
      color: COLORS.success,
      bgColor: COLORS.successAlpha,
    },
  ];

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

  const renderStatCard = (stat, index) => (
    <TouchableOpacity
      key={index}
      style={styles.statCard}
      onPress={() => router.push('/(main)/bookings')}
    >
      <View style={[styles.statIconBg, { backgroundColor: stat.bgColor }]}>
        <Ionicons name={stat.icon} size={24} color={stat.color} />
      </View>
      <Text style={styles.statCount}>{stat.count}</Text>
      <Text style={styles.statTitle}>{stat.title}</Text>
    </TouchableOpacity>
  );

  const renderBookingCard = (booking) => (
    <TouchableOpacity
      key={booking.id}
      style={styles.bookingCard}
      onPress={() => router.push(`/(main)/bookings/${booking.id}`)}
    >
      <View style={styles.bookingHeader}>
        <View style={styles.bookingInfo}>
          <Text style={styles.bookingId}>#{booking.readable_id}</Text>
          <Text style={styles.bookingDate}>
            {booking.created_at
              ? new Date(booking.created_at).toLocaleDateString('en-US', {
                  month: 'short',
                  day: 'numeric',
                  year: 'numeric',
                })
              : ''}
          </Text>
        </View>
        <View style={[styles.statusBadge, { backgroundColor: getStatusBgColor(booking.booking_status) }]}>
          <Text style={[styles.statusText, { color: getStatusColor(booking.booking_status) }]}>
            {booking.booking_status?.toUpperCase()}
          </Text>
        </View>
      </View>

      <View style={styles.bookingBody}>
        <View style={styles.infoRow}>
          <Ionicons name="person-outline" size={16} color={COLORS.textSecondary} />
          <Text style={styles.infoText}>{booking.customer?.fName || 'Customer'}</Text>
        </View>
        <View style={styles.infoRow}>
          <Ionicons name="location-outline" size={16} color={COLORS.textSecondary} />
          <Text style={styles.infoText} numberOfLines={1}>
            {booking.service_address?.address || 'Address not available'}
          </Text>
        </View>
        <View style={styles.infoRow}>
          <Ionicons name="cash-outline" size={16} color={COLORS.textSecondary} />
          <Text style={styles.infoText}>
            {booking.total_booking_amount ? `$${booking.total_booking_amount}` : 'N/A'}
          </Text>
        </View>
      </View>

      <View style={styles.bookingFooter}>
        <Text style={styles.viewDetails}>View Details</Text>
        <Ionicons name="chevron-forward" size={16} color={COLORS.primary} />
      </View>
    </TouchableOpacity>
  );

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.contentContainer}
      refreshControl={
        <RefreshControl
          refreshing={isLoading}
          onRefresh={fetchDashboard}
          tintColor={COLORS.primary}
          colors={[COLORS.primary]}
        />
      }
      showsVerticalScrollIndicator={false}
    >
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <Text style={styles.greeting}>Good Day</Text>
          <Text style={styles.userName}>{user?.fName || 'Serviceman'}</Text>
        </View>
        <TouchableOpacity 
          onPress={() => router.push('/(main)/notifications')} 
          style={styles.notifBtn}
        >
          <Ionicons name="notifications-outline" size={24} color={COLORS.textPrimary} />
          {dashboardData?.unread_notifications_count > 0 && (
            <View style={styles.notifBadge}>
              <Text style={styles.notifBadgeText}>
                {dashboardData.unread_notifications_count > 9 ? '9+' : dashboardData.unread_notifications_count}
              </Text>
            </View>
          )}
        </TouchableOpacity>
      </View>

      {/* Stats Grid */}
      <View style={styles.statsGrid}>
        {statCards.map((stat, index) => renderStatCard(stat, index))}
      </View>

      {/* Recent Bookings */}
      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Recent Bookings</Text>
          <TouchableOpacity onPress={() => router.push('/(main)/bookings')}>
            <Text style={styles.viewAll}>View All</Text>
          </TouchableOpacity>
        </View>

        {recentBookings.length === 0 ? (
          <View style={styles.emptyCard}>
            <Ionicons name="calendar-outline" size={48} color={COLORS.greyLight} />
            <Text style={styles.emptyText}>No recent bookings</Text>
            <Text style={styles.emptySubtext}>Your bookings will appear here</Text>
          </View>
        ) : (
          recentBookings.slice(0, 5).map((booking) => renderBookingCard(booking))
        )}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  contentContainer: {
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingTop: iOS.spacing.xxxxxl,
    paddingBottom: iOS.spacing.xxxxxl,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: iOS.spacing.xxl,
  },
  headerLeft: {
    flex: 1,
  },
  greeting: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    marginBottom: iOS.spacing.xs,
  },
  userName: {
    fontSize: TYPOGRAPHY.fontSize.xxxl,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.textPrimary,
  },
  notifBtn: {
    width: 44,
    height: 44,
    borderRadius: iOS.borderRadius.lg,
    backgroundColor: COLORS.surface,
    justifyContent: 'center',
    alignItems: 'center',
    ...iOS.shadowSmall,
  },
  notifBadge: {
    position: 'absolute',
    top: -2,
    right: -2,
    minWidth: 20,
    height: 20,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.error,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: COLORS.surface,
  },
  notifBadgeText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.white,
    paddingHorizontal: 4,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: iOS.spacing.md,
    marginBottom: iOS.spacing.xxl,
  },
  statCard: {
    width: '47%',
    backgroundColor: COLORS.surface,
    borderRadius: iOS.borderRadius.xl,
    padding: iOS.spacing.lg,
    ...iOS.shadowMedium,
  },
  statIconBg: {
    width: 48,
    height: 48,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: iOS.spacing.md,
  },
  statCount: {
    fontSize: TYPOGRAPHY.fontSize.huge,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.textPrimary,
    marginBottom: iOS.spacing.xs,
  },
  statTitle: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    color: COLORS.textSecondary,
  },
  section: {
    marginBottom: iOS.spacing.xxl,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: iOS.spacing.lg,
  },
  sectionTitle: {
    fontSize: TYPOGRAPHY.fontSize.xxl,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
  },
  viewAll: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.primary,
  },
  bookingCard: {
    backgroundColor: COLORS.surface,
    borderRadius: iOS.borderRadius.xl,
    padding: iOS.spacing.lg,
    marginBottom: iOS.spacing.md,
    ...iOS.shadowSmall,
  },
  bookingHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: iOS.spacing.md,
  },
  bookingInfo: {
    flex: 1,
  },
  bookingId: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.primary,
    marginBottom: iOS.spacing.xs,
  },
  bookingDate: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textSecondary,
  },
  statusBadge: {
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
  bookingBody: {
    gap: iOS.spacing.sm,
    marginBottom: iOS.spacing.md,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.sm,
  },
  infoText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    flex: 1,
  },
  bookingFooter: {
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
  emptyCard: {
    backgroundColor: COLORS.surface,
    borderRadius: iOS.borderRadius.xl,
    padding: iOS.spacing.xxxxxl,
    alignItems: 'center',
    ...iOS.shadowSmall,
  },
  emptyText: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.textSecondary,
    marginTop: iOS.spacing.md,
  },
  emptySubtext: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textTertiary,
    marginTop: iOS.spacing.xs,
  },
});