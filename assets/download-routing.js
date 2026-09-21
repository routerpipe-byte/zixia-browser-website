(function () {
  'use strict';

  var button = document.querySelector('.nav-download');
  if (!button) return;

  var userAgent = navigator.userAgent || '';
  var platform = navigator.platform || '';
  var reportedPlatform = navigator.userAgentData && navigator.userAgentData.platform;

  // Some Windows Phone browsers include both Android and iPhone in their UA.
  if (/Windows Phone/i.test(userAgent)) return;

  var isIOS = /iPad|iPhone|iPod/i.test(userAgent) ||
    (platform === 'MacIntel' && navigator.maxTouchPoints > 1);

  if (isIOS) {
    button.href = 'https://apps.apple.com/app/id6794041773';
  } else if (/Android/i.test(userAgent) || reportedPlatform === 'Android') {
    // Let the browser resolve Google Play, without guessing from device brands.
    // A direct click preserves the user gesture required for external app links.
    // Supporting browsers use this APK fallback when Play cannot be opened:
    // https://developer.chrome.com/docs/android/intents
    // Keep the page's explicit APK links for browsers that block external apps.
    button.href = 'intent://play.google.com/store/apps/details?id=com.zixia' +
      '#Intent;scheme=https;package=com.android.vending;' +
      'S.browser_fallback_url=' +
      encodeURIComponent('https://www.52zixia.com/zixia-browser-release.apk') +
      ';end';
  }
})();
