class Commandspan < Formula
  desc "Remote terminal + agent control plane: pair your phone, approve agent actions live, drive tmux/mosh from anywhere"
  homepage "https://github.com/zuhabul/commandspan"
  url "https://github.com/zuhabul/homebrew-commandspan/releases/download/v0.1.27/commandspan-v0.1.27.tar.gz"
  sha256 "eb98a8e85791dfe2633adba29b1d923e09275d7798d38235e777cf7e2994db55"
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
    bin.install "scripts/qr-render.py" => "qr-render.py"
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
    # tmux/mosh live under Homebrew's bin; the launchd service default PATH
    # (usr/bin:bin) cannot find them. Without /opt/homebrew/bin, session
    # discovery returns a bare parse error (tmux "unavailable").
    environment_variables "PATH" => "#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  end

  test do
    assert_match "commandspand", shell_output("#{bin}/commandspand --version")
  end
end