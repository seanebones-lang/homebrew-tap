cask "n11-deadbolt-preview" do
  arch arm: "aarch64", intel: "x86_64"

  version "2.0.0-rc.2"
  sha256 arm:   "26c33da31ba36b0753bfdc89e43913d1bd62c1ee102a59009b29a7b09967d689",
         intel: "abdf66e8a12ad120f88686a24fd76828e430dc9a39728ba078a89b8afe0abf3e"

  url "https://github.com/seanebones-lang/deadbolt/releases/download/v#{version}/deadbolt-#{version}-#{arch}-apple-darwin.zip"
  name "DeadBolt Preview"
  desc "Local execution gate for software agents"
  homepage "https://seanebones-lang.github.io/deadbolt/"

  livecheck do
    skip "Engine releases are reviewed separately from MCP bundle versions"
  end

  conflicts_with cask: "n11-deadbolt"
  depends_on :macos

  binary "deadbolt-#{version}-#{arch}-apple-darwin/deadbolt"

  caveats <<~EOS
    This is the opt-in 2.0.0-rc.2 prerelease engine.
    Installation does not start a service or configure protection.
    Set an explicit policy before routing protected effects through DeadBolt.
    Keep operator credentials outside agent-controlled code.
    Fresh roots default to supervisor renewal; provision it before the 60-second idle expiry.
    Existing persisted modes are preserved; sidecar startup requires operator authentication.
    Run deadbolt drill, then the disposable file-effect evaluation:
      https://github.com/seanebones-lang/deadbolt/blob/main/docs/HOMEBREW.md
    Upgrades and uninstall preserve application-owned state.
    Stop protected dispatch and back up that state before switching versions.
    2.0 changes Rust API and destination-policy semantics; review the migration guide:
      https://github.com/seanebones-lang/deadbolt/blob/v2.0.0-rc.2/docs/MIGRATING-V2.md
  EOS
end
