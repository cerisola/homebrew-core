class Pocketbase < Formula
  desc "Open source backend for your next project in 1 file"
  homepage "https://pocketbase.io/"
  url "https://github.com/pocketbase/pocketbase/archive/refs/tags/v0.18.4.tar.gz"
  sha256 "be34fc53c820c7ba7b2acb67b56e7a57b003fdbba1f0cfdaf07d6ec9c54c2c9f"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "42b022ec3c106324c5beb2fc9ec7a72b99f297fd97924b0162e364eeeba569be"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "42b022ec3c106324c5beb2fc9ec7a72b99f297fd97924b0162e364eeeba569be"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "42b022ec3c106324c5beb2fc9ec7a72b99f297fd97924b0162e364eeeba569be"
    sha256 cellar: :any_skip_relocation, ventura:        "4ad46e83642504c087b06ff9fbf9cd4e95f21e96b424d8ed8f4edfb38a3e8d99"
    sha256 cellar: :any_skip_relocation, monterey:       "4ad46e83642504c087b06ff9fbf9cd4e95f21e96b424d8ed8f4edfb38a3e8d99"
    sha256 cellar: :any_skip_relocation, big_sur:        "4ad46e83642504c087b06ff9fbf9cd4e95f21e96b424d8ed8f4edfb38a3e8d99"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "7097a0fffb3e154e152b015bb20b0022d3ae46c7efef4ea61151c366ec1c1fe6"
  end

  depends_on "go" => :build

  uses_from_macos "netcat" => :test

  def install
    ENV["CGO_ENABLED"] = "0"

    system "go", "build", *std_go_args(ldflags: "-s -w -X github.com/pocketbase/pocketbase.Version=#{version}"), "./examples/base"
  end

  test do
    assert_match "pocketbase version #{version}", shell_output("#{bin}/pocketbase --version")

    port = free_port
    _, _, pid = PTY.spawn("#{bin}/pocketbase serve --dir #{testpath}/pb_data --http 127.0.0.1:#{port}")
    sleep 5

    system "nc", "-z", "localhost", port
    Process.kill "SIGINT", pid

    assert_predicate testpath/"pb_data", :exist?, "pb_data directory should exist"
    assert_predicate testpath/"pb_data", :directory?, "pb_data should be a directory"

    assert_predicate testpath/"pb_data/data.db", :exist?, "pb_data/data.db should exist"
    assert_predicate testpath/"pb_data/data.db", :file?, "pb_data/data.db should be a file"

    assert_predicate testpath/"pb_data/logs.db", :exist?, "pb_data/logs.db should exist"
    assert_predicate testpath/"pb_data/logs.db", :file?, "pb_data/logs.db should be a file"
  end
end
