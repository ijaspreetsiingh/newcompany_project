import { create } from 'zustand';
import { bookingService, dashboardService } from '../api';

export const useBookingStore = create((set, get) => ({
  bookings: [],
  bookingDetail: null,
  dashboardData: null,
  isLoading: false,
  isRefreshing: false,
  currentFilter: 'all',
  totalCount: 0,
  page: 1,

  setFilter: (filter) => {
    set({ currentFilter: filter, bookings: [], page: 1 });
    get().fetchBookings(true);
  },

  fetchBookings: async (refresh = false) => {
    const { currentFilter, page } = get();
    set({ isLoading: !refresh, isRefreshing: refresh });
    try {
      const response = await bookingService.getBookingList(20, refresh ? 1 : page, currentFilter);
      const data = response.data.content;
      set({
        bookings: refresh ? data.data : [...get().bookings, ...data.data],
        totalCount: data.total ?? data.data.length,
        isLoading: false,
        isRefreshing: false,
        page: refresh ? 2 : page + 1,
      });
    } catch (error) {
      set({ isLoading: false, isRefreshing: false });
    }
  },

  fetchBookingDetail: async (id) => {
    set({ isLoading: true, bookingDetail: null });
    try {
      const response = await bookingService.getBookingDetail(id);
      set({ bookingDetail: response.data.content, isLoading: false });
      return response.data.content;
    } catch (error) {
      set({ isLoading: false });
      return null;
    }
  },

  updateStatus: async (bookingId, status, otp = null, evidencePhotos = []) => {
    set({ isLoading: true });
    try {
      const response = await bookingService.updateBookingStatus(bookingId, status, otp, evidencePhotos);
      if (response.data.response_code?.includes('200')) {
        await get().fetchBookingDetail(bookingId);
        set({ isLoading: false });
        return { success: true };
      }
      set({ isLoading: false });
      return { success: false, message: response.data.message };
    } catch (error) {
      set({ isLoading: false });
      return { success: false, message: error.response?.data?.message || 'Update failed' };
    }
  },

  updatePaymentStatus: async (bookingId, paymentStatus) => {
    try {
      const response = await bookingService.updatePaymentStatus(bookingId, paymentStatus);
      if (response.data.response_code?.includes('200')) {
        await get().fetchBookingDetail(bookingId);
        return { success: true };
      }
      return { success: false };
    } catch (error) {
      return { success: false };
    }
  },

  fetchDashboard: async () => {
    set({ isLoading: true });
    try {
      const response = await dashboardService.getDashboard('top_cards,recent_bookings,booking_stats');
      set({ dashboardData: response.data.content, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
    }
  },

  reset: () => set({
    bookings: [],
    bookingDetail: null,
    dashboardData: null,
    currentFilter: 'all',
    page: 1,
  }),
}));
