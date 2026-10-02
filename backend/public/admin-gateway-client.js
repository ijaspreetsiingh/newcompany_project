/**
 * Admin Panel Gateway Client
 * Intercepts AJAX calls and routes them through gateway
 */

class AdminGateway {
    constructor(gatewayUrl = 'http://localhost:3000') {
        this.gatewayUrl = gatewayUrl;
        this.gatewayEndpoint = '/api';
        this.originalFetch = window.fetch;
        this.originalXHR = window.XMLHttpRequest;
        this.interceptRequests();
    }

    interceptRequests() {
        // Intercept fetch
        window.fetch = async (url, options = {}) => {
            // Check if it's a backend request
            if (this.isBackendRequest(url)) {
                return this.gatewayFetch(url, options);
            }
            return this.originalFetch(url, options);
        };

        // Intercept XMLHttpRequest (for jQuery AJAX)
        const self = this;
        window.XMLHttpRequest = function() {
            const xhr = new self.originalXHR();
            const originalOpen = xhr.open;
            const originalSend = xhr.send;

            xhr.open = function(method, url) {
                this._method = method;
                this._url = url;
                return originalOpen.apply(this, arguments);
            };

            xhr.send = function(data) {
                if (self.isBackendRequest(this._url)) {
                    return self.gatewayXHR(this, data);
                }
                return originalSend.apply(this, arguments);
            };

            return xhr;
        };
    }

    isBackendRequest(url) {
        // Check if URL points to backend
        return url.includes('127.0.0.1:8000') || 
               url.includes('localhost:8000') ||
               url.includes('/admin/');
    }

    async gatewayFetch(url, options) {
        const action = this.getActionFromUrl(url);
        const id = this.extractId(url);

        const response = await fetch(`${this.gatewayUrl}${this.gatewayEndpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Cookie': document.cookie,
                'X-Requested-With': 'XMLHttpRequest',
            },
            body: JSON.stringify({
                action: action,
                data: options.body ? JSON.parse(options.body) : {},
                id: id,
                method: options.method || 'POST',
                isWeb: true
            }),
            credentials: 'include'
        });

        // Update cookies from response
        const setCookieHeader = response.headers.get('Set-Cookie');
        if (setCookieHeader) {
            this.setCookies(setCookieHeader);
        }

        return response;
    }

    gatewayXHR(xhr, data) {
        const action = this.getActionFromUrl(xhr._url);
        const id = this.extractId(xhr._url);

        const gatewayXhr = new this.originalXHR();
        
        gatewayXhr.open('POST', `${this.gatewayUrl}${this.gatewayEndpoint}`);
        gatewayXhr.setRequestHeader('Content-Type', 'application/json');
        gatewayXhr.setRequestHeader('Cookie', document.cookie);
        gatewayXhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
        gatewayXhr.withCredentials = true;

        gatewayXhr.onload = function() {
            // Copy response properties
            xhr.status = gatewayXhr.status;
            xhr.statusText = gatewayXhr.statusText;
            xhr.responseText = gatewayXhr.responseText;
            
            // Update cookies
            const setCookieHeader = gatewayXhr.getResponseHeader('Set-Cookie');
            if (setCookieHeader) {
                document.cookie = setCookieHeader;
            }

            if (xhr.onload) xhr.onload();
            if (xhr.onreadystatechange) xhr.onreadystatechange();
        };

        gatewayXhr.onerror = function() {
            if (xhr.onerror) xhr.onerror();
        };

        gatewayXhr.send(JSON.stringify({
            action: action,
            data: data,
            id: id,
            method: xhr._method,
            isWeb: true
        }));
    }

    getActionFromUrl(url) {
        // Map URLs to action codes
        const urlMap = {
            '/admin/get-updated-data': 'adgud',
            '/admin/login': 'adlog',
            '/admin/logout': 'adlgt',
            '/admin/dashboard': 'addas',
            '/admin/business-settings': 'adcfg',
            '/admin/business-settings/login/setup': 'adbus',
            '/admin/zone': 'adzon',
            '/admin/zone/create': 'adcrt',
            '/admin/zone/store': 'adsto',
            '/admin/zone/edit': 'adedt',
            '/admin/zone/update': 'adupz',
            '/admin/zone/delete': 'addel',
            '/admin/zone/status-update': 'adsts',
            '/admin/zone/download': 'addwn',
            '/admin/zone/table': 'adtbl',
            '/admin/customer': 'adcus',
            '/admin/customer/list': 'adcsl',
            '/admin/customer/status/update': 'adcst',
            '/admin/customer/delete': 'adcre',
            '/admin/provider': 'adpro',
            '/admin/provider/list': 'adpsl',
            '/admin/provider/status/update': 'adpst',
            '/admin/provider/delete': 'adpdl',
            '/admin/service': 'adser',
            '/admin/service/list': 'adssl',
            '/admin/category': 'adcat',
            '/admin/category/list': 'adcsl',
            '/admin/booking': 'adboo',
            '/admin/booking/list': 'adbsl',
            '/admin/booking/status-update': 'adbup',
            '/admin/booking/schedule-update': 'adbsc',
            '/admin/booking/data/download': 'adbdw',
            '/admin/payment': 'adpay',
            '/admin/payment-method': 'adpmt',
            '/admin/payment-method/list': 'adpml',
            '/admin/transaction': 'adtrn',
            '/admin/transaction/list': 'adtrl',
            '/admin/subscription': 'adsub',
            '/admin/subscription/list': 'adsul',
            '/admin/advertisement': 'adadv',
            '/admin/advertisement/list': 'adadl',
            '/admin/bid': 'adbid',
            '/admin/bid/list': 'adbdl',
            '/admin/notification': 'adnot',
            '/admin/notification/list': 'adntl',
            '/admin/message': 'admsg',
            '/admin/message/global': 'admgl',
            '/admin/report': 'adrep',
            '/admin/report/transaction': 'adrpt',
            '/admin/report/booking': 'adrpb',
            '/admin/settings': 'adset',
            '/admin/settings/general': 'adgen',
            '/admin/settings/app': 'adapp',
            '/admin/settings/localization': 'adloc',
            '/admin/settings/email': 'adema',
            '/admin/settings/sms': 'adsms',
            '/admin/settings/payment': 'adpay',
            '/admin/settings/storage': 'adsto',
            '/admin/activation-check': 'adact',
        };

        // Find matching action
        for (const [path, action] of Object.entries(urlMap)) {
            if (url.includes(path)) {
                return action;
            }
        }

        console.warn('No action found for URL:', url);
        return null;
    }

    extractId(url) {
        // Extract ID from URL patterns like /admin/zone/edit/123
        const match = url.match(/\/(\d+)(?:\/|$)/);
        return match ? match[1] : '';
    }

    setCookies(cookieString) {
        // Parse and set cookies
        const cookies = cookieString.split(', ');
        cookies.forEach(cookie => {
            document.cookie = cookie;
        });
    }
}

// Initialize gateway client
const adminGateway = new AdminGateway('http://localhost:3000');

console.log('Admin Gateway Client initialized');
