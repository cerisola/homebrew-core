require "language/node"

class Snowpack < Formula
  desc "Frontend build tool designed for the modern web"
  homepage "https://www.snowpack.dev"
  url "https://registry.npmjs.org/snowpack/-/snowpack-3.6.2.tgz"
  sha256 "600189376bd30203ea6d4b1ff18b8689132e40bb6b8d29d7d84f97e2eae95d08"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "e0cf8e321c3f7b84345bd121ab8f979b505697b47c631a01b09f13aa434d26d3"
    sha256 cellar: :any_skip_relocation, big_sur:       "f3da70d82840436fe9bef40d613e7a6e1dc4d87ea9bf48aeeafcf113746a9e09"
    sha256 cellar: :any_skip_relocation, catalina:      "f3da70d82840436fe9bef40d613e7a6e1dc4d87ea9bf48aeeafcf113746a9e09"
    sha256 cellar: :any_skip_relocation, mojave:        "f3da70d82840436fe9bef40d613e7a6e1dc4d87ea9bf48aeeafcf113746a9e09"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    mkdir "work" do
      system bin/"snowpack", "init"
      assert_predicate testpath/"work/snowpack.config.js", :exist?

      inreplace testpath/"work/snowpack.config.js",
        "  packageOptions: {\n    /* ... */\n  },",
        "  packageOptions: {\n    source: \"remote\"\n  },"
      system bin/"snowpack", "add", "react"
      deps_contents = File.read testpath/"work/snowpack.deps.json"
      assert_match(/\s*"dependencies":\s*{\s*"react": ".*"\s*}/, deps_contents)

      assert_match "Build Complete", shell_output("#{bin}/snowpack build")
    end
  end
end
