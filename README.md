# NextEleven Homebrew tap

Signed native macOS installation for [DeadBolt](https://seanebones-lang.github.io/deadbolt/),
the Apache-2.0 local execution gate for software agents. This is a NextEleven
upstream tap; it is not a listing in Homebrew's official core/cask repositories
or an independent security certification.

## Install the stable engine

With Homebrew already installed:

```sh
brew install --cask seanebones-lang/tap/n11-deadbolt
deadbolt --version
deadbolt drill
```

This installs engine **1.0.3**, selecting the existing signed Apple Silicon or
Intel archive by architecture. No Rust compiler, model key or GitHub account is
needed. Homebrew verifies the pinned archive checksum. These command-line
executables use Apple's accepted online notarization tickets, not app-bundle
stapling. Keep macOS verification enabled; report an installation rejection
rather than removing quarantine or disabling Gatekeeper.

Homebrew versions that require explicit tap trust may ask to trust the selected
cask. Review the [cask definition](Casks/n11-deadbolt.rb), then trust that package:

```sh
brew trust --cask seanebones-lang/tap/n11-deadbolt
brew install --cask seanebones-lang/tap/n11-deadbolt
```

Earlier Homebrew versions may not have `brew trust`; follow the installed
version's prompt. Whole-tap trust is unnecessary. This package does not start a
service, configure policy or make every agent tool protected. Set explicit
policy and route each protected effect through your trusted dispatcher.

## Opt into the prerelease

```sh
brew install --cask seanebones-lang/tap/n11-deadbolt-preview
```

The preview installs engine **1.1.0-rc.1** with exact-action approvals, scoped
admission credentials and dispatch helpers. It is explicitly a prerelease.
The stable and preview casks conflict because both provide `deadbolt`.
For the optional Python integration, use Python 3.10+ and:

```sh
python -m pip install 'n11-deadbolt-client[openai-agents]==1.1.0rc1'
```

The Python package and engine have separate installation and version spelling.
MCP bundle 1.1.0 contains stable engine 1.0.3, not this preview engine.

## Verify real effects

The installed archive retains its examples and documentation. Run its eleven-case
disposable evaluation with Python 3.9+:

```sh
DEADBOLT_RELEASE="$(brew --caskroom)/n11-deadbolt/1.0.3/deadbolt-1.0.3-$(uname -m | sed 's/arm64/aarch64/')-apple-darwin"
python3 "$DEADBOLT_RELEASE/examples/evaluate.py" --binary "$DEADBOLT_RELEASE/deadbolt"
```

For the preview, use `n11-deadbolt-preview`, `1.1.0-rc.1` and the corresponding
archive directory. The evaluation uses disposable state and checks actual file
contents or absence for allow, policy denial, one-shot approval, revocation,
child revocation, outage and restart. It does not use a model or prove whole-agent
containment. See the [current installation guide](https://github.com/seanebones-lang/deadbolt/blob/main/docs/HOMEBREW.md).

## Update, switch and remove

Stop protected dispatch, stop your application-owned sidecar, and back up its
state before changing the engine. Then:

```sh
brew update
brew upgrade --cask seanebones-lang/tap/n11-deadbolt
```

Preview updates use its separate cask name. A reviewed release updates the
cask version and checksums; installing this tap does not automatically upgrade
the engine or start it on login.

To switch channels, uninstall the current cask before installing the other:

```sh
brew uninstall --cask n11-deadbolt
brew install --cask seanebones-lang/tap/n11-deadbolt-preview
```

To remove it, use `brew uninstall --cask n11-deadbolt` or the preview name.
The casks have no `zap`/state-deletion hooks. Application-owned databases,
events, policies and credentials are preserved. Restoring an older engine
requires compatible state and policy; quiesce dispatch and follow the
[upgrade/rollback guide](https://github.com/seanebones-lang/deadbolt/blob/main/docs/INSTALL.md#upgrade-and-remove).
An existing independently installed `deadbolt` executable is not overwritten;
resolve that installation deliberately rather than forcing this one.

## Maintainers and validation

[`releases.json`](releases.json) pins each archive and installed executable hash,
engine version and Apple's matching accepted notarization submission. The
[CI workflow](.github/workflows/test.yml) installs stable and preview separately
on Apple Silicon and Intel, checks signatures and installed metadata, performs
eleven real file effects, refuses the conflicting channel, reinstalls and
uninstalls, and checks that a disposable application database remains unchanged.
Reinstall is tested; this is not a claim of an upgrade between distinct stable
versions or of independent customer adoption.

The preview is intentionally a GitHub prerelease.
[`audit_exceptions/github_prerelease_allowlist.json`](audit_exceptions/github_prerelease_allowlist.json)
declares only `n11-deadbolt-preview` version `1.1.0-rc.1`; stable is not exempt.
All other strict online audits and installation checks remain enabled.

For a new engine release:

1. Verify its exact release/tag identity, ZIP hashes, signatures and matching
   Apple notarization logs for both architectures. Do not follow an MCP bundle's
   version or change archive contents under an existing version.
2. Update the selected cask and `releases.json`. For a preview, update its exact
   prerelease declaration as well. Preserve the stable/preview
   distinction and mutual conflict. Review the published version's state and
   policy compatibility before suggesting a rollback.
3. Open a pull request. Run `brew style`, strict online cask audit and the
   installation/lifecycle matrix. A denied effect must leave its file absent.
4. Merge the reviewed head only after all checks pass, then verify a fresh
   installation from the public tap and update the main developer guides.

Report installation issues in [this tap](https://github.com/seanebones-lang/homebrew-tap/issues).
For engine bugs and private security reporting, use
[DeadBolt's contribution/security guidance](https://github.com/seanebones-lang/deadbolt).

Copyright NextEleven LLC. Tap definitions and test code are Apache-2.0; the
downloaded engine and notices retain their original release licenses.
