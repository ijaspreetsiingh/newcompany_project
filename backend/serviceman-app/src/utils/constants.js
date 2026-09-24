export { COLORS } from '../theme/theme';

export const BASE_URL = 'http://192.168.1.4:8000/api/v1';

export const API_ENDPOINTS = {
  AUTH: {
    LOGIN: '/serviceman/auth/login',
    LOGOUT: '/user/logout',
    FORGOT_PASSWORD: '/serviceman/forgot-password',
    OTP_VERIFICATION: '/serviceman/otp-verification',
    RESET_PASSWORD: '/serviceman/reset-password',
  },
  DASHBOARD: {
    MAIN: '/serviceman/dashboard',
    STATS: '/serviceman/dashboard/booking-statistics',
  },
  BOOKING: {
    LIST: '/serviceman/booking/list',
    DETAIL: '/serviceman/booking/detail',
    SINGLE_DETAIL: '/serviceman/booking/single/detail',
    STATUS_UPDATE: '/serviceman/booking/status-update',
    REPEAT_STATUS_UPDATE: '/serviceman/booking/single-repeat-status-update',
    PAYMENT_STATUS: '/serviceman/booking/payment-status-update',
    SEND_OTP: '/serviceman/booking/opt/notification-send',
  },
  PROFILE: {
    INFO: '/serviceman/info',
    UPDATE: '/serviceman/update/profile',
    FCM_TOKEN: '/serviceman/update/fcm-token',
    CHANGE_PASSWORD: '/serviceman/profile/change-password',
  },
  CONFIG: {
    BASE: '/serviceman/config',
    ZONE: '/serviceman/config/get-zone-id',
    DISTANCE: '/serviceman/config/distance-api',
    GEOCODE: '/serviceman/config/geocode-api',
    ROUTES: '/serviceman/config/get-routes',
    AUTOCOMPLETE: '/serviceman/config/place-api-autocomplete',
    PLACE_DETAILS: '/serviceman/config/place-api-details',
  },
  CHAT: {
    CHANNEL_LIST: '/serviceman/chat/channel-list',
    SEARCH_CHANNELS: '/serviceman/chat/channel-list-search',
    CREATE_CHANNEL: '/serviceman/chat/create-channel',
    SEND_MESSAGE: '/serviceman/chat/send-message',
    CONVERSATION: '/serviceman/chat/conversation',
  },
  NOTIFICATIONS: {
    LIST: '/serviceman/push-notifications',
  },
};

export const BOOKING_STATUS = {
  PENDING: 'pending',
  ACCEPTED: 'accepted',
  ONGOING: 'ongoing',
  COMPLETED: 'completed',
  CANCELED: 'canceled',
};
