export type BookingStatus =
  | "pending"
  | "accepted"
  | "ongoing"
  | "completed"
  | "canceled";

export type Booking = {
  id: string;
  code: string;
  customer: string;
  service: string;
  category: string;
  date: string;
  time: string;
  amount: number;
  status: BookingStatus;
  type: "regular" | "repeat";
  address: string;
  phone: string;
  serviceman?: string;
  payment: "Cash after service" | "Paid online" | "Wallet";
  items: { name: string; qty: number; price: number }[];
};

export const provider = {
  business: "Sharma Home Services",
  owner: "Jaspreet Singh",
  city: "Sector 22, Chandigarh",
  rating: 4.86,
  reviews: 412,
  plan: "Growth Plan",
  planDaysLeft: 18,
  trialEndsIn: 3,
};

export const topCards = [
  { label: "Today's bookings", value: "14", delta: "+3 vs yesterday" },
  { label: "Active now", value: "05", delta: "2 ongoing" },
  { label: "Completed", value: "236", delta: "this month" },
  { label: "Cancelled", value: "07", delta: "3% rate" },
];

export const earnings = {
  total: 184600,
  series: [
    { label: "Mon", current: 8200, previous: 6400 },
    { label: "Tue", current: 10400, previous: 9100 },
    { label: "Wed", current: 7600, previous: 8300 },
    { label: "Thu", current: 13200, previous: 9800 },
    { label: "Fri", current: 15800, previous: 12400 },
    { label: "Sat", current: 21400, previous: 17600 },
    { label: "Sun", current: 12600, previous: 11200 },
  ],
};

export const activityDonut = [
  { name: "Normal", value: 68 },
  { name: "Customized", value: 32 },
];

export const accountDonut = [
  { name: "Accepted", value: 24 },
  { name: "Ongoing", value: 12 },
  { name: "Completed", value: 58 },
  { name: "Cancelled", value: 6 },
];

export const bookings: Booking[] = [
  {
    id: "1",
    code: "#BK-10482",
    customer: "Ananya Mehta",
    service: "Deep Home Cleaning",
    category: "Cleaning",
    date: "29 Sep 2026",
    time: "10:30 AM",
    amount: 2499,
    status: "pending",
    type: "regular",
    address: "House 214, Sector 35-B, Chandigarh",
    phone: "+91 98765 43210",
    payment: "Cash after service",
    items: [
      { name: "Full home deep clean (2BHK)", qty: 1, price: 1999 },
      { name: "Sofa shampoo", qty: 1, price: 500 },
    ],
  },
  {
    id: "2",
    code: "#BK-10479",
    customer: "Rahul Verma",
    service: "AC Service & Gas Refill",
    category: "Appliance",
    date: "29 Sep 2026",
    time: "01:00 PM",
    amount: 1899,
    status: "ongoing",
    type: "regular",
    address: "Flat 8C, Omaxe Heights, Mohali",
    phone: "+91 90123 55512",
    serviceman: "Imran Khan",
    payment: "Paid online",
    items: [{ name: "Split AC service + gas", qty: 1, price: 1899 }],
  },
  {
    id: "3",
    code: "#BK-10471",
    customer: "Priya Nair",
    service: "Salon at Home — Classic",
    category: "Beauty",
    date: "28 Sep 2026",
    time: "05:00 PM",
    amount: 1250,
    status: "completed",
    type: "repeat",
    address: "Villa 12, Sunny Enclave, Kharar",
    phone: "+91 99887 21100",
    serviceman: "Neha Sharma",
    payment: "Wallet",
    items: [
      { name: "Waxing (full arms + legs)", qty: 1, price: 850 },
      { name: "Threading", qty: 2, price: 200 },
    ],
  },
  {
    id: "4",
    code: "#BK-10465",
    customer: "Devendra Soni",
    service: "Electrician Visit",
    category: "Repairs",
    date: "28 Sep 2026",
    time: "11:15 AM",
    amount: 499,
    status: "accepted",
    type: "regular",
    address: "SCO 44, Phase 7, Mohali",
    phone: "+91 88991 44556",
    serviceman: "Ravi Kumar",
    payment: "Cash after service",
    items: [{ name: "Switchboard repair", qty: 1, price: 499 }],
  },
  {
    id: "5",
    code: "#BK-10460",
    customer: "Simran Kaur",
    service: "Weekly Kitchen Cleaning",
    category: "Cleaning",
    date: "27 Sep 2026",
    time: "09:00 AM",
    amount: 799,
    status: "canceled",
    type: "repeat",
    address: "Tower B-1104, Wave Estate",
    phone: "+91 70098 12345",
    payment: "Paid online",
    items: [{ name: "Kitchen deep clean", qty: 1, price: 799 }],
  },
  {
    id: "6",
    code: "#BK-10455",
    customer: "Mohit Bansal",
    service: "Pest Control — Full Home",
    category: "Pest Control",
    date: "27 Sep 2026",
    time: "03:30 PM",
    amount: 2299,
    status: "completed",
    type: "regular",
    address: "Kothi 77, Sector 11, Panchkula",
    phone: "+91 96543 78123",
    serviceman: "Imran Khan",
    payment: "Cash after service",
    items: [{ name: "Cockroach + termite treatment", qty: 1, price: 2299 }],
  },
];

