class Qcachegrind < Formula
  desc "Visualize data generated by Cachegrind and Calltree"
  homepage "https://kcachegrind.github.io/"
  url "https://download.kde.org/stable/applications/19.08.3/src/kcachegrind-19.08.3.tar.xz"
  sha256 "8fc5e0643bb826b07cb5d283b8bd6fd5da4979f6125b43b1db3a9db60b02a36a"
  license "GPL-2.0"

  bottle do
    cellar :any
    sha256 "0a16a588310bd7251602e330366a5abde440e1f8ae4ac564eb99ac9e69298c0c" => :catalina
    sha256 "0e4e81423ef0fc5dd92f8e5dc247b1add910ddbf1491ba6d11175fe57c9642d2" => :mojave
    sha256 "67924a8923c4b2f29b69dd1cde8131d072a674051ec6ffc637547b4b67a7c31d" => :high_sierra
  end

  depends_on "graphviz"
  depends_on "qt"

  def install
    cd "qcachegrind" do
      system "#{Formula["qt"].opt_bin}/qmake", "-spec", "macx-clang",
                                               "-config", "release"
      system "make"
      prefix.install "qcachegrind.app"
      bin.install_symlink prefix/"qcachegrind.app/Contents/MacOS/qcachegrind"
    end
  end
end
