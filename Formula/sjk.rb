class Sjk < Formula
  desc "Swiss Java Knife"
  homepage "https://github.com/aragozin/jvm-tools"
  url "https://search.maven.org/remotecontent?filepath=org/gridkit/jvmtool/sjk-plus/0.17/sjk-plus-0.17.jar"
  sha256 "4f3d1b8b5c1c85b7fdcec1ebc880bac6d81da5d924fd445ce7e221e6728705d7"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "c1aa56b2a96e181fda0435cf56cf29c3338bce6c59ed2402a46dd33762765b88"
  end

  depends_on "openjdk"

  def install
    libexec.install "sjk-plus-#{version}.jar"
    bin.write_jar_script libexec/"sjk-plus-#{version}.jar", "sjk"
  end

  test do
    system bin/"sjk", "jps"
  end
end
