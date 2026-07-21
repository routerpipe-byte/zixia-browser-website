# Zixia Browser 15.14.6 review package

## App build

- Version: `15.14.6` (`151406`)
- Canonical commit: `92b94412f8a0039d58e44eff5dfd2e85dd572230`
- Play bundle: `D:\vip\andriod\zixia-einkbro\app\build\outputs\bundle\play\app-play.aab`
- Play bundle SHA-256: `28b868c6e91aafa38189cc9699632f7afaf86c96cb3ded662b59d74adb5d1bdb`

## Changes for review

- Added dual-page reading for large tablets in landscape.
- Fixed reader bookmark and bookshelf touch handling on tablets.
- Added external-app redirect confirmation for the first two attempts.
- Added persistent block and direct allow-and-launch choices after repeated redirects.
- Synchronized the persistent redirect-block setting with both Clear data entry points.
- Added and verified translations for the new redirect controls.
- Fixed ad-block subscription screen crashes.
- Improved UTF-8 reader text handling.
- Prevented the AI assistant language flash.
- Improved WebView night-mode shutdown and network-error stability.

## Screenshot masters

Each master directory contains 11 images for visual review:

- Phone Chinese: `assets\screens` (720 x 1434)
- Phone English: `assets\screens-en` (720 x 1434)
- 7-inch Chinese: `assets\tablet-promo\7\zh` (1080 x 1920)
- 7-inch English: `assets\tablet-promo\7\en` (1080 x 1920)
- 10-inch Chinese: `assets\tablet-promo\10\zh` (2560 x 1440)
- 10-inch English: `assets\tablet-promo\10\en` (2560 x 1440)

The Chinese phone settings image no longer exposes a third-party URL. Phone
screenshots were widened without stretching the app UI so their long edge is no
more than twice their short edge.

## Proposed Play upload set

Google Play accepts up to eight screenshots per device type. The exact proposed
upload files are under `play-upload`, separated by device type and language.
The three omitted master images remain available and can be substituted before
upload.

The proposed selection prioritizes home, tools, AI, ad blocking, speed control,
reader, reader appearance, and read-aloud. Script management, the detailed
settings page, and fullscreen controls remain in the 11-image master sets.

## Proposed Play release notes

English:

> Added dual-page reading on large tablets in landscape. Improved reader
> bookmark and bookshelf interactions. Added confirmation and persistent
> blocking controls for external app redirects, including direct launch of
> installed target apps. Improved ad blocking, night mode, text encoding, and
> network error stability.

Chinese:

> 新增大屏平板横屏双页阅读；优化阅读器书签、书架触控；新增第三方应用跳转确认、
> 始终拦截及直接允许跳转；修复广告拦截订阅、夜间模式、文本编码与网络错误等稳定性问题。
