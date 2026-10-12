cask "n11-deadbolt" do
  arch arm: "aarch64", intel: "x86_64"

  version "2.0.0"
  sha256 arm:   "e33aa9b4167f3af1f187045741c7496f5aef6f85131e52f84327559a2d20ae9f",
         intel: "3b206602f234b0a9444fabe22adf00bcb6ee32af4e0cec5df9d8b70ff12cf685"

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
    This installs the stable 2.0.0 engine.
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
