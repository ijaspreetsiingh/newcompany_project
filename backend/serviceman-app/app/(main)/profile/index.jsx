import { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Alert, Modal } from 'react-native';
import { Text, Avatar, Button, TextInput, Divider, Card } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useAuthStore } from '../../../src/store/authStore';
import { COLORS, iOS, TYPOGRAPHY } from '../../../src/theme/theme';

export default function ProfileScreen() {
  const router = useRouter();
  const { user, logout, updateProfile, isLoading } = useAuthStore();
  const [editing, setEditing] = useState(false);
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [drawerVisible, setDrawerVisible] = useState(false);

  useEffect(() => {
    if (user) {
      setFirstName(user.fName || '');
      setLastName(user.lName || '');
      setEmail(user.email || '');
    }
  }, [user]);

  const handleSave = async () => {
    const result = await updateProfile({
      first_name: firstName,
      last_name: lastName,
      email: email,
    });
    if (result.success) {
      setEditing(false);
      Alert.alert('Success', 'Profile updated successfully');
    } else {
      Alert.alert('Error', 'Failed to update profile');
    }
  };

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to logout?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Logout', style: 'destructive', onPress: () => logout() },
    ]);
  };

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.contentContainer} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => setDrawerVisible(true)} style={styles.menuBtn}>
            <Ionicons name="menu" size={24} color={COLORS.textPrimary} />
          </TouchableOpacity>
          <Text style={styles.title}>Profile</Text>
          <View style={{ width: 40 }} />
        </View>

        {/* Profile Header */}
        <View style={styles.profileHeader}>
          <View style={styles.avatarContainer}>
            <Avatar.Text
              size={80}
              label={`${(user?.fName || 'S')[0]}${(user?.lName || 'M')[0]}`}
              style={styles.avatar}
              labelStyle={styles.avatarLabel}
            />
            <TouchableOpacity style={styles.editAvatarBtn}>
              <Ionicons name="camera" size={16} color={COLORS.white} />
            </TouchableOpacity>
          </View>
          <Text style={styles.profileName}>{user?.fName || 'Serviceman'} {user?.lName || ''}</Text>
          <Text style={styles.profilePhone}>{user?.email || user?.phone || 'N/A'}</Text>
        </View>

      {/* Profile Info */}
      <Card style={styles.card}>
        <Card.Content>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Personal Information</Text>
            <TouchableOpacity onPress={() => setEditing(!editing)} style={styles.editBtn}>
              <Ionicons name={editing ? 'close' : 'create-outline'} size={22} color={COLORS.primary} />
            </TouchableOpacity>
          </View>
          <Divider style={styles.divider} />

          {editing ? (
            <View style={styles.editForm}>
              <TextInput
                label="First Name"
                value={firstName}
                onChangeText={setFirstName}
                mode="outlined"
                style={styles.input}
                outlineStyle={styles.inputOutline}
                theme={{ colors: { primary: COLORS.primary } }}
                dense
              />
              <TextInput
                label="Last Name"
                value={lastName}
                onChangeText={setLastName}
                mode="outlined"
                style={styles.input}
                outlineStyle={styles.inputOutline}
                theme={{ colors: { primary: COLORS.primary } }}
                dense
              />
              <TextInput
                label="Email"
                value={email}
                onChangeText={setEmail}
                mode="outlined"
                keyboardType="email-address"
                autoCapitalize="none"
                style={styles.input}
                outlineStyle={styles.inputOutline}
                theme={{ colors: { primary: COLORS.primary } }}
                dense
              />
              <Button
                mode="contained"
                onPress={handleSave}
                loading={isLoading}
                style={styles.saveButton}
                contentStyle={styles.saveButtonContent}
                labelStyle={styles.saveButtonLabel}
                buttonColor={COLORS.primary}
                icon="checkmark"
              >
                Save Changes
              </Button>
            </View>
          ) : (
            <View style={styles.infoList}>
              <InfoRow icon="person-outline" label="First Name" value={user?.fName || 'N/A'} />
              <InfoRow icon="person-outline" label="Last Name" value={user?.lName || 'N/A'} />
              <InfoRow icon="mail-outline" label="Email" value={user?.email || 'N/A'} />
              <InfoRow icon="call-outline" label="Phone" value={user?.phone || 'N/A'} />
            </View>
          )}
        </Card.Content>
      </Card>

      {/* Menu Items */}
      <Card style={styles.card}>
        <Card.Content>
          <MenuItem
            icon="key-outline"
            label="Change Password"
            onPress={() => Alert.alert('Coming Soon', 'Password change feature')}
          />
          <Divider style={styles.divider} />
          <MenuItem
            icon="language-outline"
            label="Language"
            onPress={() => Alert.alert('Coming Soon', 'Language selection')}
          />
          <Divider style={styles.divider} />
          <MenuItem
            icon="help-circle-outline"
            label="Help & Support"
            onPress={() => Alert.alert('Support', 'Contact support@jassbooking.com')}
          />
          <Divider style={styles.divider} />
          <MenuItem
            icon="document-text-outline"
            label="Terms & Conditions"
            onPress={() => Alert.alert('Terms', 'Terms & conditions page')}
          />
        </Card.Content>
      </Card>

      {/* Logout Button */}
      <Button
        mode="outlined"
        onPress={handleLogout}
        icon="logout-variant"
        style={styles.logoutButton}
        contentStyle={styles.logoutButtonContent}
        labelStyle={styles.logoutButtonLabel}
        textColor={COLORS.error}
      >
        Logout
      </Button>

      <Text style={styles.version}>Version 1.0.0</Text>
      </ScrollView>

      {/* Sidebar Drawer */}
      <Modal
        visible={drawerVisible}
        transparent={true}
        animationType="slide"
        onRequestClose={() => setDrawerVisible(false)}
      >
        <TouchableOpacity
          style={styles.drawerOverlay}
          activeOpacity={1}
          onPress={() => setDrawerVisible(false)}
        >
          <TouchableOpacity
            style={styles.drawerContent}
            activeOpacity={1}
            onPress={(e) => e.stopPropagation()}
          >
            <View style={styles.drawerHeader}>
              <Avatar.Text
                size={60}
                label={`${(user?.fName || 'S')[0]}${(user?.lName || 'M')[0]}`}
                style={styles.drawerAvatar}
                labelStyle={styles.drawerAvatarLabel}
              />
              <Text style={styles.drawerName}>{user?.fName || 'Serviceman'} {user?.lName || ''}</Text>
              <Text style={styles.drawerEmail}>{user?.email || user?.phone || 'N/A'}</Text>
            </View>

            <View style={styles.drawerMenu}>
              <DrawerItem
                icon="home-outline"
                label="Home"
                onPress={() => { setDrawerVisible(false); router.push('/(main)'); }}
              />
              <DrawerItem
                icon="calendar-outline"
                label="Bookings"
                onPress={() => { setDrawerVisible(false); router.push('/(main)/bookings'); }}
              />
              <DrawerItem
                icon="chatbubble-outline"
                label="Messages"
                onPress={() => { setDrawerVisible(false); router.push('/(main)/chat'); }}
              />
              <DrawerItem
                icon="notifications-outline"
                label="Notifications"
                onPress={() => { setDrawerVisible(false); router.push('/(main)/notifications'); }}
              />
              <DrawerItem
                icon="person-outline"
                label="Profile"
                onPress={() => { setDrawerVisible(false); router.push('/(main)/profile'); }}
              />
              <Divider style={styles.drawerDivider} />
              <DrawerItem
                icon="settings-outline"
                label="Settings"
                onPress={() => { setDrawerVisible(false); Alert.alert('Coming Soon', 'Settings'); }}
              />
              <DrawerItem
                icon="help-circle-outline"
                label="Help & Support"
                onPress={() => { setDrawerVisible(false); Alert.alert('Support', 'Contact support@jassbooking.com'); }}
              />
              <DrawerItem
                icon="information-circle-outline"
                label="About"
                onPress={() => { setDrawerVisible(false); Alert.alert('About', 'Jass Booking Serviceman App v1.0.0'); }}
              />
            </View>

            <TouchableOpacity style={styles.drawerLogout} onPress={handleLogout}>
              <Ionicons name="logout-variant" size={24} color={COLORS.error} />
              <Text style={styles.drawerLogoutText}>Logout</Text>
            </TouchableOpacity>
          </TouchableOpacity>
        </TouchableOpacity>
      </Modal>
    </View>
  );
}

