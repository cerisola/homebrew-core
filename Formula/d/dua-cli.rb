class DuaCli < Formula
  desc "View disk space usage and delete unwanted data, fast"
  homepage "https://lib.rs/crates/dua-cli"
  url "https://github.com/Byron/dua-cli/archive/refs/tags/v2.29.3.tar.gz"
  sha256 "69ae562a340b11668d8f43c6cd2de1a0777fa0afb951c6338dc58b62e86bb550"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "eeb45eae461ddbd7d0d5fa641341c3dc6ac6892313234a2cc8caaef19446b006"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d47770471424c1fa7f71e3ff0e20596876141b7ab02e5a2ca0a67e98c5e226dc"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "cdae043b7e8f0f851eca889ee03be89bc9fcfdd095039fc9b10e1f1762d12e6e"
    sha256 cellar: :any_skip_relocation, sonoma:        "23d3c0796385cc0b84c843d11745cfdde827acd71454ac9e0bb7d24f6e4b67c2"
    sha256 cellar: :any_skip_relocation, ventura:       "dad5262fa716e3b1bb874e59fd42f9afde286dd1226ad84834e7625c000da78b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "51df38524dc50cf584c26bbb69e8077d375969b5b6debdfc1e930094362db873"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    # Test that usage is correct for these 2 files.
    (testpath/"empty.txt").write("")
    (testpath/"file.txt").write("01")

    expected = %r{
      \e\[32m\s*0\s*B\e\[39m\ #{testpath}/empty.txt\n
      \e\[32m\s*2\s*B\e\[39m\ #{testpath}/file.txt\n
      \e\[32m\s*2\s*B\e\[39m\ total\n
    }x
    assert_match expected, shell_output("#{bin}/dua -A #{testpath}/*.txt")
  end
end
