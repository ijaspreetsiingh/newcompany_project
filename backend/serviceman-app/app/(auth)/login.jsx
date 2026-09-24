import { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform, ScrollView, TouchableOpacity } from 'react-native';
import { Text, TextInput, Button, HelperText } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useAuthStore } from '../../src/store/authStore';
import { COLORS, iOS, TYPOGRAPHY } from '../../src/theme/theme';

export default function LoginScreen() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const { login, isLoading, error, clearError } = useAuthStore();

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) return;
    await login(email.trim(), password.trim());
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 20}
    >
      <ScrollView 
        contentContainerStyle={styles.scrollContent} 
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        {/* Header Section */}
        <View style={styles.headerSection}>
          <View style={styles.logoContainer}>
            <View style={styles.logoCircle}>
              <Ionicons name="construct" size={40} color={COLORS.white} />
            </View>
          </View>
          <Text style={styles.appName}>Jass Booking</Text>
          <Text style={styles.subtitle}>Serviceman Portal</Text>
          <Text style={styles.welcomeText}>Sign in to manage your bookings</Text>
        </View>

        {/* Form Section */}
        <View style={styles.formSection}>
          <TextInput
            label="Email Address"
            value={email}
            onChangeText={(t) => { setEmail(t); clearError(); }}
            mode="outlined"
            keyboardType="email-address"
            autoCapitalize="none"
            autoCorrect={false}
            left={<TextInput.Icon icon={() => <Ionicons name="mail-outline" size={20} color={COLORS.primary} />} />}
            style={styles.input}
            outlineStyle={styles.inputOutline}
            theme={{ colors: { primary: COLORS.primary } }}
            dense
          />

          <TextInput
            label="Password"
            value={password}
            onChangeText={(t) => { setPassword(t); clearError(); }}
            mode="outlined"
            secureTextEntry={!showPassword}
            left={<TextInput.Icon icon={() => <Ionicons name="lock-closed-outline" size={20} color={COLORS.primary} />} />}
            right={
              <TextInput.Icon
                icon={() => <Ionicons name={showPassword ? 'eye-off' : 'eye'} size={20} color={COLORS.textSecondary} />}
                onPress={() => setShowPassword(!showPassword)}
              />
            }
            style={styles.input}
            outlineStyle={styles.inputOutline}
            theme={{ colors: { primary: COLORS.primary } }}
            dense
          />

          {error ? (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color={COLORS.error} />
              <Text style={styles.errorText}>{error}</Text>
            </View>
          ) : null}

          <Button
            mode="contained"
            onPress={handleLogin}
            loading={isLoading}
            disabled={isLoading || !email.trim() || !password.trim()}
            style={styles.loginButton}
            contentStyle={styles.loginButtonContent}
            labelStyle={styles.loginButtonLabel}
            buttonColor={COLORS.primary}
          >
            {isLoading ? 'Signing in...' : 'Sign In'}
          </Button>

          <TouchableOpacity 
            onPress={() => router.push('/(auth)/forgot-password')}
            style={styles.forgotBtn}
          >
            <Text style={styles.forgotBtnLabel}>Forgot Password?</Text>
          </TouchableOpacity>
        </View>

        {/* Footer */}
        <View style={styles.footerSection}>
          <Text style={styles.footerText}>Powered by Jass Booking</Text>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingTop: iOS.spacing.xxxxxl,
    paddingBottom: iOS.spacing.xxxxxl,
  },
  headerSection: {
    alignItems: 'center',
    marginBottom: iOS.spacing.xxxxxl,
  },
  logoContainer: {
    marginBottom: iOS.spacing.lg,
  },
  logoCircle: {
    width: 80,
    height: 80,
    borderRadius: iOS.borderRadius.xxxl,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
    ...iOS.shadowLarge,
  },
  appName: {
    fontSize: TYPOGRAPHY.fontSize.xxxl,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.textPrimary,
    marginBottom: iOS.spacing.xs,
  },
  subtitle: {
    fontSize: TYPOGRAPHY.fontSize.md,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    color: COLORS.primary,
    marginBottom: iOS.spacing.sm,
  },
  welcomeText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
  },
  formSection: {
    gap: iOS.spacing.lg,
  },
  input: {
    backgroundColor: COLORS.surface,
    borderRadius: iOS.borderRadius.lg,
    height: iOS.height.input,
  },
  inputOutline: {
    borderRadius: iOS.borderRadius.lg,
    borderWidth: 1,
    borderColor: COLORS.separator,
  },
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.sm,
    paddingHorizontal: iOS.spacing.sm,
  },
  errorText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.error,
  },
  loginButton: {
    marginTop: iOS.spacing.md,
    borderRadius: iOS.borderRadius.lg,
    height: iOS.height.button,
    ...iOS.shadowMedium,
  },
  loginButtonContent: {
    height: iOS.height.button,
  },
  loginButtonLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  forgotBtn: {
    marginTop: iOS.spacing.sm,
    alignSelf: 'center',
    paddingVertical: iOS.spacing.sm,
  },
  forgotBtnLabel: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    color: COLORS.primary,
  },
  footerSection: {
    marginTop: iOS.spacing.xxxxxl,
    alignItems: 'center',
  },
  footerText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.textQuaternary,
  },
});