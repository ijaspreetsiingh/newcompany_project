import { MD3LightTheme } from 'react-native-paper';

export const COLORS = {
  // Primary Colors (iOS Blue)
  primary: '#007AFF',
  primaryDark: '#0056CC',
  primaryLight: '#D6E8FF',
  primaryAlpha: 'rgba(0, 122, 255, 0.1)',
  
  // Status Colors
  success: '#34C759',
  successLight: '#E3F9EC',
  successAlpha: 'rgba(52, 199, 89, 0.1)',
  
  warning: '#FF9500',
  warningLight: '#FFF4E5',
  warningAlpha: 'rgba(255, 149, 0, 0.1)',
  
  error: '#FF3B30',
  errorLight: '#FFECEB',
  errorAlpha: 'rgba(255, 59, 48, 0.1)',
  
  info: '#5AC8FA',
  infoLight: '#E3F5FF',
  infoAlpha: 'rgba(90, 200, 250, 0.1)',
  
  purple: '#AF52DE',
  purpleLight: '#F5ECFB',
  purpleAlpha: 'rgba(175, 82, 222, 0.1)',

  // Background Colors
  background: '#F2F2F7',
  backgroundSecondary: '#FFFFFF',
  surface: '#FFFFFF',
  surfaceSecondary: '#F9F9FB',
  surfaceTertiary: '#F2F2F7',
  card: '#FFFFFF',
  
  // Border/Separator Colors
  separator: '#C6C6C8',
  separatorLight: '#E5E5EA',
  border: '#D1D1D6',
  
  // Text Colors
  text: '#000000',
  textPrimary: '#000000',
  textSecondary: '#8E8E93',
  textTertiary: '#AEAEB2',
  textQuaternary: '#C7C7CC',
  textInverse: '#FFFFFF',
  
  // Neutral Colors
  white: '#FFFFFF',
  black: '#000000',
  blackAlpha: 'rgba(0, 0, 0, 0.8)',
  grey: '#8E8E93',
  greyLight: '#C7C7CC',
  greyDark: '#636366',
  lightGrey: '#F2F2F7',
  
  // Navigation Colors
  tabBarBackground: '#F9F9FB',
  navBarBackground: '#F9F9FB',
  tabBarActive: '#007AFF',
  tabBarInactive: '#8E8E93',
  
  // Map Colors
  mapRoute: '#007AFF',
  mapRouteAlpha: 'rgba(0, 122, 255, 0.3)',
  mapMarker: '#FF3B30',
  mapMarkerAlpha: 'rgba(255, 59, 48, 0.3)',
  
  // Chat Colors
  chatBubbleMe: '#007AFF',
  chatBubbleOther: '#E5E5EA',
  chatBubbleMeText: '#FFFFFF',
  chatBubbleOtherText: '#000000',
};

export const TYPOGRAPHY = {
  // Font Sizes
  fontSize: {
    xs: 11,
    sm: 12,
    base: 14,
    md: 15,
    lg: 16,
    xl: 17,
    xxl: 20,
    xxxl: 24,
    huge: 28,
    massive: 32,
  },
  
  // Font Weights
  fontWeight: {
    regular: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
    heavy: '800',
  },
  
  // Line Heights
  lineHeight: {
    tight: 1.2,
    normal: 1.4,
    relaxed: 1.6,
  },
};

export const iOS = {
  // Shadows
  shadowSmall: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06,
    shadowRadius: 2,
    elevation: 1,
  },
  shadowMedium: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  shadowLarge: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.12,
    shadowRadius: 16,
    elevation: 6,
  },
  shadowXLarge: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.15,
    shadowRadius: 24,
    elevation: 8,
  },
  
  // Border Radius
  borderRadius: {
    xs: 6,
    sm: 8,
    md: 10,
    base: 12,
    lg: 14,
    xl: 16,
  xxl: 20,
  xxxl: 24,
  full: 9999,
  },
  
  // Spacing
  spacing: {
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 20,
    xxl: 24,
  xxxl: 32,
  xxxxl: 40,
  xxxxxl: 48,
  xxxxxxl: 64,
  },
  
  // Screen Padding
  screenPadding: {
    horizontal: 20,
    vertical: 16,
  },
  
  // Component Heights
  height: {
    input: 52,
    button: 52,
    tabBar: 88,
    navBar: 44,
    card: 80,
  },
  
  // Animation
  animation: {
    fast: 150,
    normal: 300,
    slow: 500,
  },
};

export const theme = {
  ...MD3LightTheme,
  colors: {
    ...MD3LightTheme.colors,
    primary: COLORS.primary,
    primaryContainer: COLORS.primaryLight,
    secondary: COLORS.warning,
    secondaryContainer: COLORS.warningLight,
    surface: COLORS.surface,
    surfaceVariant: COLORS.surfaceSecondary,
    background: COLORS.background,
    error: COLORS.error,
    onPrimary: COLORS.white,
    onSecondary: COLORS.white,
    onSurface: COLORS.textPrimary,
    onBackground: COLORS.textPrimary,
    outline: COLORS.separator,
    outlineVariant: COLORS.separatorLight,
    success: COLORS.success,
    warning: COLORS.warning,
    info: COLORS.info,
  },
  roundness: iOS.borderRadius.lg,
  fonts: {
    ...MD3LightTheme.fonts,
    regular: {
      fontFamily: 'System',
      fontWeight: '400',
    },
    medium: {
      fontFamily: 'System',
      fontWeight: '500',
    },
    light: {
      fontFamily: 'System',
      fontWeight: '300',
    },
  },
};
