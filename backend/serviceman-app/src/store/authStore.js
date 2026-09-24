import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { authService, profileService } from '../api';

export const useAuthStore = create((set, get) => ({
  token: null,
  user: null,
  isLoading: false,
  isLoggedIn: false,
  error: null,

  init: async () => {
    try {
      const token = await AsyncStorage.getItem('auth_token');
      const userData = await AsyncStorage.getItem('user_data');
      if (token && userData) {
        set({
          token,
          user: JSON.parse(userData),
          isLoggedIn: true,
        });
      }
    } catch (e) {
      console.log('Auth init error:', e);
    }
  },

  login: async (email, password) => {
    set({ isLoading: true, error: null });
    try {
      console.log('[LOGIN] Sending:', { email, password: '***' });
      const response = await authService.login(email, password);

      console.log('[LOGIN] Response status:', response.status);
      console.log('[LOGIN] Response data:', JSON.stringify(response.data).substring(0, 500));

      const content = response.data?.content;
      const token = content?.token;
      const responseCode = response.data?.response_code;

      console.log('[LOGIN] Response code:', responseCode);
      console.log('[LOGIN] Token found:', !!token);

      if (token) {
        await AsyncStorage.setItem('auth_token', token);

        try {
          const profileRes = await profileService.getProfile();
          console.log('[LOGIN] Profile status:', profileRes.status);
          const userData = profileRes.data?.content;
          await AsyncStorage.setItem('user_data', JSON.stringify(userData));

          set({
            token,
            user: userData,
            isLoggedIn: true,
            isLoading: false,
          });
          return { success: true };
        } catch (profileError) {
          console.log('[LOGIN] Profile fetch error:', profileError.message);
          // Still login even if profile fails
          set({
            token,
            user: content,
            isLoggedIn: true,
            isLoading: false,
          });
          return { success: true };
        }
      }

      const msg = response.data?.message || 'Login failed - no token received';
      console.log('[LOGIN] No token. Message:', msg);
      set({ isLoading: false, error: msg });
      return { success: false, message: msg };

    } catch (error) {
      console.log('[LOGIN] Error status:', error.response?.status);
      console.log('[LOGIN] Error data:', JSON.stringify(error.response?.data || error.message || 'unknown'));
      console.log('[LOGIN] Full error:', JSON.stringify(Object.keys(error)));

      let message = 'Login failed';

      if (error.response?.status === 503) {
        message = error.response?.data?.message || 'System not activated. Contact admin.';
      } else if (error.response?.status === 404) {
        message = 'Email not found. Check your email.';
      } else if (error.response?.status === 401) {
        message = error.response?.data?.message || 'Wrong password. Try again.';
      } else if (error.response?.status === 403) {
        message = error.response?.data?.message || 'Validation error. Check fields.';
      } else if (error.response?.status === 422) {
        message = error.response?.data?.message || 'Validation error.';
      } else if (error.code === 'ECONNREFUSED' || error.code === 'ERR_NETWORK') {
        message = 'Cannot connect to server. Check BASE_URL and server status.';
      } else if (error.message) {
        message = error.message;
      }

      set({ isLoading: false, error: message });
      return { success: false, message };
    }
  },

  logout: async () => {
    try {
      await authService.logout();
    } catch (e) {}
    await AsyncStorage.removeItem('auth_token');
    await AsyncStorage.removeItem('user_data');
    set({ token: null, user: null, isLoggedIn: false });
  },

  updateProfile: async (data) => {
    set({ isLoading: true });
    try {
      const response = await profileService.updateProfile(data);
      if (response.data.response_code === 'default_update_200') {
        const profileRes = await profileService.getProfile();
        const userData = profileRes.data.content;
        await AsyncStorage.setItem('user_data', JSON.stringify(userData));
        set({ user: userData, isLoading: false });
        return { success: true };
      }
      set({ isLoading: false });
      return { success: false };
    } catch (error) {
      set({ isLoading: false });
      return { success: false };
    }
  },

  clearError: () => set({ error: null }),
}));
