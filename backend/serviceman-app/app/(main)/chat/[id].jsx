import { useEffect, useState, useRef } from 'react';
import { View, StyleSheet, FlatList, TextInput, KeyboardAvoidingView, Platform, TouchableOpacity } from 'react-native';
import { Text, IconButton, Avatar, ActivityIndicator } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { chatService } from '../../../src/api';
import { useAuthStore } from '../../../src/store/authStore';
import { COLORS, iOS, TYPOGRAPHY } from '../../../src/theme/theme';

export default function ChatDetailScreen() {
  const { id: channelId } = useLocalSearchParams();
  const router = useRouter();
  const { user } = useAuthStore();
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [isSending, setIsSending] = useState(false);
  const flatListRef = useRef(null);

  useEffect(() => {
    fetchMessages();
  }, []);

  const fetchMessages = async () => {
    try {
      const response = await chatService.getConversation(channelId, 50, 1);
      setMessages(response.data.content?.data || []);
    } catch (error) {
      console.log('Messages fetch error:', error);
    }
    setIsLoading(false);
  };

  const sendMessage = async () => {
    if (!inputText.trim() || isSending) return;
    const text = inputText.trim();
    setInputText('');
    setIsSending(true);

    try {
      await chatService.sendMessage(channelId, text);
      await fetchMessages();
    } catch (error) {
      console.log('Send error:', error);
      setInputText(text);
    }
    setIsSending(false);
  };

  const renderMessage = ({ item }) => {
    const isMe = item.sender_id === user?.id;
    return (
      <View style={[styles.messageBubble, isMe ? styles.myMessage : styles.otherMessage]}>
        {!isMe && (
          <Avatar.Text
            size={36}
            label={(item.sender?.fName || 'U')[0]}
            style={styles.messageAvatar}
            labelStyle={styles.avatarLabel}
          />
        )}
        <View style={[styles.messageContent, isMe ? styles.myMessageContent : styles.otherMessageContent]}>
          <Text style={[styles.messageText, isMe && styles.myMessageText]}>
            {item.message || ''}
          </Text>
          <Text style={[styles.messageTime, isMe && styles.myMessageTime]}>
            {item.created_at ? new Date(item.created_at).toLocaleTimeString('en-US', {
              hour: '2-digit', minute: '2-digit',
            }) : ''}
          </Text>
        </View>
      </View>
    );
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 80}
    >
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="chevron-back" size={24} color={COLORS.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Chat</Text>
        <View style={styles.headerRight} />
      </View>

      {/* Messages */}
      {isLoading ? (
        <View style={styles.loader}>
          <ActivityIndicator size="large" color={COLORS.primary} />
          <Text style={styles.loaderText}>Loading messages...</Text>
        </View>
      ) : (
        <FlatList
          ref={flatListRef}
          data={messages}
          keyExtractor={(item) => item.id?.toString() || Math.random().toString()}
          renderItem={renderMessage}
          contentContainerStyle={styles.messageList}
          inverted
          showsVerticalScrollIndicator={false}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Ionicons name="chatbubble-outline" size={64} color={COLORS.greyLight} />
              <Text style={styles.emptyText}>No messages yet</Text>
              <Text style={styles.emptySubtext}>Start the conversation</Text>
            </View>
          }
        />
      )}

      {/* Input */}
      <View style={styles.inputBar}>
        <TextInput
          value={inputText}
          onChangeText={setInputText}
          placeholder="Type a message..."
          style={styles.textInput}
          multiline
          maxLength={1000}
          mode="outlined"
          outlineStyle={styles.textInputOutline}
          theme={{ colors: { primary: COLORS.primary } }}
          dense
        />
        <TouchableOpacity
          style={[styles.sendBtn, inputText.trim() && styles.sendBtnActive]}
          onPress={sendMessage}
          disabled={!inputText.trim() || isSending}
        >
          <Ionicons 
            name="send" 
            size={20} 
            color={inputText.trim() ? COLORS.white : COLORS.textTertiary} 
          />
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingTop: iOS.spacing.xxxxxl,
    paddingBottom: iOS.spacing.lg,
    backgroundColor: COLORS.surface,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.separatorLight,
    ...iOS.shadowSmall,
  },
  backBtn: {
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
    flex: 1,
    textAlign: 'center',
  },
  headerRight: {
    width: 40,
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
  messageList: {
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingTop: iOS.spacing.lg,
    paddingBottom: iOS.spacing.lg,
  },
  messageBubble: {
    flexDirection: 'row',
    marginBottom: iOS.spacing.lg,
    maxWidth: '80%',
  },
  myMessage: {
    alignSelf: 'flex-end',
    flexDirection: 'row-reverse',
  },
  otherMessage: {
    alignSelf: 'flex-start',
  },
  messageAvatar: {
    backgroundColor: COLORS.primary,
    marginRight: iOS.spacing.sm,
  },
  avatarLabel: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.white,
  },
  messageContent: {
    padding: iOS.spacing.md,
    borderRadius: iOS.borderRadius.xl,
    maxWidth: '100%',
  },
  myMessageContent: {
    backgroundColor: COLORS.primary,
    borderBottomRightRadius: iOS.borderRadius.xs,
  },
  otherMessageContent: {
    backgroundColor: COLORS.surface,
    borderBottomLeftRadius: iOS.borderRadius.xs,
    ...iOS.shadowSmall,
  },
  messageText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textPrimary,
    lineHeight: TYPOGRAPHY.lineHeight.relaxed,
  },
  myMessageText: {
    color: COLORS.white,
  },
  messageTime: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.textTertiary,
    marginTop: iOS.spacing.xs,
    alignSelf: 'flex-end',
  },
  myMessageTime: {
    color: 'rgba(255,255,255,0.7)',
  },
  inputBar: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    padding: iOS.spacing.md,
    backgroundColor: COLORS.surface,
    borderTopWidth: 1,
    borderTopColor: COLORS.separatorLight,
    gap: iOS.spacing.sm,
  },
  textInput: {
    flex: 1,
    backgroundColor: COLORS.background,
    borderRadius: iOS.borderRadius.xl,
    maxHeight: 100,
  },
  textInputOutline: {
    borderRadius: iOS.borderRadius.xl,
    borderWidth: 1,
    borderColor: COLORS.separator,
  },
  sendBtn: {
    width: 44,
    height: 44,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.separatorLight,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 2,
  },
  sendBtnActive: {
    backgroundColor: COLORS.primary,
    ...iOS.shadowSmall,
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
