cask "n11-deadbolt" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.0.3"
  sha256 arm:   "d8af0582d347e56ae4d618f6ac2e4380d52b4b01ffc57a9e385e5cc33cc36a41",
         intel: "3534804199a637e75f53179399f9130e86c53206dcc7cbfe2253fc6eae224f04"

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
    This installs the stable 1.0.3 engine.
    Installation does not start a service or configure protection.
    Set an explicit policy before routing protected effects through DeadBolt.
    Keep operator credentials outside agent-controlled code.
    Run deadbolt drill, then the disposable file-effect evaluation:
      https://github.com/seanebones-lang/deadbolt/blob/main/docs/HOMEBREW.md
    Upgrades and uninstall preserve application-owned state.
    Stop protected dispatch and back up that state before switching versions.
  EOS
end
