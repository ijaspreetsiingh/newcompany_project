@extends('paymentmodule::layouts.master')

@section('content')
    <style>
        .cf-wrap {
            display: flex;
            min-height: 100vh;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            gap: 1rem;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        .cf-card {
            max-width: 420px;
            width: calc(100% - 2rem);
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 28px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(15, 23, 42, .08);
        }

        .cf-btn {
            background: #ff7529;
            color: #fff;
            border: 0;
            border-radius: 8px;
            padding: 13px 26px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            margin-top: 18px;
        }

        .cf-cancel {
            display: inline-block;
            margin-top: 14px;
            color: #6b7280;
            font-size: 13px;
            text-decoration: underline;
            cursor: pointer;
        }
    </style>

    <div class="cf-wrap">
        <div class="cf-card">
            <h2>{{ $businessName }}</h2>
            <p>{{ $data->currency_code }} {{ number_format((float) $data->payment_amount, 2) }}</p>
            <button type="button" class="cf-btn" id="cf-pay">Pay with Cashfree</button>
            <a class="cf-cancel" href="{{ $cancelUrl }}">Cancel payment</a>
        </div>
    </div>
@endsection

@push('script')
    <script src="https://sdk.cashfree.com/js/v3/cashfree.js"></script>
    <script>
        (function () {
            var sessionId = @json($paymentSessionId);
            var mode = @json($checkoutMode);
            var cancelUrl = @json($cancelUrl);
            var cashfree = null;

            function openCheckout() {
                try {
                    cashfree = cashfree || Cashfree({ mode: mode });
                    cashfree.checkout({
                        paymentSessionId: sessionId,
                        redirectTarget: "_self"
                    });
                } catch (error) {
                    console.error("Cashfree checkout failed", error);
                    window.location.href = cancelUrl;
                }
            }

            document.getElementById('cf-pay').addEventListener('click', openCheckout);
        })();
    </script>
@endpush
