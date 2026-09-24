import { useEffect, useState } from 'react';
import { View, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { Text, ActivityIndicator, Chip } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { COLORS, iOS, TYPOGRAPHY } from '../../../src/theme/theme';

const MOCK_NOTIFICATIONS = [
  {
    id: '1',
    title: 'New Booking Request',
    message: 'You have a new booking request from John Doe for AC Repair service.',
    type: 'booking',
    time: '2 min ago',
    read: false,
  },
  {
    id: '2',
    title: 'Booking Accepted',
    message: 'Your booking #12345 has been accepted by the customer.',
    type: 'success',
    time: '15 min ago',
    read: false,
  },
  {
    id: '3',
    title: 'Payment Received',
    message: 'Payment of $150.00 received for booking #12344.',
    type: 'payment',
    time: '1 hour ago',
    read: true,
  },
  {
    id: '4',
    title: 'New Message',
    message: 'You have a new message from Sarah Johnson.',
    type: 'message',
    time: '2 hours ago',
    read: true,
  },
  {
    id: '5',
    title: 'Booking Completed',
    message: 'Booking #12343 has been marked as completed.',
    type: 'success',
    time: '3 hours ago',
    read: true,
  },
  {
    id: '6',
    title: 'System Update',
    message: 'The app has been updated with new features and improvements.',
    type: 'system',
    time: '1 day ago',
    read: true,
  },
];

export default function NotificationsScreen() {
  const router = useRouter();
  const [notifications, setNotifications] = useState(MOCK_NOTIFICATIONS);
  const [isLoading, setIsLoading] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [filter, setFilter] = useState('all');

  const getNotificationIcon = (type) => {
    switch (type) {
      case 'booking': return 'calendar-outline';
      case 'success': return 'checkmark-circle-outline';
      case 'payment': return 'card-outline';
      case 'message': return 'chatbubble-outline';
      case 'system': return 'information-circle-outline';
      default: return 'notifications-outline';
    }
  };

  const getNotificationColor = (type) => {
    switch (type) {
      case 'booking': return COLORS.primary;
      case 'success': return COLORS.success;
      case 'payment': return COLORS.warning;
      case 'message': return COLORS.info;
      case 'system': return COLORS.purple;
      default: return COLORS.grey;
    }
  };

  const getNotificationBgColor = (type) => {
    switch (type) {
      case 'booking': return COLORS.primaryAlpha;
      case 'success': return COLORS.successAlpha;
      case 'payment': return COLORS.warningAlpha;
      case 'message': return COLORS.infoAlpha;
      case 'system': return COLORS.purpleAlpha;
      default: return COLORS.greyLight;
    }
  };

  const filteredNotifications = notifications.filter((notif) => {
    if (filter === 'all') return true;
    if (filter === 'unread') return !notif.read;
    return true;
  });

  const markAsRead = (id) => {
    setNotifications(notifications.map(n => 
      n.id === id ? { ...n, read: true } : n
    ));
  };

  const markAllAsRead = () => {
    setNotifications(notifications.map(n => ({ ...n, read: true })));
  };

  const renderNotification = ({ item }) => (
    <TouchableOpacity
      style={[styles.notificationItem, !item.read && styles.unreadItem]}
      onPress={() => markAsRead(item.id)}
      activeOpacity={0.7}
    >
      <View style={[styles.iconBg, { backgroundColor: getNotificationBgColor(item.type) }]}>
        <Ionicons 
          name={getNotificationIcon(item.type)} 
          size={24} 
          color={getNotificationColor(item.type)} 
        />
      </View>
      <View style={styles.notificationContent}>
        <View style={styles.notificationHeader}>
          <Text style={[styles.notificationTitle, !item.read && styles.unreadTitle]}>
            {item.title}
          </Text>
          <Text style={styles.notificationTime}>{item.time}</Text>
        </View>
        <Text style={styles.notificationMessage} numberOfLines={2}>
          {item.message}
        </Text>
      </View>
      {!item.read && <View style={styles.unreadDot} />}
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>Notifications</Text>
        {notifications.some(n => !n.read) && (
          <TouchableOpacity onPress={markAllAsRead} style={styles.markReadBtn}>
            <Text style={styles.markReadText}>Mark all read</Text>
          </TouchableOpacity>
        )}
      </View>

      {/* Filter Chips */}
      <View style={styles.filterContainer}>
        <Chip
          selected={filter === 'all'}
          onPress={() => setFilter('all')}
          style={[styles.filterChip, filter === 'all' && styles.filterChipActive]}
          textStyle={[styles.filterChipText, filter === 'all' && styles.filterChipTextActive]}
          showSelectedOverlay={false}
        >
          All
        </Chip>
        <Chip
          selected={filter === 'unread'}
          onPress={() => setFilter('unread')}
          style={[styles.filterChip, filter === 'unread' && styles.filterChipActive]}
          textStyle={[styles.filterChipText, filter === 'unread' && styles.filterChipTextActive]}
          showSelectedOverlay={false}
        >
          Unread
        </Chip>
      </View>

      {/* Notification List */}
      {isLoading ? (
        <View style={styles.loader}>
          <ActivityIndicator size="large" color={COLORS.primary} />
          <Text style={styles.loaderText}>Loading notifications...</Text>
        </View>
      ) : (
        <FlatList
          data={filteredNotifications}
          keyExtractor={(item) => item.id}
          renderItem={renderNotification}
          contentContainerStyle={styles.listContent}
          refreshControl={
            <RefreshControl
              refreshing={isRefreshing}
              onRefresh={() => {
                setIsRefreshing(true);
                setTimeout(() => setIsRefreshing(false), 1000);
              }}
              tintColor={COLORS.primary}
              colors={[COLORS.primary]}
            />
          }
          showsVerticalScrollIndicator={false}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Ionicons name="notifications-off-outline" size={64} color={COLORS.greyLight} />
              <Text style={styles.emptyText}>No notifications</Text>
              <Text style={styles.emptySubtext}>You're all caught up!</Text>
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
  markReadBtn: {
    paddingHorizontal: iOS.spacing.md,
    paddingVertical: iOS.spacing.xs,
  },
  markReadText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.primary,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  filterContainer: {
    flexDirection: 'row',
    gap: iOS.spacing.sm,
    paddingHorizontal: iOS.screenPadding.horizontal,
    marginBottom: iOS.spacing.md,
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
  listContent: {
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingBottom: iOS.spacing.xxxxxl,
    gap: iOS.spacing.sm,
  },
  notificationItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    padding: iOS.spacing.lg,
    backgroundColor: COLORS.surface,
    borderRadius: iOS.borderRadius.xl,
    ...iOS.shadowSmall,
  },
  unreadItem: {
    backgroundColor: COLORS.primaryLight,
    borderWidth: 1,
    borderColor: COLORS.primaryAlpha,
  },
  iconBg: {
    width: 48,
    height: 48,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: iOS.spacing.md,
  },
  notificationContent: {
    flex: 1,
  },
  notificationHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: iOS.spacing.xs,
  },
  notificationTitle: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.textPrimary,
    flex: 1,
  },
  unreadTitle: {
    fontWeight: TYPOGRAPHY.fontWeight.bold,
  },
  notificationTime: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.textTertiary,
    marginLeft: iOS.spacing.sm,
  },
  notificationMessage: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textSecondary,
    lineHeight: TYPOGRAPHY.lineHeight.normal,
  },
  unreadDot: {
    width: 8,
    height: 8,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.primary,
    marginTop: 6,
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
