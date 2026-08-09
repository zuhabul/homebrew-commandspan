class Commandspan < Formula
  desc "Remote terminal + agent control plane: pair your phone, approve agent actions live, drive tmux/mosh from anywhere"
  homepage "https://github.com/zuhabul/commandspan"
  url "https://github.com/zuhabul/homebrew-commandspan/releases/download/v0.1.1/commandspan-v0.1.1.tar.gz"
  sha256 "6bd9d8dcdfd7cc9cbebe5a3e870636e3602872e5a6b838bf4d7d0a93d8ad5718"
  license "Proprietary"
  head "https://github.com/zuhabul/commandspan.git", branch: "main"

  depends_on "rust" => :build
  depends_on "pkg-config" => :build
  depends_on "mosh"
  depends_on "tmux"
  depends_on "qrencode"
  depends_on "jq"

  def install
    # Build the daemon + supervisor from the release tarball.
    system "cargo", "install", *std_cargo_args(path: "services/daemon")
    system "cargo", "install", *std_cargo_args(path: "crates/supervisor")

    # Pairing + hook helper scripts (self-contained; no repo layout needed).
    bin.install "scripts/commandspan-pair-qr.sh" => "commandspan-pair-qr"
    bin.install "scripts/commandspan-setup.sh" => "commandspan-setup"
    bin.install "scripts/install-hook-claude.sh" => "commandspan-hook-claude"
    bin.install "scripts/install-hooks.sh" => "commandspan-install-hooks"
    bin.install "scripts/display-pairing-qr.swift" => "commandspan-display-qr"
    bin.install "scripts/render-pairing-qr.swift" => "commandspan-render-qr"
  end

  service do
    run [opt_bin/"commandspand", "serve"]
    keep_alive true
    working_dir var
    log_path var/"log/commandspan.log"
    error_log_path var/"log/commandspan.error.log"
  end

  test do
    assert_match "commandspand", shell_output("#{bin}/commandspand --version")
  end
end