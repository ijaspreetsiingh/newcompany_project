import { useState } from 'react';
import { View, StyleSheet, KeyboardAvoidingView, Platform, ScrollView, TouchableOpacity } from 'react-native';
import { Text, TextInput, Button } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { authService } from '../../src/api';
import { COLORS, iOS, TYPOGRAPHY } from '../../src/theme/theme';

export default function ForgotPasswordScreen() {
  const router = useRouter();
  const [step, setStep] = useState(1);
  const [phoneOrEmail, setPhoneOrEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSendOtp = async () => {
    setIsLoading(true);
    setError('');
    try {
      await authService.forgotPassword(phoneOrEmail);
      setStep(2);
    } catch (e) {
      setError(e.response?.data?.message || 'Failed to send OTP');
    }
    setIsLoading(false);
  };

  const handleVerifyOtp = async () => {
    setIsLoading(true);
    setError('');
    try {
      await authService.verifyOtp(phoneOrEmail, otp);
      setStep(3);
    } catch (e) {
      setError(e.response?.data?.message || 'Invalid OTP');
    }
    setIsLoading(false);
  };

  const handleResetPassword = async () => {
    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }
    setIsLoading(true);
    setError('');
    try {
      await authService.resetPassword(phoneOrEmail, otp, password, confirmPassword);
      router.replace('/(auth)/login');
    } catch (e) {
      setError(e.response?.data?.message || 'Failed to reset password');
    }
    setIsLoading(false);
  };

  const getStepTitle = () => {
    switch (step) {
      case 1: return 'Reset Password';
      case 2: return 'Verify OTP';
      case 3: return 'New Password';
      default: return 'Reset Password';
    }
  };

  const getStepSubtitle = () => {
    switch (step) {
      case 1: return 'Enter your email address to receive OTP';
      case 2: return 'Enter the OTP sent to your email';
      case 3: return 'Create a new password for your account';
      default: return '';
    }
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
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <Ionicons name="chevron-back" size={24} color={COLORS.primary} />
          </TouchableOpacity>
        </View>

        {/* Title Section */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>{getStepTitle()}</Text>
          <Text style={styles.subtitle}>{getStepSubtitle()}</Text>
        </View>

        {/* Progress Indicator */}
        <View style={styles.progressContainer}>
          {[1, 2, 3].map((s) => (
            <View key={s} style={styles.progressStep}>
              <View style={[styles.progressDot, s <= step && styles.progressDotActive]}>
                {s < step ? (
                  <Ionicons name="checkmark" size={14} color={COLORS.white} />
                ) : (
                  <Text style={[styles.progressDotText, s <= step && styles.progressDotTextActive]}>
                    {s}
                  </Text>
                )}
              </View>
              {s < 3 && <View style={[styles.progressLine, s < step && styles.progressLineActive]} />}
            </View>
          ))}
        </View>

        {/* Form */}
        <View style={styles.formSection}>
          {step === 1 && (
            <>
              <TextInput
                label="Email Address"
                value={phoneOrEmail}
                onChangeText={setPhoneOrEmail}
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
              <Button
                mode="contained"
                onPress={handleSendOtp}
                loading={isLoading}
                disabled={isLoading || !phoneOrEmail.trim()}
                style={styles.button}
                contentStyle={styles.buttonContent}
                labelStyle={styles.buttonLabel}
                buttonColor={COLORS.primary}
              >
                Send OTP
              </Button>
            </>
          )}

          {step === 2 && (
            <>
              <TextInput
                label="Enter OTP"
                value={otp}
                onChangeText={setOtp}
                mode="outlined"
                keyboardType="numeric"
                maxLength={6}
                left={<TextInput.Icon icon={() => <Ionicons name="key-outline" size={20} color={COLORS.primary} />} />}
                style={styles.input}
                outlineStyle={styles.inputOutline}
                theme={{ colors: { primary: COLORS.primary } }}
                dense
              />
              <Button
                mode="contained"
                onPress={handleVerifyOtp}
                loading={isLoading}
                disabled={isLoading || !otp.trim()}
                style={styles.button}
                contentStyle={styles.buttonContent}
                labelStyle={styles.buttonLabel}
                buttonColor={COLORS.primary}
              >
                Verify OTP
              </Button>
            </>
          )}

          {step === 3 && (
            <>
              <TextInput
                label="New Password"
                value={password}
                onChangeText={setPassword}
                mode="outlined"
                secureTextEntry
                left={<TextInput.Icon icon={() => <Ionicons name="lock-closed-outline" size={20} color={COLORS.primary} />} />}
                style={styles.input}
                outlineStyle={styles.inputOutline}
                theme={{ colors: { primary: COLORS.primary } }}
                dense
              />
              <TextInput
                label="Confirm Password"
                value={confirmPassword}
                onChangeText={setConfirmPassword}
                mode="outlined"
                secureTextEntry
                left={<TextInput.Icon icon={() => <Ionicons name="lock-closed-outline" size={20} color={COLORS.primary} />} />}
                style={styles.input}
                outlineStyle={styles.inputOutline}
                theme={{ colors: { primary: COLORS.primary } }}
                dense
              />
              <Button
                mode="contained"
                onPress={handleResetPassword}
                loading={isLoading}
                disabled={isLoading || !password.trim() || !confirmPassword.trim()}
                style={styles.button}
                contentStyle={styles.buttonContent}
                labelStyle={styles.buttonLabel}
                buttonColor={COLORS.primary}
              >
                Reset Password
              </Button>
            </>
          )}

          {error ? (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={16} color={COLORS.error} />
              <Text style={styles.errorText}>{error}</Text>
            </View>
          ) : null}
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
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingTop: iOS.spacing.xxl,
    paddingBottom: iOS.spacing.xxxxxl,
  },
  header: {
    marginBottom: iOS.spacing.lg,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.base,
    backgroundColor: COLORS.surface,
    justifyContent: 'center',
    alignItems: 'center',
    ...iOS.shadowSmall,
  },
  titleSection: {
    marginBottom: iOS.spacing.xxl,
  },
  title: {
    fontSize: TYPOGRAPHY.fontSize.huge,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.textPrimary,
    marginBottom: iOS.spacing.sm,
  },
  subtitle: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    lineHeight: TYPOGRAPHY.lineHeight.relaxed,
  },
  progressContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: iOS.spacing.xxxxl,
    paddingHorizontal: iOS.spacing.xl,
  },
  progressStep: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  progressDot: {
    width: 32,
    height: 32,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.separatorLight,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: COLORS.separatorLight,
  },
  progressDotActive: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  progressDotText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.textSecondary,
  },
  progressDotTextActive: {
    color: COLORS.white,
  },
  progressLine: {
    flex: 1,
    height: 2,
    backgroundColor: COLORS.separatorLight,
    marginHorizontal: iOS.spacing.sm,
  },
  progressLineActive: {
    backgroundColor: COLORS.primary,
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
  button: {
    marginTop: iOS.spacing.md,
    borderRadius: iOS.borderRadius.lg,
    height: iOS.height.button,
    ...iOS.shadowMedium,
  },
  buttonContent: {
    height: iOS.height.button,
  },
  buttonLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.sm,
    paddingHorizontal: iOS.spacing.sm,
    paddingVertical: iOS.spacing.sm,
    backgroundColor: COLORS.errorLight,
    borderRadius: iOS.borderRadius.md,
  },
  errorText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.error,
    flex: 1,
  },
});