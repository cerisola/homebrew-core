class Jackett < Formula
  desc "API Support for your favorite torrent trackers"
  homepage "https://github.com/Jackett/Jackett"
  url "https://github.com/Jackett/Jackett/archive/refs/tags/v0.21.976.tar.gz"
  sha256 "4c9ce04d45c50c827099298c3cb2f91fba0e9db0c11bdcac83de92501adbfa29"
  license "GPL-2.0-only"
  head "https://github.com/Jackett/Jackett.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "c12508e013cb239bc166fe874e31732614370f644e6cee4ce8fd429e8e7c2b4c"
    sha256 cellar: :any,                 arm64_monterey: "9d54e1fcae86d6b762f8bef243d13ff2950516ac34a86fab31297fedd2ffe7cd"
    sha256 cellar: :any,                 ventura:        "d3d1dfdcc8b3d494588dd20f08d91b6e4682b02d29b0a2fa3e8c1f5ee2cbda89"
    sha256 cellar: :any,                 monterey:       "4c30769a5ec2ca5febb3ee1c790d9f2e68cfcf1dd056481989106bec72b020ae"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a269078af23d4652b9fa921699ea9a7db74ba68fed040659908054b3c00b1341"
  end

  depends_on "dotnet@6"

  def install
    dotnet = Formula["dotnet@6"]
    os = OS.mac? ? "osx" : OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --runtime #{os}-#{arch}
      --no-self-contained
    ]
    if build.stable?
      args += %W[
        /p:AssemblyVersion=#{version}
        /p:FileVersion=#{version}
        /p:InformationalVersion=#{version}
        /p:Version=#{version}
      ]
    end

    system "dotnet", "publish", "src/Jackett.Server", *args

    (bin/"jackett").write_env_script libexec/"jackett", "--NoUpdates",
      DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}"
  end

  service do
    run opt_bin/"jackett"
    keep_alive true
    working_dir opt_libexec
    log_path var/"log/jackett.log"
    error_log_path var/"log/jackett.log"
  end

  test do
    assert_match(/^Jackett v#{Regexp.escape(version)}$/, shell_output("#{bin}/jackett --version 2>&1; true"))

    port = free_port

    pid = fork do
      exec "#{bin}/jackett", "-d", testpath, "-p", port.to_s
    end

    begin
      sleep 10
      assert_match "<title>Jackett</title>", shell_output("curl -b cookiefile -c cookiefile -L --silent http://localhost:#{port}")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
