import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { BASE_URL, API_ENDPOINTS } from '../utils/constants';

const api = axios.create({
  baseURL: BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

api.interceptors.request.use(
  async (config) => {
    const token = await AsyncStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      await AsyncStorage.removeItem('auth_token');
      await AsyncStorage.removeItem('user_data');
    }
    return Promise.reject(error);
  }
);

export const authService = {
  login: (email, password) =>
    api.post(API_ENDPOINTS.AUTH.LOGIN, { email, password }),

  logout: () => api.post(API_ENDPOINTS.AUTH.LOGOUT),

  forgotPassword: (phone_or_email) =>
    api.post(API_ENDPOINTS.AUTH.FORGOT_PASSWORD, { phone_or_email }),

  verifyOtp: (phone_or_email, otp) =>
    api.post(API_ENDPOINTS.AUTH.OTP_VERIFICATION, { phone_or_email, otp }),

  resetPassword: (phone_or_email, otp, password, confirm_password) =>
    api.put(API_ENDPOINTS.AUTH.RESET_PASSWORD, {
      phone_or_email, otp, password, confirm_password,
    }),
};

export const dashboardService = {
  getDashboard: (sections = 'top_cards,recent_bookings,booking_stats', year, month) => {
    const params = { sections };
    if (year) params.year = year;
    if (month) params.month = month;
    return api.get(API_ENDPOINTS.DASHBOARD.MAIN, { params });
  },

  getBookingStats: () => api.get(API_ENDPOINTS.DASHBOARD.STATS),
};

export const bookingService = {
  getBookingList: (limit = 20, offset = 1, status = 'all') =>
    api.get(API_ENDPOINTS.BOOKING.LIST, {
      params: { limit, offset, booking_status: status },
    }),

  getBookingDetail: (id) =>
    api.get(`${API_ENDPOINTS.BOOKING.DETAIL}/${id}`),

  updateBookingStatus: (bookingId, status, otp = null, evidencePhotos = []) => {
    const formData = new FormData();
    formData.append('booking_status', status);
    if (otp) formData.append('booking_otp', otp);
    evidencePhotos.forEach((photo, index) => {
      formData.append(`evidence_photos[${index}]`, {
        uri: photo.uri,
        type: 'image/jpeg',
        name: `evidence_${index}.jpg`,
      });
    });
    return api.put(
      `${API_ENDPOINTS.BOOKING.STATUS_UPDATE}/${bookingId}`,
      formData,
      { headers: { 'Content-Type': 'multipart/form-data' } }
    );
  },

  updatePaymentStatus: (bookingId, paymentStatus) =>
    api.put(`${API_ENDPOINTS.BOOKING.PAYMENT_STATUS}/${bookingId}`, {
      payment_status: paymentStatus,
    }),

  sendOtpNotification: (bookingId) =>
    api.get(API_ENDPOINTS.BOOKING.SEND_OTP, {
      params: { booking_id: bookingId },
    }),
};

export const profileService = {
  getProfile: () => api.get(API_ENDPOINTS.PROFILE.INFO),

  updateProfile: (data) => {
    const formData = new FormData();
    if (data.first_name) formData.append('first_name', data.first_name);
    if (data.last_name) formData.append('last_name', data.last_name);
    if (data.email) formData.append('email', data.email);
    if (data.password) formData.append('password', data.password);
    if (data.profile_image) {
      formData.append('profile_image', {
        uri: data.profile_image.uri,
        type: 'image/jpeg',
        name: 'profile.jpg',
      });
    }
    return api.put(API_ENDPOINTS.PROFILE.UPDATE, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },

  updateFcmToken: (fcm_token) =>
    api.put(API_ENDPOINTS.PROFILE.FCM_TOKEN, { fcm_token }),

  changePassword: (password, confirm_password) =>
    api.put(API_ENDPOINTS.PROFILE.CHANGE_PASSWORD, { password, confirm_password }),
};

export const configService = {
  getDistance: (originLat, originLng, destLat, destLng) =>
    api.get(API_ENDPOINTS.CONFIG.DISTANCE, {
      params: {
        origin_lat: originLat,
        origin_lng: originLng,
        destination_lat: destLat,
        destination_lng: destLng,
      },
    }),

  getRoutes: (originLat, originLng, destLat, destLng) =>
    api.get(API_ENDPOINTS.CONFIG.ROUTES, {
      params: {
        origin_latitude: originLat,
        origin_longitude: originLng,
        destination_latitude: destLat,
        destination_longitude: destLng,
      },
    }),

  geocode: (lat, lng) =>
    api.get(API_ENDPOINTS.CONFIG.GEOCODE, { params: { lat, lng } }),
};

export const chatService = {
  getChannels: (limit = 20, offset = 1) =>
    api.get(API_ENDPOINTS.CHAT.CHANNEL_LIST, { params: { limit, offset } }),

  createChannel: (to_user, reference_id, reference_type) =>
    api.post(API_ENDPOINTS.CHAT.CREATE_CHANNEL, {
      to_user, reference_id, reference_type,
    }),

  sendMessage: (channel_id, message, files = []) => {
    const formData = new FormData();
    formData.append('channel_id', channel_id);
    if (message) formData.append('message', message);
    files.forEach((file, index) => {
      formData.append(`files[${index}]`, {
        uri: file.uri,
        type: file.type || 'image/jpeg',
        name: file.name || `file_${index}.jpg`,
      });
    });
    return api.post(API_ENDPOINTS.CHAT.SEND_MESSAGE, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },

  getConversation: (channelId, limit = 50, offset = 1) =>
    api.get(API_ENDPOINTS.CHAT.CONVERSATION, {
      params: { channel_id: channelId, limit, offset },
    }),
};

export const notificationService = {
  getNotifications: (limit = 20, offset = 1) =>
    api.get(API_ENDPOINTS.NOTIFICATIONS.LIST, { params: { limit, offset } }),
};

export default api;
