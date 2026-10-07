@extends('layouts.landing.app')

@section('title', 'Jass Booking - On-Demand Home Services')

@section('content')

    {{-- ==================== HERO SECTION ==================== --}}
    <section class="banner-section" style="background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0f172a 100%); min-height: 100vh; display: flex; align-items: center; position: relative; overflow: hidden;">
        <div style="position: absolute; top: -50%; right: -20%; width: 600px; height: 600px; background: radial-gradient(circle, rgba(59,130,246,0.15) 0%, transparent 70%); border-radius: 50%;"></div>
        <div style="position: absolute; bottom: -30%; left: -10%; width: 500px; height: 500px; background: radial-gradient(circle, rgba(16,185,129,0.1) 0%, transparent 70%); border-radius: 50%;"></div>
        <div class="container" style="position: relative; z-index: 2;">
            <div class="row align-items-center g-5">
                <div class="col-lg-6 wow animate__fadeInUp">
                    <div style="display: inline-block; background: rgba(59,130,246,0.15); border: 1px solid rgba(59,130,246,0.3); border-radius: 50px; padding: 8px 20px; margin-bottom: 24px;">
                        <span style="color: #60a5fa; font-size: 14px; font-weight: 600; letter-spacing: 1px;">🏠 #1 HOME SERVICES PLATFORM</span>
                    </div>
                    <h1 style="color: #fff; font-size: 56px; font-weight: 800; line-height: 1.15; margin-bottom: 20px;">
                        Your Home, <br>
                        <span style="background: linear-gradient(135deg, #3b82f6, #10b981); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">Our Priority</span>
                    </h1>
                    <p style="color: #94a3b8; font-size: 18px; line-height: 1.7; margin-bottom: 32px; max-width: 480px;">
                        Book trusted professionals for cleaning, repairs, plumbing, electrical work and 50+ home services. Fast, reliable, and affordable.
                    </p>
                    <div class="d-flex flex-wrap gap-3 mb-4">
                        <a href="#service" style="background: linear-gradient(135deg, #3b82f6, #2563eb); color: #fff; padding: 16px 36px; border-radius: 12px; font-weight: 700; font-size: 16px; text-decoration: none; display: inline-flex; align-items: center; gap: 10px; box-shadow: 0 8px 25px rgba(59,130,246,0.4); transition: all 0.3s;">
                            Book Now <i class="las la-arrow-right"></i>
                        </a>
                        <a href="#how-it-works" style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: #fff; padding: 16px 36px; border-radius: 12px; font-weight: 700; font-size: 16px; text-decoration: none; display: inline-flex; align-items: center; gap: 10px; transition: all 0.3s;">
                            <i class="las la-play-circle" style="font-size: 20px;"></i> How It Works
                        </a>
                    </div>
                    <div class="d-flex align-items-center gap-4 mt-4">
                        <div class="d-flex">
                            @for($i = 0; $i < 4; $i++)
                                <div style="width: 40px; height: 40px; border-radius: 50%; border: 2px solid #1e3a5f; margin-left: -10px; background: linear-gradient(135deg, #3b82f6, #10b981); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: 700; font-size: 14px;">{{ chr(65 + $i) }}</div>
                            @endfor
                        </div>
                        <div>
                            <div style="color: #fbbf24; font-size: 14px;">★★★★★</div>
                            <span style="color: #94a3b8; font-size: 13px;">50,000+ Happy Customers</span>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 wow animate__fadeInUp" style="animation-delay: 0.2s;">
                    <div style="position: relative;">
                        <div style="width: 100%; height: 400px; border-radius: 24px; box-shadow: 0 25px 60px rgba(0,0,0,0.4); background: linear-gradient(135deg, #1e3a5f, #3b82f6); display: flex; align-items: center; justify-content: center;"><i class="las la-home" style="color: rgba(255,255,255,0.3); font-size: 120px;"></i></div>
                        <div style="position: absolute; bottom: -20px; left: -20px; background: #fff; border-radius: 16px; padding: 16px 24px; box-shadow: 0 10px 40px rgba(0,0,0,0.15); display: flex; align-items: center; gap: 12px;">
                            <div style="width: 48px; height: 48px; background: linear-gradient(135deg, #10b981, #059669); border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                                <i class="las la-check" style="color: #fff; font-size: 24px;"></i>
                            </div>
                            <div>
                                <div style="font-weight: 700; color: #1e293b; font-size: 16px;">100% Verified</div>
                                <div style="color: #64748b; font-size: 13px;">Professional Workers</div>
                            </div>
                        </div>
                        <div style="position: absolute; top: 20px; right: -10px; background: linear-gradient(135deg, #f59e0b, #d97706); border-radius: 16px; padding: 14px 20px; box-shadow: 0 10px 30px rgba(245,158,11,0.3); display: flex; align-items: center; gap: 10px;">
                            <i class="las la-bolt" style="color: #fff; font-size: 22px;"></i>
                            <div>
                                <div style="font-weight: 800; color: #fff; font-size: 18px;">30 Min</div>
                                <div style="color: rgba(255,255,255,0.8); font-size: 12px;">Average Arrival</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== SERVICES SECTION ==================== --}}
    <section id="service" class="py-5" style="background: #f8fafc;">
        <div class="container">
            <div class="text-center mb-5 wow animate__fadeInUp">
                <span style="background: rgba(59,130,246,0.1); color: #3b82f6; padding: 8px 20px; border-radius: 50px; font-weight: 600; font-size: 14px; display: inline-block; margin-bottom: 16px;">OUR SERVICES</span>
                <h2 style="font-size: 40px; font-weight: 800; color: #1e293b; margin-bottom: 16px;">Explore Popular Services</h2>
                <p style="color: #64748b; font-size: 17px; max-width: 600px; margin: 0 auto;">Find the right service for your home from our wide range of professional categories</p>
            </div>
            <div class="row g-4">
                @foreach ($categories->take(6) as $index => $category)
                    <div class="col-md-6 col-lg-4 wow animate__fadeInUp" style="animation-delay: {{ $index * 0.1 }}s;">
                        <div style="background: #fff; border-radius: 20px; padding: 32px; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid #f1f5f9; transition: all 0.3s; cursor: pointer; height: 100%;" onmouseover="this.style.transform='translateY(-8px)'; this.style.boxShadow='0 20px 40px rgba(0,0,0,0.12)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 20px rgba(0,0,0,0.06)'">
                            <div style="width: 64px; height: 64px; background: linear-gradient(135deg, rgba(59,130,246,0.1), rgba(16,185,129,0.1)); border-radius: 16px; display: flex; align-items: center; justify-content: center; margin-bottom: 20px;">
                                <img src="{{ $category->image_full_path }}" alt="{{ $category['name'] }}" style="width: 36px; height: 36px; object-fit: contain;">
                            </div>
                            <h5 style="font-weight: 700; color: #1e293b; margin-bottom: 8px; font-size: 18px;">{{ $category['name'] }}</h5>
                            <p style="color: #64748b; font-size: 14px; line-height: 1.6; margin-bottom: 16px;">
                                Available in {{ $category->zones_count }} zones • {{ $category->children->count() }}+ subcategories
                            </p>
                            <a href="javascript:void(0)" style="color: #3b82f6; font-weight: 600; font-size: 14px; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                                Explore <i class="las la-arrow-right" style="font-size: 14px;"></i>
                            </a>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </section>

    {{-- ==================== HOW IT WORKS ==================== --}}
    <section id="how-it-works" class="py-5" style="background: #fff;">
        <div class="container">
            <div class="text-center mb-5 wow animate__fadeInUp">
                <span style="background: rgba(16,185,129,0.1); color: #10b981; padding: 8px 20px; border-radius: 50px; font-weight: 600; font-size: 14px; display: inline-block; margin-bottom: 16px;">HOW IT WORKS</span>
                <h2 style="font-size: 40px; font-weight: 800; color: #1e293b; margin-bottom: 16px;">Book in 3 Easy Steps</h2>
                <p style="color: #64748b; font-size: 17px; max-width: 500px; margin: 0 auto;">Getting your home services has never been easier</p>
            </div>
            <div class="row g-4 align-items-center">
                <div class="col-md-4 text-center wow animate__fadeInUp">
                    <div style="position: relative; display: inline-block; margin-bottom: 24px;">
                        <div style="width: 100px; height: 100px; background: linear-gradient(135deg, #3b82f6, #2563eb); border-radius: 24px; display: flex; align-items: center; justify-content: center; box-shadow: 0 15px 35px rgba(59,130,246,0.3);">
                            <i class="las la-search" style="color: #fff; font-size: 40px;"></i>
                        </div>
                        <div style="position: absolute; top: -10px; right: -10px; width: 32px; height: 32px; background: #fbbf24; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; color: #1e293b; font-size: 14px;">1</div>
                    </div>
                    <h5 style="font-weight: 700; color: #1e293b; margin-bottom: 8px;">Choose Service</h5>
                    <p style="color: #64748b; font-size: 15px;">Browse through 50+ categories and select the service you need</p>
                </div>
                <div class="col-md-4 text-center wow animate__fadeInUp" style="animation-delay: 0.15s;">
                    <div style="position: relative; display: inline-block; margin-bottom: 24px;">
                        <div style="width: 100px; height: 100px; background: linear-gradient(135deg, #10b981, #059669); border-radius: 24px; display: flex; align-items: center; justify-content: center; box-shadow: 0 15px 35px rgba(16,185,129,0.3);">
                            <i class="las la-calendar-check" style="color: #fff; font-size: 40px;"></i>
                        </div>
                        <div style="position: absolute; top: -10px; right: -10px; width: 32px; height: 32px; background: #fbbf24; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; color: #1e293b; font-size: 14px;">2</div>
                    </div>
                    <h5 style="font-weight: 700; color: #1e293b; margin-bottom: 8px;">Book Appointment</h5>
                    <p style="color: #64748b; font-size: 15px;">Pick a date and time that works best for your schedule</p>
                </div>
                <div class="col-md-4 text-center wow animate__fadeInUp" style="animation-delay: 0.3s;">
                    <div style="position: relative; display: inline-block; margin-bottom: 24px;">
                        <div style="width: 100px; height: 100px; background: linear-gradient(135deg, #f59e0b, #d97706); border-radius: 24px; display: flex; align-items: center; justify-content: center; box-shadow: 0 15px 35px rgba(245,158,11,0.3);">
                            <i class="las la-tools" style="color: #fff; font-size: 40px;"></i>
                        </div>
                        <div style="position: absolute; top: -10px; right: -10px; width: 32px; height: 32px; background: #fbbf24; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; color: #1e293b; font-size: 14px;">3</div>
                    </div>
                    <h5 style="font-weight: 700; color: #1e293b; margin-bottom: 8px;">Get It Done</h5>
                    <p style="color: #64748b; font-size: 15px;">Sit back and relax while our verified pro handles everything</p>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== ABOUT SECTION ==================== --}}
    <section class="py-5" style="background: linear-gradient(135deg, #0f172a, #1e3a5f); position: relative; overflow: hidden;">
        <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: linear-gradient(135deg, rgba(59,130,246,0.1), rgba(16,185,129,0.05)); opacity: 0.5;"></div>
        <div class="container" style="position: relative; z-index: 2;">
            <div class="row align-items-center g-5">
                <div class="col-lg-6 wow animate__fadeInUp">
                    <span style="background: rgba(59,130,246,0.2); color: #60a5fa; padding: 8px 20px; border-radius: 50px; font-weight: 600; font-size: 14px; display: inline-block; margin-bottom: 16px;">ABOUT US</span>
                    <h2 style="font-size: 40px; font-weight: 800; color: #fff; margin-bottom: 20px; line-height: 1.2;">We Are The Best Home Service Provider</h2>
                    <p style="color: #94a3b8; font-size: 17px; line-height: 1.8; margin-bottom: 32px;">
                        With over 10,000+ verified professionals, we deliver exceptional home services right to your doorstep. Our platform connects you with trusted experts who are Background verified, skilled, and ready to serve.
                    </p>
                    <div class="row g-3 mb-4">
                        <div class="col-6">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 44px; height: 44px; background: rgba(16,185,129,0.15); border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                    <i class="las la-shield-alt" style="color: #10b981; font-size: 20px;"></i>
                                </div>
                                <span style="color: #e2e8f0; font-weight: 600; font-size: 15px;">Verified Pros</span>
                            </div>
                        </div>
                        <div class="col-6">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 44px; height: 44px; background: rgba(59,130,246,0.15); border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                    <i class="las la-headset" style="color: #3b82f6; font-size: 20px;"></i>
                                </div>
                                <span style="color: #e2e8f0; font-weight: 600; font-size: 15px;">24/7 Support</span>
                            </div>
                        </div>
                        <div class="col-6">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 44px; height: 44px; background: rgba(245,158,11,0.15); border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                    <i class="las la-bolt" style="color: #f59e0b; font-size: 20px;"></i>
                                </div>
                                <span style="color: #e2e8f0; font-weight: 600; font-size: 15px;">Quick Response</span>
                            </div>
                        </div>
                        <div class="col-6">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div style="width: 44px; height: 44px; background: rgba(239,68,68,0.15); border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                    <i class="las la-hand-holding-usd" style="color: #ef4444; font-size: 20px;"></i>
                                </div>
                                <span style="color: #e2e8f0; font-weight: 600; font-size: 15px;">Best Prices</span>
                            </div>
                        </div>
                    </div>
                    <a href="{{ route('business.page.dynamic', ['slug' => 'about-us']) }}" style="background: linear-gradient(135deg, #3b82f6, #2563eb); color: #fff; padding: 14px 32px; border-radius: 12px; font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 8px 25px rgba(59,130,246,0.3);">
                        Learn More <i class="las la-arrow-right"></i>
                    </a>
                </div>
                <div class="col-lg-6 wow animate__fadeInUp" style="animation-delay: 0.2s;">
                    <div style="position: relative;">
                        <div style="width: 100%; height: 400px; border-radius: 24px; box-shadow: 0 25px 60px rgba(0,0,0,0.3); background: linear-gradient(135deg, #f59e0b, #d97706); display: flex; align-items: center; justify-content: center;"><i class="las la-trophy" style="color: rgba(255,255,255,0.3); font-size: 100px;"></i></div>
                        <div style="position: absolute; bottom: 30px; left: -30px; background: #fff; border-radius: 16px; padding: 20px 28px; box-shadow: 0 15px 40px rgba(0,0,0,0.15); display: flex; align-items: center; gap: 14px;">
                            <div style="width: 56px; height: 56px; background: linear-gradient(135deg, #fbbf24, #f59e0b); border-radius: 14px; display: flex; align-items: center; justify-content: center;">
                                <i class="las la-trophy" style="color: #fff; font-size: 28px;"></i>
                            </div>
                            <div>
                                <div style="font-weight: 800; color: #1e293b; font-size: 24px;">#1 Rated</div>
                                <div style="color: #64748b; font-size: 13px;">Home Service App</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== STATS SECTION ==================== --}}
    <section class="py-5" style="background: #fff;">
        <div class="container">
            <div class="row g-4 text-center">
                <div class="col-6 col-lg-3 wow animate__fadeInUp">
                    <div style="padding: 30px 20px;">
                        <div style="font-size: 48px; font-weight: 800; background: linear-gradient(135deg, #3b82f6, #2563eb); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">10K+</div>
                        <div style="color: #64748b; font-size: 16px; font-weight: 500; margin-top: 4px;">Verified Professionals</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 wow animate__fadeInUp" style="animation-delay: 0.1s;">
                    <div style="padding: 30px 20px;">
                        <div style="font-size: 48px; font-weight: 800; background: linear-gradient(135deg, #10b981, #059669); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">50K+</div>
                        <div style="color: #64748b; font-size: 16px; font-weight: 500; margin-top: 4px;">Happy Customers</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 wow animate__fadeInUp" style="animation-delay: 0.2s;">
                    <div style="padding: 30px 20px;">
                        <div style="font-size: 48px; font-weight: 800; background: linear-gradient(135deg, #f59e0b, #d97706); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">50+</div>
                        <div style="color: #64748b; font-size: 16px; font-weight: 500; margin-top: 4px;">Service Categories</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3 wow animate__fadeInUp" style="animation-delay: 0.3s;">
                    <div style="padding: 30px 20px;">
                        <div style="font-size: 48px; font-weight: 800; background: linear-gradient(135deg, #ef4444, #dc2626); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">4.9</div>
                        <div style="color: #64748b; font-size: 16px; font-weight: 500; margin-top: 4px;">App Store Rating ★</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== CTA / PROVIDER SECTION ==================== --}}
    <section class="py-5" style="background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0f172a 100%); position: relative; overflow: hidden;">
        <div style="position: absolute; top: -50%; right: -10%; width: 400px; height: 400px; background: radial-gradient(circle, rgba(16,185,129,0.12) 0%, transparent 70%); border-radius: 50%;"></div>
        <div class="container" style="position: relative; z-index: 2;">
            <div class="row align-items-center g-5">
                <div class="col-lg-6 wow animate__fadeInUp">
                    <div style="width: 100%; height: 350px; border-radius: 24px; box-shadow: 0 25px 60px rgba(0,0,0,0.3); background: linear-gradient(135deg, #10b981, #059669); display: flex; align-items: center; justify-content: center;"><i class="las la-user-tie" style="color: rgba(255,255,255,0.3); font-size: 100px;"></i></div>
                </div>
                <div class="col-lg-6 wow animate__fadeInUp" style="animation-delay: 0.15s;">
                    <span style="background: rgba(16,185,129,0.2); color: #34d399; padding: 8px 20px; border-radius: 50px; font-weight: 600; font-size: 14px; display: inline-block; margin-bottom: 16px;">BECOME A PROVIDER</span>
                    <h2 style="font-size: 40px; font-weight: 800; color: #fff; margin-bottom: 20px; line-height: 1.2;">Grow Your Business With Us</h2>
                    <p style="color: #94a3b8; font-size: 17px; line-height: 1.8; margin-bottom: 24px;">
                        Join thousands of service providers who are earning more by listing their services on our platform. Get access to thousands of customers in your area.
                    </p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="{{ route('provider.auth.sign-up') }}" style="background: linear-gradient(135deg, #10b981, #059669); color: #fff; padding: 16px 32px; border-radius: 12px; font-weight: 700; font-size: 16px; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 8px 25px rgba(16,185,129,0.4);">
                            Register Now <i class="las la-arrow-right"></i>
                        </a>
                        <a href="tel:{{ bs_data($settings, 'business_phone', 1) }}" style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: #fff; padding: 16px 32px; border-radius: 12px; font-weight: 700; font-size: 16px; text-decoration: none; display: inline-flex; align-items: center; gap: 8px;">
                            <i class="las la-phone"></i> Call Us
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== APP DOWNLOAD SECTION ==================== --}}
    <section class="py-5" style="background: #f8fafc;">
        <div class="container">
            <div class="row align-items-center g-5">
                <div class="col-lg-6 wow animate__fadeInUp">
                    <span style="background: rgba(59,130,246,0.1); color: #3b82f6; padding: 8px 20px; border-radius: 50px; font-weight: 600; font-size: 14px; display: inline-block; margin-bottom: 16px;">DOWNLOAD APP</span>
                    <h2 style="font-size: 40px; font-weight: 800; color: #1e293b; margin-bottom: 16px;">Get The App & Book Services Instantly</h2>
                    <p style="color: #64748b; font-size: 17px; line-height: 1.7; margin-bottom: 32px;">
                        Download our mobile app and enjoy seamless booking, real-time tracking, secure payments, and instant notifications - all from your phone.
                    </p>
                    <div class="d-flex flex-wrap gap-3 mb-4">
                        @if ($settings->where('key_name', 'app_url_appstore')->first()->is_active ?? 0)
                            <a href="{{ bs_data($settings, 'app_url_appstore', 1) }}" style="background: #000; color: #fff; padding: 14px 28px; border-radius: 12px; text-decoration: none; display: inline-flex; align-items: center; gap: 12px; transition: all 0.3s;">
                                <i class="lab la-apple" style="font-size: 32px;"></i>
                                <div>
                                    <div style="font-size: 11px; opacity: 0.8;">Download on the</div>
                                    <div style="font-size: 17px; font-weight: 700;">App Store</div>
                                </div>
                            </a>
                        @endif
                        @if ($settings->where('key_name', 'app_url_playstore')->first()->is_active ?? 0)
                            <a href="{{ bs_data($settings, 'app_url_playstore', 1) }}" style="background: #000; color: #fff; padding: 14px 28px; border-radius: 12px; text-decoration: none; display: inline-flex; align-items: center; gap: 12px; transition: all 0.3s;">
                                <i class="lab la-google-play" style="font-size: 28px;"></i>
                                <div>
                                    <div style="font-size: 11px; opacity: 0.8;">GET IT ON</div>
                                    <div style="font-size: 17px; font-weight: 700;">Google Play</div>
                                </div>
                            </a>
                        @endif
                    </div>
                    <div class="d-flex align-items-center gap-3">
                        <div style="color: #fbbf24; font-size: 20px;">★★★★★</div>
                        <span style="color: #64748b; font-size: 14px;">4.9/5 Rating • 10K+ Downloads</span>
                    </div>
                </div>
                <div class="col-lg-6 text-center wow animate__fadeInUp" style="animation-delay: 0.2s;">
                    <div style="max-width: 350px; width: 100%; height: 400px; border-radius: 30px; box-shadow: 0 30px 60px rgba(0,0,0,0.2); background: linear-gradient(135deg, #8b5cf6, #6366f1); display: flex; align-items: center; justify-content: center; margin: 0 auto;"><i class="las la-mobile-alt" style="color: rgba(255,255,255,0.3); font-size: 120px;"></i></div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== TESTIMONIALS ==================== --}}
    <section class="py-5" style="background: #fff;">
        <div class="container">
            <div class="text-center mb-5 wow animate__fadeInUp">
                <span style="background: rgba(245,158,11,0.1); color: #f59e0b; padding: 8px 20px; border-radius: 50px; font-weight: 600; font-size: 14px; display: inline-block; margin-bottom: 16px;">TESTIMONIALS</span>
                <h2 style="font-size: 40px; font-weight: 800; color: #1e293b; margin-bottom: 16px;">What Our Customers Say</h2>
                <p style="color: #64748b; font-size: 17px; max-width: 500px; margin: 0 auto;">Real reviews from real customers who love our services</p>
            </div>
            <div class="row g-4">
                @foreach ($testimonials->take(3) as $index => $testimonial)
                    <div class="col-md-6 col-lg-4 wow animate__fadeInUp" style="animation-delay: {{ $index * 0.1 }}s;">
                        <div style="background: #f8fafc; border-radius: 20px; padding: 32px; border: 1px solid #f1f5f9; height: 100%;">
                            <div style="color: #fbbf24; font-size: 18px; margin-bottom: 16px;">★★★★★</div>
                            <p style="color: #475569; font-size: 15px; line-height: 1.7; margin-bottom: 24px; font-style: italic;">
                                "{{ $testimonial['review'] }}"
                            </p>
                            <div style="display: flex; align-items: center; gap: 14px;">
                                <img src="{{ $testimonial['image_full_path'] }}" alt="{{ $testimonial['name'] }}" style="width: 48px; height: 48px; border-radius: 50%; object-fit: cover;">
                                <div>
                                    <div style="font-weight: 700; color: #1e293b; font-size: 15px;">{{ $testimonial['name'] }}</div>
                                    <div style="color: #64748b; font-size: 13px;">{{ $testimonial['designation'] }}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </section>

@endsection
