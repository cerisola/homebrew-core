class Grex < Formula
  desc "Command-line tool for generating regular expressions"
  homepage "https://github.com/pemistahl/grex"
  url "https://github.com/pemistahl/grex/archive/v1.1.0.tar.gz"
  sha256 "52a9d5ddc15c7fb227c87147d991bfabe2aae1fbef8169893a9111dcd3aa641f"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "972e86f0ad63118acec99822c9a1836b874866cbbde963fec76dac07f560fc6f"
    sha256 cellar: :any_skip_relocation, big_sur:       "69b19b50f9db286414869271c0622b0415784559a87b245caa67ea882b59a2ea"
    sha256 cellar: :any_skip_relocation, catalina:      "a6a2e903b81404d8637492fdbdea4bd2bafc5b9e2ead89e565ed64ca27a8a9ad"
    sha256 cellar: :any_skip_relocation, mojave:        "add77eeff9facb30f56b579ab893bcfafcae43699e629b3780f67b560fb59ad2"
    sha256 cellar: :any_skip_relocation, high_sierra:   "b09e46aabadbb7742e60b942386f994795fcfca48a2834b2dbc4bc7fdb500dcc"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    output = shell_output("#{bin}/grex a b c")
    assert_match "^[a-c]$\n", output
  end
end
