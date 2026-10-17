<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Device Token Abilities Map
    |--------------------------------------------------------------------------
    |
    | Defines the Sanctum token abilities granted to each device platform.
    |
    */
    'flutter-mobile' => [
        'expenses:read',
        'expenses:create',
        'expenses:update',
    ],

    'vue-web' => [
        '*',
    ],

    /*
    |--------------------------------------------------------------------------
    | Publicly Allowed Devices
    |--------------------------------------------------------------------------
    |
    | By default, only 'flutter-mobile' can request tokens via public
    | endpoints (/api/login and /api/register) to prevent unauthenticated
    | clients from requesting wildcard tokens.
    |
    */
    'allow_vue_web_tokens' => (bool) env('ALLOW_VUE_WEB_TOKENS', false),

    'public_devices' => env('ALLOW_VUE_WEB_TOKENS', false)
        ? ['flutter-mobile', 'vue-web']
        : ['flutter-mobile'],
];