export const statusLabel: Record<BookingStatus, string> = {
  pending: "Pending",
  accepted: "Accepted",
  ongoing: "Ongoing",
  completed: "Completed",
  canceled: "Canceled",
};

export const categories = [
  { name: "Cleaning", subs: 6, services: 24, subscribed: true },
  { name: "Appliance Repair", subs: 5, services: 18, subscribed: true },
  { name: "Beauty & Salon", subs: 4, services: 22, subscribed: true },
  { name: "Plumbing", subs: 3, services: 11, subscribed: false },
  { name: "Electrician", subs: 3, services: 14, subscribed: true },
  { name: "Pest Control", subs: 2, services: 8, subscribed: false },
  { name: "Painting", subs: 4, services: 16, subscribed: false },
  { name: "Car Care", subs: 3, services: 9, subscribed: true },
];

export const servicesByCategory: Record<
  string,
  { name: string; price: number; time: string; active: boolean; rating: number }[]
> = {
  Cleaning: [
    { name: "Deep home cleaning (2BHK)", price: 1999, time: "4 hrs", active: true, rating: 4.9 },
    { name: "Bathroom cleaning", price: 499, time: "60 min", active: true, rating: 4.7 },
    { name: "Sofa shampoo (3 seater)", price: 849, time: "90 min", active: true, rating: 4.8 },
    { name: "Kitchen deep clean", price: 799, time: "2 hrs", active: false, rating: 4.6 },
  ],
  "Appliance Repair": [
    { name: "Split AC service", price: 599, time: "60 min", active: true, rating: 4.8 },
    { name: "AC gas refill", price: 1899, time: "90 min", active: true, rating: 4.7 },
    { name: "Washing machine repair", price: 449, time: "45 min", active: true, rating: 4.5 },
  ],
  "Beauty & Salon": [
    { name: "Salon at home — classic", price: 1250, time: "90 min", active: true, rating: 4.9 },
    { name: "Hair spa", price: 899, time: "60 min", active: true, rating: 4.8 },
    { name: "Bridal makeup", price: 6999, time: "3 hrs", active: false, rating: 5 },
  ],
  Electrician: [
    { name: "Switchboard repair", price: 499, time: "45 min", active: true, rating: 4.6 },
    { name: "Fan installation", price: 349, time: "30 min", active: true, rating: 4.7 },
  ],
  "Car Care": [
    { name: "Car wash at home", price: 699, time: "60 min", active: true, rating: 4.7 },
    { name: "Interior detailing", price: 2499, time: "3 hrs", active: true, rating: 4.8 },
  ],
};

export const servicemen = [
  { id: "1", name: "Imran Khan", role: "Senior technician", jobs: 148, rating: 4.9, status: "On duty", zone: "Mohali" },
  { id: "2", name: "Neha Sharma", role: "Beautician", jobs: 96, rating: 4.8, status: "On a job", zone: "Chandigarh" },
  { id: "3", name: "Ravi Kumar", role: "Electrician", jobs: 211, rating: 4.7, status: "Off duty", zone: "Panchkula" },
  { id: "4", name: "Sunita Devi", role: "Cleaning expert", jobs: 64, rating: 4.9, status: "On duty", zone: "Kharar" },
];

export const bids = [
  {
    id: "1",
    title: "Full flat painting — 3BHK",
    customer: "Karan Ahuja",
    distance: "2.4 km",
    budget: "₹18,000 – ₹25,000",
    posted: "12 min ago",
    offers: 4,
    note: "Need 2 coats, Asian Paints, work within next weekend.",
  },
  {
    id: "2",
    title: "Office deep cleaning (monthly)",
    customer: "Nexlab Pvt Ltd",
    distance: "5.1 km",
    budget: "₹8,000 / month",
    posted: "1 hr ago",
    offers: 7,
    note: "1800 sqft office, cleaning after 8 PM on weekdays.",
  },
  {
    id: "3",
    title: "Sofa + carpet shampoo",
    customer: "Meera Joshi",
    distance: "800 m",
    budget: "₹2,000 – ₹3,500",
    posted: "3 hrs ago",
    offers: 2,
    note: "5 seater sofa and one 6x8 carpet, this Saturday.",
  },
];

