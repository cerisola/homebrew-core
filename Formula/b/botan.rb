class Botan < Formula
  desc "Cryptographic algorithms and formats library in C++"
  homepage "https://botan.randombit.net/"
  url "https://botan.randombit.net/releases/Botan-3.8.0.tar.xz"
  sha256 "2af468933ba6b53b1a65696cdae6479f04726c606c19ee8bd0252df3faf07f99"
  license "BSD-2-Clause"
  head "https://github.com/randombit/botan.git", branch: "master"

  livecheck do
    url :homepage
    regex(/href=.*?Botan[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_sequoia: "828c6482aa84b598e9e7814b840f1540c7970fc8b339efe9b4d2cdf6cd2a37c4"
    sha256 arm64_sonoma:  "6949d51bc49e0926e0887e1faa0cada0cfef2d1b1ac4626ad8c7b96e45de3d3b"
    sha256 arm64_ventura: "ed129b0d70088270e69701049fb5dfd19a9f234105cee83e1c3ab1d088c28094"
    sha256 sonoma:        "70de9a26d70616dfa6a9688d9ad0c0bcd9ba551f14faa5ffc8073541d4c522c6"
    sha256 ventura:       "b921480c1e85f1dc574754898bc21b778b3e450945c6c2e4e579a52ef3a3c355"
    sha256 arm64_linux:   "ef40bc156a84dd5fcb9a62cee8a70ab50cbd323b3b194e2bf6764fa9afe34a14"
    sha256 x86_64_linux:  "fbc259942cc0414e004fdb16e9b810c7110d1d411705ac64c1f2969756f506d2"
  end

  depends_on "pkgconf" => :build
  depends_on "ca-certificates"
  depends_on "python@3.13"
  depends_on "sqlite"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  on_macos do
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1400
  end

  fails_with :clang do
    build 1400
    cause "Requires C++20"
  end

  def python3
    which("python3.13")
  end

  def install
    ENV.runtime_cpu_detection

    args = %W[
      --prefix=#{prefix}
      --docdir=share/doc
      --with-zlib
      --with-bzip2
      --with-sqlite3
      --system-cert-bundle=#{Formula["ca-certificates"].pkgetc}/cert.pem
    ]
    args << "--with-commoncrypto" if OS.mac?

    if OS.mac? && DevelopmentTools.clang_build_version <= 1400
      ENV.llvm_clang

      ldflags = %W[-L#{Formula["llvm"].opt_lib}/c++ -L#{Formula["llvm"].opt_lib} -lunwind]
      args << "--ldflags=#{ldflags.join(" ")}"
    end

    system python3, "configure.py", *args
    system "make", "install"
  end

  test do
    (testpath/"test.txt").write "Homebrew"
    (testpath/"testout.txt").write shell_output("#{bin}/botan base64_enc test.txt")
    assert_match "Homebrew", shell_output("#{bin}/botan base64_dec testout.txt")
  end
end
