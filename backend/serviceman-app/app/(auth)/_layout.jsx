import { Stack } from 'expo-router';
import { COLORS } from '../../src/theme/theme';

export default function AuthLayout() {
  return (
    <Stack 
      screenOptions={{
        headerShown: false,
        animation: 'slide_from_right',
        contentStyle: { backgroundColor: COLORS.background },
        presentation: 'card',
      }}
    >
      <Stack.Screen 
        name="login" 
        options={{ 
          gestureEnabled: false,
        }} 
      />
      <Stack.Screen 
        name="forgot-password" 
        options={{ 
          gestureEnabled: true,
        }} 
      />
    </Stack>
  );
}
