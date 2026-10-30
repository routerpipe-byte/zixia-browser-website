// Sends a key press to the SWF player on this page, for the buttons below the game.
function zixiaPressKey(code, key, keyCode) {
  var player = document.querySelector('ruffle-embed, ruffle-object, ruffle-player') || document.querySelector('embed');
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
// Turns all effects on once the game has started (the same as pressing Enter).
function zixiaJuiceOnLoad() {
  var done = false;
  function juice() { if (!done) { done = true; zixiaPressKey('Enter', 'Enter', 13); } }
  var tries = 0, timer = setInterval(function () {
    var player = document.querySelector('ruffle-embed, ruffle-object, ruffle-player');
    tries++;
    if (player && player.readyState === 2) { clearInterval(timer); setTimeout(juice, 800); }
    else if (tries > 40) { clearInterval(timer); juice(); }
  }, 250);
}
