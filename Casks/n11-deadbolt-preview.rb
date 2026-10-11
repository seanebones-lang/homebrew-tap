cask "n11-deadbolt-preview" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.1.0-rc.1"
  sha256 arm:   "9dabeee245ee967bc3e5dca0db54c9c262472e47aa2d487bfff2634cac98afcb",
         intel: "72b7c9e0ad49f4f20ae21250553b3346c6a3cfaa93b37113ff5e871faa3830aa"

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
    This is the opt-in 1.1.0-rc.1 prerelease engine.
    Installation does not start a service or configure protection.
    Set an explicit policy before routing protected effects through DeadBolt.
    Keep operator credentials outside agent-controlled code.
    Run deadbolt drill, then the disposable file-effect evaluation:
      https://github.com/seanebones-lang/deadbolt/blob/main/docs/HOMEBREW.md
    Upgrades and uninstall preserve application-owned state.
    Stop protected dispatch and back up that state before switching versions.
  EOS
end
