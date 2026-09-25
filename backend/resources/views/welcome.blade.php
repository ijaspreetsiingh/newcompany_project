@extends('layouts.landing.app')

@section('title', 'Jass Booking - On-Demand Home Services')

@section('content')

    {{-- ==================== HERO ==================== --}}
    <section class="banner-section lv-hero">
        <div class="container">
            <div class="lv-hero-grid">
                <div class="lv-reveal">
                    <span class="lv-hero-badge">
                        <span class="lv-dot"></span>
                        #1 Home Services Platform
                    </span>
                    <h1>
                        Your home deserves<br>
                        the <span class="grad-text">best care</span>.
                    </h1>
                    <p class="lv-lead">
                        Book trusted, background-verified professionals for cleaning, repairs,
                        plumbing, electrical work and 50+ home services — fast, reliable and
                        at honest prices.
                    </p>
                    <div class="lv-hero-cta">
                        <a href="#service" class="lv-btn lv-btn-primary">
                            Book a Service <i class="las la-arrow-right"></i>
                        </a>
                        <a href="#how-it-works" class="lv-btn lv-btn-ghost">
                            <i class="las la-play-circle"></i> How It Works
                        </a>
                    </div>
                    <div class="lv-trust">
                        <div class="lv-avatars">
                            <span class="lv-av">AK</span>
                            <span class="lv-av lv-av--2">RS</span>
                            <span class="lv-av lv-av--3">PM</span>
                            <span class="lv-av lv-av--4">VD</span>
                        </div>
                        <div>
                            <div class="stars">★★★★★</div>
                            <b>4.9 average rating</b>
                            <small>Trusted by 50,000+ happy customers</small>
                        </div>
                    </div>
                </div>

                <div class="lv-reveal" style="--d: .15s">
                    <div class="lv-collage">
                        <div class="lv-tile"><img src="{{ $topImageData['top_image_1'] }}" alt="Home service professional"></div>
                        <div class="lv-tile"><img src="{{ $topImageData['top_image_2'] }}" alt="Home cleaning service"></div>
                        <div class="lv-tile"><img src="{{ $topImageData['top_image_3'] }}" alt="Repair service"></div>
                        <div class="lv-tile"><img src="{{ $topImageData['top_image_4'] }}" alt="Trusted experts"></div>

                        <div class="lv-float lv-float--verified">
                            <span class="ico"><i class="las la-shield-alt"></i></span>
                            <span>
                                <b>100% Verified</b>
                                <small>Background-checked pros</small>
                            </span>
                        </div>
                        <div class="lv-float lv-float--time">
                            <span class="ico"><i class="las la-bolt"></i></span>
                            <span>
                                <b>30 Min</b>
                                <small>Average arrival</small>
                            </span>
                        </div>
                        <div class="lv-float lv-float--rating">
                            <span class="ico"><i class="las la-star"></i></span>
                            <span>
                                <b>4.9 Rated</b>
                                <small>Top rated app</small>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== CATEGORIES ==================== --}}
    <section id="service" class="lv-section lv-section--alt service-section">
        <div class="container">
            <div class="lv-head lv-reveal">
                <span class="lv-eyebrow">Our Services</span>
                <h2 class="lv-title">Popular services, <span class="grad-text">on demand</span></h2>
                <p class="lv-sub">From everyday cleaning to emergency repairs — explore professional categories trusted by thousands of homes.</p>
            </div>

            <div class="lv-cat-grid">
                @forelse ($categories->take(6) as $category)
                    <a href="javascript:void(0)" class="lv-cat lv-reveal" style="--d: {{ $loop->index * 0.07 }}s">
                        <span class="lv-cat-ico">
                            <img src="{{ $category->image_full_path }}" alt="{{ $category['name'] }}">
                        </span>
                        <h3>{{ $category['name'] }}</h3>
                        <p>Available in {{ $category->zones_count }} zones &middot; {{ $category->children->count() }}+ subcategories</p>
                        <span class="more">
                            Explore
                            <span class="arr"><i class="las la-arrow-right"></i></span>
                        </span>
                    </a>
                @empty
                    <div class="lv-empty">Services are being updated — please check back soon.</div>
                @endforelse
            </div>
        </div>
    </section>

    {{-- ==================== HOW IT WORKS ==================== --}}
    <section id="how-it-works" class="lv-section">
        <div class="container">
            <div class="lv-head lv-reveal">
                <span class="lv-eyebrow lv-eyebrow--mint">How It Works</span>
                <h2 class="lv-title">Book in <span class="grad-text">3 easy steps</span></h2>
                <p class="lv-sub">Getting your home services done has never been this simple.</p>
            </div>

            <div class="lv-steps">
                <div class="lv-step lv-reveal">
                    <div class="lv-step-num">
                        <i class="las la-search"></i>
                        <span class="step-no">1</span>
                    </div>
                    <h3>Choose a Service</h3>
                    <p>Browse 50+ professional categories and pick exactly what your home needs.</p>
                </div>
                <div class="lv-step lv-reveal" style="--d: .12s">
                    <div class="lv-step-num lv-step-num--mint">
                        <i class="las la-calendar-check"></i>
                        <span class="step-no">2</span>
                    </div>
                    <h3>Book &amp; Schedule</h3>
                    <p>Pick a date and time that fits your routine — slots available 7 days a week.</p>
                </div>
                <div class="lv-step lv-reveal" style="--d: .24s">
                    <div class="lv-step-num lv-step-num--amber">
                        <i class="las la-tools"></i>
                        <span class="step-no">3</span>
                    </div>
                    <h3>Get It Done</h3>
                    <p>Sit back and relax while a verified pro arrives and gets the job done.</p>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== WHY CHOOSE US ==================== --}}
    <section class="lv-why">
        <div class="container">
            <div class="lv-why-grid">
                <div class="lv-why-media lv-reveal">
                    <div class="frame"></div>
                    <div class="shot">
                        <img src="{{ $topImageData['top_image_1'] }}" alt="Why choose us">
                    </div>
                    <div class="lv-float lv-float--trophy">
                        <span class="ico"><i class="las la-trophy"></i></span>
                        <span>
                            <b>#1 Rated</b>
                            <small>Home service app</small>
                        </span>
                    </div>
                </div>

                <div class="lv-reveal" style="--d: .15s">
                    <span class="lv-eyebrow lv-eyebrow--dark">Why Choose Us</span>
                    <h2 class="lv-title">The best home service<br>provider you can <span class="grad-text">trust</span></h2>
                    <p class="lv-lead">
                        With 10,000+ verified professionals across the city, we deliver
                        exceptional services right to your doorstep — skilled, background
                        verified and ready to serve.
                    </p>

                    <div class="lv-check-grid">
                        <div class="lv-check">
                            <span class="ico ico--mint"><i class="las la-shield-alt"></i></span>
                            <span>
                                <b>Verified Pros</b>
                                <small>Background checked</small>
                            </span>
                        </div>
                        <div class="lv-check">
                            <span class="ico ico--blue"><i class="las la-headset"></i></span>
                            <span>
                                <b>24/7 Support</b>
                                <small>We're always here</small>
                            </span>
                        </div>
                        <div class="lv-check">
                            <span class="ico ico--amber"><i class="las la-bolt"></i></span>
                            <span>
                                <b>Quick Response</b>
                                <small>30 min average arrival</small>
                            </span>
                        </div>
                        <div class="lv-check">
                            <span class="ico ico--rose"><i class="las la-hand-holding-usd"></i></span>
                            <span>
                                <b>Best Prices</b>
                                <small>No hidden charges</small>
                            </span>
                        </div>
                    </div>

                    <a href="{{ route('business.page.dynamic', ['slug' => 'about-us']) }}" class="lv-btn lv-btn-primary">
                        Learn More <i class="las la-arrow-right"></i>
                    </a>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== FEATURES (dynamic) ==================== --}}
    @if ($features->isNotEmpty())
        <section class="lv-section lv-section--alt">
            <div class="container">
                <div class="lv-head lv-reveal">
                    <span class="lv-eyebrow">Platform Highlights</span>
                    <h2 class="lv-title">Built for a <span class="grad-text">better experience</span></h2>
                </div>
                <div class="lv-feat-grid">
                    @foreach ($features as $feature)
                        <div class="lv-feat lv-reveal" style="--d: {{ $loop->index * 0.1 }}s">
                            <div class="thumb">
                                <img src="{{ $feature->image_1_full_path }}" alt="{{ $feature->title }}">
                            </div>
                            <div class="body">
                                <h3>{{ $feature->title }}</h3>
                                <p>{{ $feature->sub_title }}</p>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        </section>
    @endif

    {{-- ==================== SPECIALITIES (dynamic) ==================== --}}
    @if ($specialities->isNotEmpty())
        <section class="lv-section">
            <div class="container">
                <div class="lv-head lv-reveal">
                    <span class="lv-eyebrow lv-eyebrow--amber">Our Specialities</span>
                    <h2 class="lv-title">What makes us <span class="grad-text">different</span></h2>
                </div>
                <div class="lv-spec-grid">
                    @foreach ($specialities as $speciality)
                        <div class="lv-spec lv-reveal" style="--d: {{ $loop->index * 0.08 }}s">
                            <span class="pic">
                                <img src="{{ $speciality->image_full_path }}" alt="{{ $speciality->title }}">
                            </span>
                            <span>
                                <h3>{{ $speciality->title }}</h3>
                                <p>{{ $speciality->description }}</p>
                            </span>
                        </div>
                    @endforeach
                </div>
            </div>
        </section>
    @endif

    {{-- ==================== STATS ==================== --}}
    <section class="lv-stats">
        <div class="container">
            <div class="lv-stats-grid">
                <div class="lv-stat lv-reveal">
                    <div class="num" data-target="10000" data-suffix="+">0</div>
                    <div class="lbl">Verified Professionals</div>
                </div>
                <div class="lv-stat lv-reveal" style="--d: .08s">
                    <div class="num" data-target="50000" data-suffix="+">0</div>
                    <div class="lbl">Happy Customers</div>
                </div>
                <div class="lv-stat lv-reveal" style="--d: .16s">
                    <div class="num" data-target="50" data-suffix="+">0</div>
                    <div class="lbl">Service Categories</div>
                </div>
                <div class="lv-stat lv-reveal" style="--d: .24s">
                    <div class="num" data-target="4.9" data-decimals="1" data-suffix="★">0</div>
                    <div class="lbl">App Store Rating</div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== PROVIDER CTA ==================== --}}
    <section class="lv-cta">
        <div class="container">
            <div class="lv-cta-grid">
                <div class="lv-cta-visual lv-reveal">
                    <div class="lv-cta-card">
                        <i class="las la-user-tie"></i>
                    </div>
                    <div class="lv-float lv-float--earn">
                        <span class="ico"><i class="las la-users"></i></span>
                        <span>
                            <b>10K+ Partners</b>
                            <small>Already growing with us</small>
                        </span>
                    </div>
                </div>

                <div class="lv-reveal" style="--d: .15s">
                    <span class="lv-eyebrow lv-eyebrow--mint">Become a Provider</span>
                    <h2 class="lv-title">Grow your business <span class="grad-text">with us</span></h2>
                    <p class="lv-lead">
                        Join thousands of service providers earning more by listing their
                        services on our platform — and get access to thousands of customers
                        in your area.
                    </p>
                    <div class="lv-ticks">
                        <span class="lv-tick"><i class="las la-check"></i> Free registration</span>
                        <span class="lv-tick"><i class="las la-check"></i> Weekly payouts</span>
                        <span class="lv-tick"><i class="las la-check"></i> Marketing support</span>
                    </div>
                    <div class="lv-cta-btns">
                        <a href="{{ route('provider.auth.sign-up') }}" class="lv-btn lv-btn-mint">
                            Register Now <i class="las la-arrow-right"></i>
                        </a>
                        <a href="tel:{{ bs_data($settings, 'business_phone', 1) }}" class="lv-btn lv-btn-ghost">
                            <i class="las la-phone"></i> Call Us
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== APP DOWNLOAD ==================== --}}
    <section class="lv-section lv-section--alt">
        <div class="container">
            <div class="lv-app-grid">
                <div class="lv-app-copy lv-reveal">
                    <span class="lv-eyebrow">Download App</span>
                    <h2 class="lv-title">Book services <span class="grad-text">instantly</span> from your phone</h2>
                    <p class="lv-sub" style="margin: 0">
                        Enjoy seamless booking, real-time tracking, secure payments and
                        instant notifications — all from the app.
                    </p>

                    <div class="lv-store-btns">
                        @if ($settings->where('key_name', 'app_url_appstore')->first()->is_active ?? 0)
                            <a href="{{ bs_data($settings, 'app_url_appstore', 1) }}" class="lv-store">
                                <i class="lab la-apple"></i>
                                <span>
                                    <small>Download on the</small>
                                    <b>App Store</b>
                                </span>
                            </a>
                        @endif
                        @if ($settings->where('key_name', 'app_url_playstore')->first()->is_active ?? 0)
                            <a href="{{ bs_data($settings, 'app_url_playstore', 1) }}" class="lv-store">
                                <i class="lab la-google-play"></i>
                                <span>
                                    <small>GET IT ON</small>
                                    <b>Google Play</b>
                                </span>
                            </a>
                        @endif
                    </div>

                    <div class="lv-rating-row">
                        <span class="stars">★★★★★</span>
                        4.9/5 rating &middot; 10K+ downloads
                    </div>
                </div>

                <div class="lv-reveal" style="--d: .15s">
                    <div class="lv-phone-wrap">
                        <div class="lv-phone">
                            <span class="lv-phone-notch"></span>
                            <div class="lv-phone-screen">
                                <div class="lv-ph-head">
                                    <div class="hi">Welcome back</div>
                                    <div class="find">Find services near you</div>
                                    <div class="lv-ph-search">
                                        <i class="las la-search"></i>
                                        Search cleaning, repair...
                                    </div>
                                </div>
                                <div class="lv-ph-body">
                                    <div class="lv-ph-label">Top Categories</div>
                                    <div class="lv-ph-grid">
                                        <div class="lv-ph-tile">
                                            <span class="ic"><i class="las la-spray-can"></i></span>
                                            <span>Cleaning</span>
                                        </div>
                                        <div class="lv-ph-tile">
                                            <span class="ic"><i class="las la-faucet"></i></span>
                                            <span>Plumbing</span>
                                        </div>
                                        <div class="lv-ph-tile">
                                            <span class="ic"><i class="las la-bolt"></i></span>
                                            <span>Electric</span>
                                        </div>
                                        <div class="lv-ph-tile">
                                            <span class="ic"><i class="las la-paint-roller"></i></span>
                                            <span>Painter</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="lv-ph-promo">
                                    <i class="las la-tags"></i>
                                    <span>
                                        <b>FLAT 20% OFF</b>
                                        <small>On your first booking</small>
                                    </span>
                                </div>
                                <div class="lv-ph-nav">
                                    <i class="las la-home on"></i>
                                    <i class="las la-search"></i>
                                    <i class="las la-receipt"></i>
                                    <i class="las la-user"></i>
                                </div>
                            </div>
                        </div>

                        <div class="lv-float lv-phone-float">
                            <span class="ico"><i class="las la-bolt"></i></span>
                            <span>
                                <b>Live Tracking</b>
                                <small>Follow your pro in real time</small>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {{-- ==================== TESTIMONIALS ==================== --}}
    @if ($testimonials->isNotEmpty())
        <section class="lv-section">
            <div class="container">
                <div class="lv-quotes-head lv-reveal">
                    <div class="lv-head">
                        <span class="lv-eyebrow lv-eyebrow--amber">Testimonials</span>
                        <h2 class="lv-title">What our <span class="grad-text">customers say</span></h2>
                        <p class="lv-sub">Real reviews from real customers who love our services.</p>
                    </div>
                    <div class="lv-qnav">
                        <span class="slider-counter">1 / {{ $testimonials->count() }}</span>
                        <button type="button" class="testimonial-owl-prev" aria-label="Previous">
                            <i class="las la-angle-left"></i>
                        </button>
                        <button type="button" class="testimonial-owl-next" aria-label="Next">
                            <i class="las la-angle-right"></i>
                        </button>
                    </div>
                </div>

                <div class="testimonial-slider swiper lv-reveal" style="--d: .1s">
                    <div class="swiper-wrapper">
                        @foreach ($testimonials->take(6) as $testimonial)
                            <div class="swiper-slide">
                                <div class="testimonial__item lv-quote">
                                    <span class="qmark">&ldquo;</span>
                                    <span class="stars">★★★★★</span>
                                    <p>{{ $testimonial['review'] }}</p>
                                    <div class="who">
                                        <img src="{{ $testimonial['image_full_path'] }}" alt="{{ $testimonial['name'] }}">
                                        <span>
                                            <b>{{ $testimonial['name'] }}</b>
                                            <small>{{ $testimonial['designation'] }}</small>
                                        </span>
                                        <span class="verified"><i class="las la-check"></i></span>
                                    </div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </section>
    @endif

    <button type="button" class="lv-top" id="lvTop" aria-label="Back to top">
        <i class="las la-arrow-up"></i>
    </button>

    <script>
        (function () {
            var revealEls = document.querySelectorAll('.lv-reveal');
            if ('IntersectionObserver' in window) {
                var io = new IntersectionObserver(function (entries) {
                    entries.forEach(function (entry) {
                        if (entry.isIntersecting) {
                            entry.target.classList.add('is-in');
                            io.unobserve(entry.target);
                        }
                    });
                }, { threshold: 0.12 });
                revealEls.forEach(function (el) { io.observe(el); });
            } else {
                revealEls.forEach(function (el) { el.classList.add('is-in'); });
            }

            function animateCount(el) {
                var target = parseFloat(el.getAttribute('data-target')) || 0;
                var decimals = parseInt(el.getAttribute('data-decimals') || '0', 10);
                var suffix = el.getAttribute('data-suffix') || '';
                var duration = 1500;
                var start = null;

                function frame(now) {
                    if (!start) start = now;
                    var p = Math.min((now - start) / duration, 1);
                    var ease = 1 - Math.pow(1 - p, 3);
                    var value = target * ease;
                    el.textContent = (decimals
                        ? value.toFixed(decimals)
                        : Math.round(value).toLocaleString('en-US')) + suffix;
                    if (p < 1) requestAnimationFrame(frame);
                }
                requestAnimationFrame(frame);
            }

            var nums = document.querySelectorAll('.lv-stat .num[data-target]');
            if ('IntersectionObserver' in window) {
                var cio = new IntersectionObserver(function (entries) {
                    entries.forEach(function (entry) {
                        if (entry.isIntersecting) {
                            animateCount(entry.target);
                            cio.unobserve(entry.target);
                        }
                    });
                }, { threshold: 0.5 });
                nums.forEach(function (el) { cio.observe(el); });
            } else {
                nums.forEach(animateCount);
            }

            var topBtn = document.getElementById('lvTop');
            if (topBtn) {
                window.addEventListener('scroll', function () {
                    topBtn.classList.toggle('show', window.scrollY > 550);
                }, { passive: true });
                topBtn.addEventListener('click', function () {
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                });
            }
        })();
    </script>

@endsection
