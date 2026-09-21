const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const root = path.resolve(__dirname, '..');
const source = fs.readFileSync(path.join(root, 'assets/download-routing.js'), 'utf8');
const appStore = 'https://apps.apple.com/app/id6794041773';
const apk = 'https://www.52zixia.com/zixia-browser-release.apk';

function route(navigatorProperties, hasButton = true) {
  const attributes = new Map([['href', '#download']]);
  const button = {
    get href() { return attributes.get('href'); },
    set href(value) { attributes.set('href', value); },
    getAttribute(name) { return attributes.get(name) ?? null; },
    setAttribute(name, value) { attributes.set(name, String(value)); },
    removeAttribute(name) { attributes.delete(name); },
  };
  const noAutomaticNavigation = () => assert.fail('Routing must wait for a user click');
  const location = new Proxy({
    assign: noAutomaticNavigation,
    replace: noAutomaticNavigation,
  }, { set: noAutomaticNavigation });
  const context = {
    navigator: { userAgent: '', platform: '', maxTouchPoints: 0, ...navigatorProperties },
    document: {
      querySelector(selector) {
        assert.equal(selector, '.nav-download');
        return hasButton ? button : null;
      },
    },
    setTimeout: () => assert.fail('Do not use a timer to infer whether Google Play is installed'),
  };
  Object.defineProperty(context, 'location', {
    get: () => location,
    set: noAutomaticNavigation,
  });
  context.window = context;
  vm.runInNewContext(source, context, { filename: 'download-routing.js' });
  return button.href;
}

function assertGooglePlayWithApkFallback(href) {
  assert.ok(href.startsWith('intent://play.google.com/store/apps/details?id=com.zixia#Intent;'));
  const intent = new Map(href.split('#Intent;')[1].split(';').map((item) => {
    const separator = item.indexOf('=');
    return separator < 0 ? [item, ''] : [item.slice(0, separator), item.slice(separator + 1)];
  }));
  assert.equal(intent.get('scheme'), 'https');
  assert.equal(intent.get('package'), 'com.android.vending');
  assert.equal(decodeURIComponent(intent.get('S.browser_fallback_url')), apk);
  assert.ok(intent.has('end'));
}

test('iPhone and iPad open the Zixia App Store listing', () => {
  for (const device of ['iPhone', 'iPad', 'iPod']) {
    assert.equal(route({ userAgent: `Mozilla/5.0 (${device}; CPU OS 18_0 like Mac OS X)` }), appStore);
  }
});

test('iPad desktop mode opens the App Store', () => {
  assert.equal(route({
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 Version/18.0 Safari/605.1.15',
    platform: 'MacIntel',
    maxTouchPoints: 5,
  }), appStore);
});

test('a MacBook preserves the download section', () => {
  assert.equal(route({
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 Safari/605.1.15',
    platform: 'MacIntel',
    maxTouchPoints: 0,
  }), '#download');
});

test('Android opens Google Play with the direct APK fallback', () => {
  assertGooglePlayWithApkFallback(route({
    userAgent: 'Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 Chrome/130.0.0.0 Mobile Safari/537.36',
  }));
});

test('Huawei follows the same Android routing instead of assuming Play is absent', () => {
  assertGooglePlayWithApkFallback(route({
    userAgent: 'Mozilla/5.0 (Linux; Android 12; HUAWEI LIO-AN00) AppleWebKit/537.36 HuaweiBrowser/14.0.0.0 Mobile Safari/537.36',
  }));
});

test('Android client hints work when the user agent does not name Android', () => {
  assertGooglePlayWithApkFallback(route({
    userAgent: 'Mozilla/5.0 Chrome/130.0.0.0 Safari/537.36',
    userAgentData: { platform: 'Android' },
  }));
});

test('Windows Phone compatibility tokens do not route to Android or iOS', () => {
  assert.equal(route({
    userAgent: 'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; Microsoft; Lumia 950) AppleWebKit/537.36 Chrome/42.0.2311.135 Mobile Safari/537.36 Edge/12.10586',
  }), '#download');
});

test('desktop and unrecognized systems preserve the download section', () => {
  for (const userAgent of ['', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', 'Mozilla/5.0 (X11; Linux x86_64)']) {
    assert.equal(route({ userAgent }), '#download');
  }
});

test('pages without a header download button do not throw', () => {
  assert.doesNotThrow(() => route({ userAgent: 'Android' }, false));
});

function attributes(tag) {
  return Object.fromEntries([...tag.matchAll(/([\w-]+)\s*=\s*(["'])(.*?)\2/g)].map((match) => [match[1], match[3]]));
}

for (const relativePath of ['index.html', 'zh-cn/index.html']) {
  test(`${relativePath} loads the routing script and retains manual downloads`, () => {
    const html = fs.readFileSync(path.join(root, relativePath), 'utf8');
    const pageUrl = new URL(relativePath, 'https://www.52zixia.com/');
    const scripts = [...html.matchAll(/<script\b[^>]*>/gi)].map((match) => attributes(match[0]));
    assert.equal(scripts.filter((script) => script.src &&
      new URL(script.src, pageUrl).pathname === '/assets/download-routing.js').length, 1);

    const anchors = [...html.matchAll(/<a\b[^>]*>/gi)].map((match) => attributes(match[0]));
    const headerButton = anchors.find((anchor) => (anchor.class || '').split(/\s+/).includes('nav-download'));
    assert.equal(headerButton?.href, '#download', 'No-JavaScript users must retain the download section');
    assert.match(html, /\bid=["']download["']/);
    for (const destination of [appStore, apk, 'https://play.google.com/store/apps/details?id=com.zixia']) {
      assert.ok(anchors.some((anchor) => anchor.href && new URL(anchor.href, pageUrl).href === destination),
        `Missing manual download link: ${destination}`);
    }
  });
}