export const chats = [
  { id: "1", name: "Ananya Mehta", type: "Customer", last: "Bhaiya 10:30 tak aa jaoge?", time: "2m", unread: 2 },
  { id: "2", name: "Imran Khan", type: "Serviceman", last: "AC ka gas lag gaya, bill bhej diya", time: "18m", unread: 0 },
  { id: "3", name: "Rahul Verma", type: "Customer", last: "Payment done ✅", time: "1h", unread: 0 },
  { id: "4", name: "Neha Sharma", type: "Serviceman", last: "Kal ki booking confirm hai?", time: "3h", unread: 1 },
];

export const messages = [
  { from: "them", text: "Hello! Kal ki cleaning booking ka time confirm kar dein?", time: "09:12" },
  { from: "me", text: "Ji bilkul, subah 10:30 AM slot confirm hai.", time: "09:14" },
  { from: "them", text: "Team kitne log aayenge?", time: "09:15" },
  { from: "me", text: "2 experts aayenge, machine aur material saath layenge.", time: "09:16" },
  { from: "them", text: "Perfect, thank you 🙏", time: "09:17" },
];

export const notifications = [
  { title: "New booking request", body: "Ananya Mehta — Deep Home Cleaning", time: "2 min ago", unseen: true },
  { title: "Payment received", body: "₹1,899 credited for #BK-10479", time: "40 min ago", unseen: true },
  { title: "Review received", body: "Priya Nair rated you 5 stars", time: "2 hrs ago", unseen: false },
  { title: "Plan reminder", body: "Growth Plan expires in 18 days", time: "Yesterday", unseen: false },
];

export const transactions = [
  { id: "TXN-8841", label: "Booking payout", date: "28 Sep", amount: 1899, type: "credit" },
  { id: "TXN-8832", label: "Withdraw to HDFC ****4421", date: "26 Sep", amount: 25000, type: "debit" },
  { id: "TXN-8820", label: "Booking payout", date: "25 Sep", amount: 2299, type: "credit" },
  { id: "TXN-8811", label: "Subscription — Growth Plan", date: "22 Sep", amount: 1499, type: "debit" },
  { id: "TXN-8802", label: "Booking payout", date: "21 Sep", amount: 1250, type: "credit" },
];

export const plans = [
  {
    name: "Starter",
    price: 499,
    period: "month",
    current: false,
    features: ["Up to 30 bookings", "2 servicemen", "Basic reports", "Email support"],
  },
  {
    name: "Growth",
    price: 1499,
    period: "month",
    current: true,
    features: ["Unlimited bookings", "10 servicemen", "Bidding / custom posts", "Advertisements", "Priority support"],
  },
  {
    name: "Enterprise",
    price: 3999,
    period: "month",
    current: false,
    features: ["Everything in Growth", "Unlimited servicemen", "Multi-zone operations", "Dedicated manager"],
  },
];

export const reviews = [
  { name: "Priya Nair", stars: 5, text: "Neha did an amazing job, very professional and on time.", date: "28 Sep", service: "Salon at Home" },
  { name: "Mohit Bansal", stars: 4, text: "Good pest control service, slight delay in arrival.", date: "27 Sep", service: "Pest Control" },
  { name: "Rahul Verma", stars: 5, text: "AC cooling like new. Highly recommended.", date: "26 Sep", service: "AC Service" },
];

export const moreMenu = [
  { label: "Profile", to: "/profile", group: "Business" },
  { label: "Business Plan", to: "/plan", group: "Business" },
  { label: "Account Information", to: "/account", group: "Business" },
  { label: "Reports", to: "/reports", group: "Business" },
  { label: "Chat", to: "/chat", group: "Operations" },
  { label: "Servicemen", to: "/servicemen", group: "Operations" },
  { label: "Reviews", to: "/reviews", group: "Operations" },
  { label: "Advertisements", to: "/ads", group: "Operations" },
  { label: "Withdraw List", to: "/withdraw", group: "Money" },
  { label: "Payment Information", to: "/payment-info", group: "Money" },
  { label: "Notification Channel", to: "/notification-settings", group: "Settings" },
  { label: "Settings", to: "/settings", group: "Settings" },
  { label: "Help & Support", to: "/help", group: "Settings" },
  { label: "About Us", to: "/page/about", group: "Legal" },
  { label: "Terms & Conditions", to: "/page/terms", group: "Legal" },
  { label: "Privacy Policy", to: "/page/privacy", group: "Legal" },
  { label: "Cancellation Policy", to: "/page/cancellation", group: "Legal" },
  { label: "Refund Policy", to: "/page/refund", group: "Legal" },
] as const;
