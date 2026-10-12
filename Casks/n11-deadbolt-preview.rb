cask "n11-deadbolt-preview" do
  arch arm: "aarch64", intel: "x86_64"

  version "2.0.0-rc.1"
  sha256 arm:   "2a55ad536473ef9900510a516fb9407fd96e43429d8ba2b51cc378da4c6cd88b",
         intel: "44d96961ddea1baf90a1888aa2693b3a201091e08a863ee35ca07ced9864409d"

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
    This is the opt-in 2.0.0-rc.1 prerelease engine.
    Installation does not start a service or configure protection.
    Set an explicit policy before routing protected effects through DeadBolt.
    Keep operator credentials outside agent-controlled code.
    Run deadbolt drill, then the disposable file-effect evaluation:
      https://github.com/seanebones-lang/deadbolt/blob/main/docs/HOMEBREW.md
    Upgrades and uninstall preserve application-owned state.
    Stop protected dispatch and back up that state before switching versions.
    2.0 changes Rust API and destination-policy semantics; review the migration guide:
      https://github.com/seanebones-lang/deadbolt/blob/v2.0.0-rc.1/docs/MIGRATING-V2.md
  EOS
end
