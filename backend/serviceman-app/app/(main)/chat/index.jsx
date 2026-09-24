import { useEffect, useState } from 'react';
import { View, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { Text, Avatar, ActivityIndicator, Searchbar } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { chatService } from '../../../src/api';
import { COLORS, iOS, TYPOGRAPHY } from '../../../src/theme/theme';

export default function ChatScreen() {
  const router = useRouter();
  const [channels, setChannels] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    fetchChannels();
  }, []);

  const fetchChannels = async (refresh = false) => {
    if (refresh) setIsRefreshing(true);
    else setIsLoading(true);

    try {
      const response = await chatService.getChannels(50, 1);
      setChannels(response.data.content?.data || []);
    } catch (error) {
      console.log('Chat fetch error:', error);
    }
    setIsLoading(false);
    setIsRefreshing(false);
  };

  const filteredChannels = channels.filter((ch) =>
    ch.to_user?.fName?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    ch.to_user?.lName?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const renderChannel = ({ item }) => (
    <TouchableOpacity
      style={styles.channelItem}
      onPress={() => router.push(`/(main)/chat/${item.id}`)}
      activeOpacity={0.7}
    >
      <Avatar.Text
        size={56}
        label={`${(item.to_user?.fName || 'U')[0]}`}
        style={styles.channelAvatar}
        labelStyle={styles.avatarLabel}
      />
      <View style={styles.channelInfo}>
        <View style={styles.channelHeader}>
          <Text style={styles.channelName} numberOfLines={1}>
            {item.to_user?.fName || 'User'} {item.to_user?.lName || ''}
          </Text>
          <Text style={styles.channelTime}>
            {item.last_message?.created_at
              ? new Date(item.last_message.created_at).toLocaleTimeString('en-US', {
                  hour: '2-digit', minute: '2-digit',
                })
              : ''}
          </Text>
        </View>
        <Text style={styles.channelMessage} numberOfLines={2}>
          {item.last_message?.message || 'No messages yet'}
        </Text>
      </View>
      {item.unread_count > 0 && (
        <View style={styles.unreadBadge}>
          <Text style={styles.unreadText}>
            {item.unread_count > 9 ? '9+' : item.unread_count}
          </Text>
        </View>
      )}
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>Messages</Text>
      </View>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <Searchbar
          placeholder="Search conversations..."
          onChangeText={setSearchQuery}
          value={searchQuery}
          style={styles.searchBar}
          inputStyle={styles.searchInput}
          iconColor={COLORS.textSecondary}
          placeholderTextColor={COLORS.textTertiary}
        />
      </View>

      {/* Channel List */}
      {isLoading ? (
        <View style={styles.loader}>
          <ActivityIndicator size="large" color={COLORS.primary} />
          <Text style={styles.loaderText}>Loading conversations...</Text>
        </View>
      ) : (
        <FlatList
          data={filteredChannels}
          keyExtractor={(item) => item.id?.toString() || Math.random().toString()}
          renderItem={renderChannel}
          contentContainerStyle={styles.listContent}
          refreshControl={
            <RefreshControl
              refreshing={isRefreshing}
              onRefresh={() => fetchChannels(true)}
              tintColor={COLORS.primary}
              colors={[COLORS.primary]}
            />
          }
          showsVerticalScrollIndicator={false}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Ionicons name="chatbubbles-outline" size={64} color={COLORS.greyLight} />
              <Text style={styles.emptyText}>No conversations yet</Text>
              <Text style={styles.emptySubtext}>Start a conversation with a customer</Text>
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
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingTop: iOS.spacing.xxxxxl,
    paddingBottom: iOS.spacing.lg,
  },
  title: {
    fontSize: TYPOGRAPHY.fontSize.xxxl,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.textPrimary,
  },
  searchContainer: {
    paddingHorizontal: iOS.screenPadding.horizontal,
    marginBottom: iOS.spacing.md,
  },
  searchBar: {
    borderRadius: iOS.borderRadius.xl,
    backgroundColor: COLORS.surface,
    elevation: 0,
    ...iOS.shadowSmall,
  },
  searchInput: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textPrimary,
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
  channelItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: iOS.spacing.lg,
    backgroundColor: COLORS.surface,
    borderRadius: iOS.borderRadius.xl,
    ...iOS.shadowSmall,
  },
  channelAvatar: {
    backgroundColor: COLORS.primary,
  },
  avatarLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.white,
  },
  channelInfo: {
    flex: 1,
    marginLeft: iOS.spacing.md,
  },
  channelHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: iOS.spacing.xs,
  },
  channelName: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.textPrimary,
    flex: 1,
  },
  channelTime: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.textTertiary,
  },
  channelMessage: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    lineHeight: TYPOGRAPHY.lineHeight.normal,
  },
  unreadBadge: {
    backgroundColor: COLORS.primary,
    borderRadius: iOS.borderRadius.full,
    paddingHorizontal: iOS.spacing.sm,
    paddingVertical: iOS.spacing.xs,
    minWidth: 24,
    minHeight: 24,
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: iOS.spacing.sm,
  },
  unreadText: {
    color: COLORS.white,
    fontSize: TYPOGRAPHY.fontSize.xs,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
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