function InfoRow({ icon, label, value }) {
  return (
    <View style={styles.infoRow}>
      <View style={[styles.infoIconBg, { backgroundColor: COLORS.primaryAlpha }]}>
        <Ionicons name={icon} size={18} color={COLORS.primary} />
      </View>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={styles.infoValue}>{value}</Text>
    </View>
  );
}

function MenuItem({ icon, label, onPress }) {
  return (
    <TouchableOpacity style={styles.menuItem} onPress={onPress} activeOpacity={0.7}>
      <View style={[styles.menuIconBg, { backgroundColor: COLORS.infoAlpha }]}>
        <Ionicons name={icon} size={20} color={COLORS.info} />
      </View>
      <Text style={styles.menuLabel}>{label}</Text>
      <Ionicons name="chevron-forward" size={18} color={COLORS.textTertiary} />
    </TouchableOpacity>
  );
}

function DrawerItem({ icon, label, onPress }) {
  return (
    <TouchableOpacity style={styles.drawerItem} onPress={onPress} activeOpacity={0.7}>
      <Ionicons name={icon} size={24} color={COLORS.textPrimary} />
      <Text style={styles.drawerItemLabel}>{label}</Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  scrollView: {
    flex: 1,
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
    marginBottom: iOS.spacing.xl,
  },
  menuBtn: {
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: TYPOGRAPHY.fontSize.xxxl,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.textPrimary,
  },
  profileHeader: {
    alignItems: 'center',
    marginBottom: iOS.spacing.xl,
  },
  avatarContainer: {
    position: 'relative',
    marginBottom: iOS.spacing.md,
  },
  avatar: {
    backgroundColor: COLORS.primary,
  },
  avatarLabel: {
    fontSize: TYPOGRAPHY.fontSize.xxxl,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.white,
  },
  editAvatarBtn: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    width: 32,
    height: 32,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 3,
    borderColor: COLORS.surface,
    ...iOS.shadowSmall,
  },
  profileName: {
    fontSize: TYPOGRAPHY.fontSize.xxl,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
    marginBottom: iOS.spacing.xs,
  },
  profilePhone: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
  },
  card: {
    marginBottom: iOS.spacing.lg,
    borderRadius: iOS.borderRadius.xl,
    backgroundColor: COLORS.surface,
    ...iOS.shadowSmall,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: iOS.spacing.md,
  },
  cardTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
  },
  editBtn: {
    width: 36,
    height: 36,
    borderRadius: iOS.borderRadius.base,
    justifyContent: 'center',
    alignItems: 'center',
  },
  divider: {
    backgroundColor: COLORS.separatorLight,
  },
  editForm: {
    gap: iOS.spacing.md,
  },
  input: {
    backgroundColor: COLORS.background,
  },
  inputOutline: {
    borderRadius: iOS.borderRadius.lg,
    borderWidth: 1,
    borderColor: COLORS.separator,
  },
  saveButton: {
    marginTop: iOS.spacing.sm,
    borderRadius: iOS.borderRadius.lg,
    height: iOS.height.button,
    ...iOS.shadowMedium,
  },
  saveButtonContent: {
    height: iOS.height.button,
  },
  saveButtonLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  infoList: {
    gap: iOS.spacing.lg,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.md,
  },
  infoIconBg: {
    width: 36,
    height: 36,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  infoLabel: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    width: 100,
  },
  infoValue: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textPrimary,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    flex: 1,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: iOS.spacing.md,
    gap: iOS.spacing.md,
  },
  menuIconBg: {
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  menuLabel: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textPrimary,
    flex: 1,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  logoutButton: {
    borderRadius: iOS.borderRadius.lg,
    borderColor: COLORS.error,
    marginTop: iOS.spacing.md,
    height: iOS.height.button,
  },
  logoutButtonContent: {
    height: iOS.height.button,
  },
  logoutButtonLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  version: {
    textAlign: 'center',
    color: COLORS.textTertiary,
    marginTop: iOS.spacing.xl,
    fontSize: TYPOGRAPHY.fontSize.sm,
  },
  // Drawer Styles
  drawerOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-start',
  },
  drawerContent: {
    width: '80%',
    maxWidth: 320,
    height: '100%',
    backgroundColor: COLORS.surface,
    paddingTop: iOS.spacing.xxxxxl,
  },
  drawerHeader: {
    paddingHorizontal: iOS.spacing.xl,
    paddingBottom: iOS.spacing.xl,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.separatorLight,
    alignItems: 'center',
  },
  drawerAvatar: {
    backgroundColor: COLORS.primary,
    marginBottom: iOS.spacing.md,
  },
  drawerAvatarLabel: {
    fontSize: TYPOGRAPHY.fontSize.xxl,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.white,
  },
  drawerName: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
    marginBottom: iOS.spacing.xs,
  },
  drawerEmail: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textSecondary,
  },
  drawerMenu: {
    flex: 1,
    paddingTop: iOS.spacing.lg,
  },
  drawerItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: iOS.spacing.xl,
    paddingVertical: iOS.spacing.lg,
    gap: iOS.spacing.md,
  },
  drawerItemLabel: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textPrimary,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  drawerDivider: {
    marginVertical: iOS.spacing.md,
    backgroundColor: COLORS.separatorLight,
  },
  drawerLogout: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: iOS.spacing.xl,
    marginBottom: iOS.spacing.xl,
    paddingVertical: iOS.spacing.lg,
    backgroundColor: COLORS.errorAlpha,
    borderRadius: iOS.borderRadius.lg,
    gap: iOS.spacing.sm,
  },
  drawerLogoutText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.error,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
});
