// Generated by CoffeeScript 1.9.1
(function() {
  var ShaHasher, crypto;

  crypto = require("crypto");

  ShaHasher = (function() {
    function ShaHasher() {}

    ShaHasher.prototype.hash = function(file, entry, done) {
      var shaHasher;
      if (!file.isBuffer()) {
        return done(new Error("only file buffers are supported"));
      }
      shaHasher = crypto.createHash("sha1");
      shaHasher.update(file.contents);
      return done(null, shaHasher.digest("hex"));
    };

    return ShaHasher;

  })();

  module.exports = ShaHasher;

}).call(this);
