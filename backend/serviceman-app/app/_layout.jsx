import { useEffect } from 'react';
import { Slot, useRouter, useSegments } from 'expo-router';
import { PaperProvider } from 'react-native-paper';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { useAuthStore } from '../src/store/authStore';
import { theme } from '../src/theme/theme';

function RootLayoutNav() {
  const { isLoggedIn, init } = useAuthStore();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    init();
  }, []);

  useEffect(() => {
    const inAuthGroup = segments[0] === '(auth)';
    
    if (!isLoggedIn && !inAuthGroup) {
      router.replace('/(auth)/login');
    } else if (isLoggedIn && inAuthGroup) {
      router.replace('/(main)');
    }
  }, [isLoggedIn, segments]);

  return <Slot />;
}

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <PaperProvider theme={theme}>
        <RootLayoutNav />
        <StatusBar style="dark" backgroundColor="#F2F2F7" />
      </PaperProvider>
    </SafeAreaProvider>
  );
}
