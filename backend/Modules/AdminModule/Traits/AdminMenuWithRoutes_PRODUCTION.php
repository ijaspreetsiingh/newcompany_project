<?php

namespace Modules\AdminModule\Traits;

trait AdminMenuWithRoutes
{
    /**
     * Production-ready admin menu
     * Cleaned up - only core functionality needed for booking system
     */
    public function adminMenuWithRoutes()
    {
        $result = [
            // ============ BOOKINGS ============
            [
                'route_name' => 'Booking_Requests',
                'uri' => 'admin/booking/list?booking_status=pending&service_type=all',
                'full_route' => url('admin/booking/list?booking_status=pending&service_type=all'),
                "page_title" => 'Booking_Requests',
                "keywords" => 'Bookings',
                "type" => 'menu',
                "module" => "bookings",
                "sorting" => 1,
            ],
            [
                'route_name' => 'Accepted',
                'uri' => 'admin/booking/list?booking_status=accepted&service_type=all',
                'full_route' => url('admin/booking/list?booking_status=accepted&service_type=all'),
                "page_title" => 'Accepted',
                "keywords" => 'Bookings',
                "type" => 'menu',
                "module" => "bookings",
                "sorting" => 2,
            ],
            [
                'route_name' => 'Ongoing',
                'uri' => 'admin/booking/list?booking_status=ongoing&service_type=all',
                'full_route' => url('admin/booking/list?booking_status=ongoing&service_type=all'),
                "page_title" => 'Ongoing',
                "keywords" => 'Ongoing, Bookings',
                "type" => 'menu',
                "module" => "bookings",
                "sorting" => 3,
            ],
            [
                'route_name' => 'Completed',
                'uri' => 'admin/booking/list?booking_status=completed&service_type=all',
                'full_route' => url('admin/booking/list?booking_status=completed&service_type=all'),
                "page_title" => 'Completed',
                "keywords" => 'Bookings',
                "type" => 'menu',
                "module" => "bookings",
                "sorting" => 4,
            ],
            [
                'route_name' => 'Canceled',
                'uri' => 'admin/booking/list?booking_status=canceled&service_type=all',
                'full_route' => url('admin/booking/list?booking_status=canceled&service_type=all'),
                "page_title" => 'Canceled',
                "keywords" => 'Bookings',
                "type" => 'menu',
                "module" => "bookings",
                "sorting" => 5,
            ],

            // ============ PROVIDERS ============
            [
                'route_name' => 'Provider_List',
                'uri' => 'admin/provider/list?status=all',
                'full_route' => url('admin/provider/list?status=all'),
                "page_title" => 'Provider_List',
                "keywords" => 'Provider List, Providers',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Add_New_Provider',
                'uri' => 'admin/provider/create',
                'full_route' => url('admin/provider/create'),
                "page_title" => 'Add_New_Provider',
                "keywords" => 'Add new provider, Providers',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Withdraw_Requests',
                'uri' => 'admin/withdraw/request/list?status=all',
                'full_route' => url('admin/withdraw/request/list?status=all'),
                "page_title" => 'Withdraw_Requests',
                "keywords" => 'Withdraw Requests, Withdraws',
                "type" => 'menu',
            ],

            // ============ SERVICES ============
            [
                'route_name' => 'service_list',
                'uri' => 'admin/service/list',
                'full_route' => url('admin/service/list'),
                "page_title" => 'service_list',
                "keywords" => 'Services',
                "type" => 'menu',
                "module" => "services",
                "sorting" => 1,
            ],
            [
                'route_name' => 'add_new_service',
                'uri' => 'admin/service/create',
                'full_route' => url('admin/service/create'),
                "page_title" => 'add_new_service',
                "keywords" => 'Services',
                "type" => 'menu',
                "module" => "services",
                "sorting" => 2,
            ],
            [
                'route_name' => 'New_Service_Requests',
                'uri' => 'admin/service/request/list',
                'full_route' => url('admin/service/request/list'),
                "page_title" => 'New_Service_Requests',
                "keywords" => 'Services',
                "type" => 'menu',
                "module" => "services",
                "sorting" => 3,
            ],
            [
                'route_name' => 'Provider_Services',
                'uri' => 'admin/service/provider-services',
                'full_route' => url('admin/service/provider-services'),
                "page_title" => 'Provider_Services',
                "keywords" => 'Services',
                "type" => 'menu',
                "module" => "services",
                "sorting" => 4,
            ],

            // ============ SETUP ============
            [
                'route_name' => 'Service_Zones_Setup',
                'uri' => 'admin/zone/create',
                'full_route' => url('admin/zone/create'),
                "page_title" => 'Service_Zones_Setup',
                "keywords" => 'Service Zones Setup',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Category_Setup',
                'uri' => 'admin/category/create',
                'full_route' => url('admin/category/create'),
                "page_title" => 'Category_Setup',
                "keywords" => 'Category Setup, Categories',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Sub_Category_Setup',
                'uri' => 'admin/sub-category/create',
                'full_route' => url('admin/sub-category/create'),
                "page_title" => 'Sub_Category_Setup',
                "keywords" => 'Sub Category Setup, Categories',
                "type" => 'menu',
            ],

            // ============ CUSTOMERS ============
            [
                'route_name' => 'customer_list',
                'uri' => 'admin/customer/list',
                'full_route' => url('admin/customer/list'),
                "page_title" => 'customer_list',
                'keywords' => 'Customers',
                "type" => 'menu',
            ],
            [
                'route_name' => 'add_new_customer',
                'uri' => 'admin/customer/create',
                'full_route' => url('admin/customer/create'),
                "page_title" => 'add_new_customer',
                "keywords" => 'Customers',
                "type" => 'menu',
            ],

            // ============ REPORTS ============
            [
                'route_name' => 'Transaction_Reports',
                'uri' => 'admin/report/transaction?transaction_type=all',
                'full_route' => url('admin/report/transaction?transaction_type=all'),
                "page_title" => 'Transaction Reports',
                "keywords" => 'Reports',
                "type" => 'menu',
                "module" => "reports",
                "sorting" => 1,
            ],
            [
                'route_name' => 'Business_Reports',
                'uri' => 'admin/report/business/overview',
                'full_route' => url('admin/report/business/overview'),
                "page_title" => 'Business_Reports',
                "keywords" => 'Reports',
                "type" => 'menu',
                "module" => "reports",
                "sorting" => 2,
            ],
            [
                'route_name' => 'Booking_Reports',
                'uri' => 'admin/report/booking',
                'full_route' => url('admin/report/booking'),
                "page_title" => 'Booking_Reports',
                "keywords" => 'Reports',
                "type" => 'menu',
                "module" => "reports",
                "sorting" => 3,
            ],
            [
                'route_name' => 'Provider_Reports',
                'uri' => 'admin/report/provider',
                'full_route' => url('admin/report/provider'),
                "page_title" => 'Provider_Reports',
                "keywords" => 'Reports',
                "type" => 'menu',
                "module" => "reports",
                "sorting" => 4,
            ],

            // ============ SETTINGS ============
            [
                'route_name' => 'Business_settings',
                'uri' => 'admin/business-settings/get-business-information',
                'full_route' => url('admin/business-settings/get-business-information'),
                "page_title" => 'Business_settings',
                "keywords" => 'Business Settings, Settings management',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Notification_Channel',
                'uri' => 'admin/business-settings/notification-channel?notification_type=user',
                'full_route' => url('admin/business-settings/notification-channel?notification_type=user'),
                "page_title" => 'Notification_Channel',
                "keywords" => 'Notification Channel, Settings management',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Payment_methods',
                'uri' => 'admin/configuration/third-party/payment_config?type=digital_payment',
                'full_route' => url('admin/configuration/third-party/payment_config?type=digital_payment'),
                "page_title" => 'Payment_methods',
                "keywords" => 'Payment methods,Payment config',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Email_config',
                'uri' => 'admin/configuration/third-party/email-config',
                'full_route' => url('admin/configuration/third-party/email-config'),
                "page_title" => 'Email_config',
                "keywords" => 'Email config',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Sms_config',
                'uri' => 'admin/configuration/third-party/sms_config',
                'full_route' => url('admin/configuration/third-party/sms_config'),
                "page_title" => 'Sms_config',
                "keywords" => 'Sms config',
                "type" => 'menu',
            ],
            [
                'route_name' => 'Language_setup',
                'uri' => 'admin/configuration/language-setup',
                'full_route' => url('admin/configuration/language-setup'),
                "page_title" => 'Language_setup',
                "keywords" => 'Language setup, Configuration',
                "type" => 'menu',
            ],
        ];

        return collect($result)->map(function ($item) {
            return [
                "page_title" => $item['route_name'],
                'page_title_value' => $item['route_name'] ?? null,
                'key' => base64_encode($item['uri']),
                'uri' => $item['uri'],
                'uri_count' => count(explode('/', $item['uri'])),
                'full_route' => $item['full_route'] ?? '',
                'type' => $item['type'],
                'priority' => $item['priority'] ?? 1,
                'sorting' => $item['sorting'] ?? '',
                "keywords" => $item['keywords'],
            ];
        });
    }
}
