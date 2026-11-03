cask "n11-deadbolt" do
  arch arm: "aarch64", intel: "x86_64"

  version "2.0.1"
  sha256 arm:   "e4f204744f65a45a944761bb9597d7d17a637d714c1c56eec8ed69d5347839df",
         intel: "0075e54fe2dbc5f3081be751b793f6ad30e2238bbba59f42cfdb358e4b4bec06"

  url "https://github.com/seanebones-lang/deadbolt/releases/download/v#{version}/deadbolt-#{version}-#{arch}-apple-darwin.zip"
  name "DeadBolt"
  desc "Local execution gate for software agents"
  homepage "https://seanebones-lang.github.io/deadbolt/"

  livecheck do
    skip "Engine releases are reviewed separately from MCP bundle versions"
  end

  conflicts_with cask: "n11-deadbolt-preview"
  depends_on :macos

  binary "deadbolt-#{version}-#{arch}-apple-darwin/deadbolt"

  caveats <<~EOS
    This installs the stable 2.0.1 engine.
    Installation does not start a service or configure protection.
    Set an explicit policy before routing protected effects through DeadBolt.
    Keep operator credentials outside agent-controlled code.
    New runs default to supervisor renewal with a 60-second idle TTL.
    Review the v2 migration guide before upgrading existing integrations.
    Run deadbolt drill, then the disposable file-effect evaluation:
      https://github.com/seanebones-lang/deadbolt/blob/main/docs/HOMEBREW.md
    Upgrades and uninstall preserve application-owned state.
    Stop protected dispatch and back up that state before switching versions.
  EOS
end
