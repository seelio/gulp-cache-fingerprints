// Generated by CoffeeScript 1.8.0
(function() {
  var WError, abspathToWorkingDir, computeOptions, crypto, fs, git, path, relpathToFile, through;

  fs = require("fs");

  path = require("path");

  through = require("through2");

  git = require("nodegit");

  WError = require("verror").WError;

  crypto = require("crypto");

  computeOptions = require("./lib/compute_options");

  abspathToWorkingDir = function(repo) {
    return repo.path().replace(new RegExp("\.git/?$"), "");
  };

  relpathToFile = function(filePath, workingPath, basePath) {
    return filePath.replace(new RegExp("^" + workingPath + "/?"), "").replace(new RegExp("^" + basePath + "/?"), "");
  };

  module.exports = function(opts) {
    var cache, commit, defaults, flush, getTheHash, options, repo, setupGitVars, transform, transformHelper, workingDir;
    if (opts == null) {
      opts = {};
    }
    defaults = {
      root: null,
      build: null,
      base: "public",
      output: ".fingerprint-cache.json"
    };
    options = computeOptions(defaults, opts);
    options.build || (options.build = options.root);
    options.basepath = path.resolve(options.build, options.base);
    cache = {};
    repo = null;
    commit = null;
    workingDir = null;
    setupGitVars = function(done) {
      return git.Repository.open(options.root).then(function(_repo) {
        repo = _repo;
        workingDir = abspathToWorkingDir(repo);
        return repo.head();
      }).then(function(ref) {
        var hashOfHEAD;
        hashOfHEAD = ref.target().tostrS();
        return repo.getCommit(hashOfHEAD);
      }).then(function(_commit) {
        return commit = _commit;
      })["catch"](function(err) {
        return done(new WError(err, "couldn't read git repository"));
      }).done(function() {
        return done();
      });
    };
    getTheHash = function(file, done) {
      var fileRelpath, found, notFound;
      fileRelpath = relpathToFile(file.path, workingDir, options.base);
      found = function(entry) {
        cache[fileRelpath] = entry.sha();
        return done();
      };
      notFound = function(err) {
        var digest, shaHasher;
        shaHasher = crypto.createHash("sha1");
        if (file.isBuffer()) {
          shaHasher.update(file.contents);
          digest = shaHasher.digest("hex");
          cache[fileRelpath] = digest;
          return done();
        } else if (file.isStream()) {
          return done(new Error("streams aren't supported"));
        }
      };
      return commit.getEntry(fileRelpath).then(found, notFound);
    };
    transformHelper = function(file, enc, done) {
      return getTheHash(file, done);
    };
    transform = function(file, enc, done) {
      if (file.isDirectory()) {
        return done();
      }
      if (file.isNull()) {
        return done(new Error("file is null, can't hash"));
      }
      if (repo) {
        return transformHelper(file, enc, done);
      } else {
        return setupGitVars(function(err) {
          if (err) {
            return done(err);
          }
          return transformHelper(file, enc, done);
        });
      }
    };
    flush = function(done) {
      var filepath, keys;
      keys = Object.keys(cache);
      filepath = path.resolve(options.root, options.output);
      return fs.writeFile(filepath, JSON.stringify(cache), function(err) {
        console.log("wrote " + keys.length + " hashes", filepath);
        return done();
      });
    };
    return through.obj(transform, flush);
  };

}).call(this);
