import type React from 'react';
import { createContext, useContext, useState, type ReactNode } from 'react';

type Booking = { serviceId: string; date: string; slot: string; address: string; instructions: string; confirmed: boolean };
type BookingContextValue = { booking: Booking; update: (patch: Partial<Booking>) => void; reset: () => void };
const initial: Booking = { serviceId: 'home-cleaning', date: '', slot: '', address: '', instructions: '', confirmed: false };
// Keep one context instance across hot reloads so providers and consumers always match.
const g = globalThis as typeof globalThis & { __nestBookingContext?: React.Context<BookingContextValue | null> };
const Context = (g.__nestBookingContext ??= createContext<BookingContextValue | null>(null));
export function BookingProvider({ children }: { children: ReactNode }) {
  const [booking, setBooking] = useState<Booking>(initial);
  return <Context.Provider value={{ booking, update: patch => setBooking(current => ({ ...current, ...patch })), reset: () => setBooking(initial) }}>{children}</Context.Provider>;
}
export function useBooking() { const value = useContext(Context); if (!value) throw new Error('BookingProvider missing'); return value; }
