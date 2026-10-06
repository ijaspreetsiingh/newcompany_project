# nest. Customer Service Booking App

## Goal
Build a polished, mobile-first home-services booking experience covering the supplied customer journey. Use realistic demo content and working local interactions so every screen can be reviewed without a live API.

## What will be built
- A location-first launch flow with splash, sign-in/up, verification, password reset, language, location, and saved addresses.
- Five-tab app shell: Home, Services, Bookings, Cart, and Account.
- Complete discovery flow: search, filters, categories, offers, providers, favorites, service details, gallery, reviews, and booking configuration.
- Complete booking flow: cart, coupon, address, schedule, payment, success, booking list/details, and status tracking.
- Account and support flows: profile, settings, inbox/chat, notifications, custom posts, wallet, loyalty, referrals, service areas, support, and policy pages.
- Dedicated empty, loading, offline, unavailable-area, update, and login-required states.

## Visual direction
- Exact monochrome `nest.` language: white canvas, ink-black actions, fine grey borders, soft grey icon wells, no gradients or decorative color.
- Manrope display typography and DM Sans body typography.
- Compact 16px cards, pill controls, restrained motion, large tap targets, and a persistent five-item bottom navigation.
- Realistic Indian service pricing, addresses, providers, bookings, offers, and review content.

## Interaction model
- All important controls will work in the preview: tab navigation, back navigation, search, category selection, filters, favorites, quantity, cart, scheduling, checkout, settings, dialogs, sheets, and screen-to-screen actions.
- App data remains demo data for now; API calls, accounts, maps, payments, and persistence are not connected.

## Technical details
- Keep the experience on the existing TanStack Start home route as an app-like prototype.
- Use semantic theme tokens in the global design system and reusable React components for screen patterns.
- Use iconography from the existing icon library and locally authored mock data/state.
- Add complete route metadata and verify the mobile preview, interactions, and current build status.
