class Algol68g < Formula
  desc "Algol 68 compiler-interpreter"
  homepage "https://jmvdveer.home.xs4all.nl/algol.html"
  url "https://jmvdveer.home.xs4all.nl/algol68g-3.3.18.tar.gz"
  sha256 "63f277b0214020366900611c8c6db127461c883c0544bf02f7be697eb9ced2f6"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://jmvdveer.home.xs4all.nl/en.download.algol-68-genie-current.html"
    regex(/href=.*?algol68g[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "42c7ce36b66d36ce2bb0869441ee020b6c8444d3fa374e44650ef69fe26e14a9"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "8fc517115721336a35983fe64e1772e1db3c4b6230de042aefe32ef95b5358d0"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "c070d75aff638dd3fa43eee2cb556ae68e08f070f7ff36a7cb6ea59e934dc75c"
    sha256                               ventura:        "a8e682ec6828f14604bfb0e9e3cf297dcb4a0b8b121f912fdeb019592c7562ee"
    sha256                               monterey:       "f6d7cbb8f05a4829090ebb8b40f622b5959b859f98da081f96d192cd0ff95b42"
    sha256                               big_sur:        "a90ed4b46f71eebccd1a4fa6820fcb5d08801ed83d35f8e57aee316ac149357e"
    sha256                               x86_64_linux:   "4b4ae2f2fd686ad0a54b01e647d548533b346b953f16813248b52060ceb76755"
  end

  on_linux do
    depends_on "libpq"
  end

  def install
    # Workaround for Xcode 14.3.
    ENV.append_to_cflags "-Wno-implicit-function-declaration"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    path = testpath/"hello.alg"
    path.write <<~EOS
      print("Hello World")
    EOS

    assert_equal "Hello World", shell_output("#{bin}/a68g #{path}").strip
  end
end
