// The SWF player on this page: whatever element now stands where the <embed> was (Ruffle's
// player element, or a browser's own Flash player in its place).
function zixiaPlayer() {
  return document.querySelector('ruffle-embed, ruffle-object, ruffle-player') || document.querySelector('.stage > *');
}
// Sends a key press to the SWF player on this page, for the buttons below the game.
function zixiaPressKey(code, key, keyCode) {
  var player = zixiaPlayer();
  if (!player) return;
  try { player.focus({preventScroll: true}); } catch (e) {}
  ['keydown', 'keyup'].forEach(function (type, i) {
    setTimeout(function () {
      var event = new KeyboardEvent(type, {code: code, key: key, bubbles: true, cancelable: true, composed: true});
      Object.defineProperty(event, 'keyCode', {value: keyCode});
      Object.defineProperty(event, 'which', {value: keyCode});
      player.dispatchEvent(event);
    }, i * 60);
  });
}
// Turns all effects on once the game is running (the same as pressing Enter). The game only
// listens for keys after its sounds have loaded, so Enter is repeated once a second for the
// first ten seconds; it stops as soon as the visitor presses a button or touches the game.
function zixiaJuiceOnLoad() {
  var stopped = false, presses = 0;
  function stop() { stopped = true; }
  document.addEventListener('pointerdown', stop, true);
  document.addEventListener('keydown', function (e) { if (e.isTrusted) stop(); }, true);
  var timer = setInterval(function () {
    var player = zixiaPlayer();
    if (stopped || presses >= 10) { clearInterval(timer); return; }
    if (player && player.readyState === 2) { presses++; zixiaPressKey('Enter', 'Enter', 13); }
  }, 1000);
}
