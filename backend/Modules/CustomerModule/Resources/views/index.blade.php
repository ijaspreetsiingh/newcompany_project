@php
    $content = $page_data->live_values ?? '';
    if (is_array($content)) {
        $content = implode(' ', array_filter($content));
    }
    $content = trim((string) $content, '"');
    $title = ucwords(str_replace('_', ' ', $page_data->key_name ?? ''));
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title }}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8f9fa; color: #212529; line-height: 1.7; }
        .page-header { background: #3C76F1; color: #fff; padding: 24px 16px; text-align: center; font-size: 20px; font-weight: 600; }
        .page-body { max-width: 800px; margin: 0 auto; padding: 24px 16px 48px; }
        .page-body p { margin-bottom: 12px; }
        .page-body img { max-width: 100%; height: auto; border-radius: 8px; }
        .page-body ul, .page-body ol { padding-left: 24px; margin-bottom: 12px; }
        .empty { text-align: center; color: #6c757d; padding: 48px 16px; }
    </style>
</head>
<body>
    <div class="page-header">{{ $title }}</div>
    <div class="page-body">
        @if(!empty($content))
            {!! $content !!}
        @else
            <p class="empty">Content coming soon.</p>
        @endif
    </div>
</body>
</html>
