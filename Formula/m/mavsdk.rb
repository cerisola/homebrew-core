class Mavsdk < Formula
  desc "API and library for MAVLink compatible systems written in C++17"
  homepage "https://mavsdk.mavlink.io"
  url "https://github.com/mavlink/MAVSDK.git",
      tag:      "v3.3.1",
      revision: "b4d03cc38724f1707314c215a70cda4226c0eea8"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256                               arm64_sequoia: "74920dc18002f7ba61c0eee1ab2a5eed0919b266445c2a3d5439d9b872029305"
    sha256                               arm64_sonoma:  "e1f4c9b80fe65d77417c467c5d40bb23b89ad2567ecc74a2bddeb9f5c7c4474e"
    sha256                               arm64_ventura: "3d57c09d077b9b93dfc6ce8dbbd4496365a5acd877d9849dc33400845ab87ae7"
    sha256 cellar: :any,                 sonoma:        "7ad08bebf9607e873ae1e9ff716fc14fec11ef3fb580624ce9b7f229ac50632b"
    sha256 cellar: :any,                 ventura:       "93154fe5b8999ce5ff3b485d38de421cd2c34a102d164ca49b0ee567901bbb17"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0081aad01e59c58aec4eaaf061dd75c1b445b77f22b63ae1f605362a36628401"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b9f87312ae2623f655288035474c76c1ee7ccde89cb42be2a6ca735ef68cb4f6"
  end

  depends_on "cmake" => :build
  depends_on "python@3.13" => :build
  depends_on "abseil"
  depends_on "c-ares"
  depends_on "curl"
  depends_on "grpc"
  depends_on "jsoncpp"
  depends_on "openssl@3"
  depends_on "protobuf"
  depends_on "re2"
  depends_on "tinyxml2"
  depends_on "xz"

  uses_from_macos "zlib"

  on_macos do
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1100
  end

  fails_with :clang do
    build 1100
    cause <<~EOS
      Undefined symbols for architecture x86_64:
        "std::__1::__fs::filesystem::__status(std::__1::__fs::filesystem::path const&, std::__1::error_code*)"
    EOS
  end

  # ver={version} && \
  # curl -s https://raw.githubusercontent.com/mavlink/MAVSDK/v$ver/third_party/mavlink/CMakeLists.txt \
  # | grep 'MAVLINK_GIT_HASH'
  resource "mavlink" do
    url "https://github.com/mavlink/mavlink.git",
        revision: "5e3a42b8f3f53038f2779f9f69bd64767b913bb8"
  end

  def install
    ENV.llvm_clang if OS.mac? && (DevelopmentTools.clang_build_version <= 1100)

    # Fix version being reported as `v#{version}-dirty`
    inreplace "CMakeLists.txt", "OUTPUT_VARIABLE VERSION_STR", "OUTPUT_VARIABLE VERSION_STR_IGNORED"

    # Regenerate files to support newer protobuf
    system "tools/generate_from_protos.sh"

    resource("mavlink").stage do
      system "cmake", "-S", ".", "-B", "build",
                      "-DPython_EXECUTABLE=#{which("python3.13")}",
                      *std_cmake_args(install_prefix: libexec)
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    # Source build adapted from
    # https://mavsdk.mavlink.io/develop/en/contributing/build.html
    args = %W[
      -DSUPERBUILD=OFF
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_MAVSDK_SERVER=ON
      -DBUILD_TESTS=OFF
      -DVERSION_STR=v#{version}-#{tap.user}
      -DCMAKE_PREFIX_PATH=#{libexec}
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # Force use of Clang on Mojave
    ENV.clang if OS.mac?

    (testpath/"test.cpp").write <<~CPP
      #include <iostream>
      #include <mavsdk/mavsdk.h>
      using namespace mavsdk;
      int main() {
          Mavsdk mavsdk{Mavsdk::Configuration{ComponentType::GroundStation}};
          std::cout << mavsdk.version() << std::endl;
          return 0;
      }
    CPP
    system ENV.cxx, "-std=c++17", testpath/"test.cpp", "-o", "test",
                    "-I#{include}", "-L#{lib}", "-lmavsdk"
    assert_match "v#{version}-#{tap.user}", shell_output("./test").chomp

    assert_equal "Usage: #{bin}/mavsdk_server [Options] [Connection URL]",
                 shell_output("#{bin}/mavsdk_server --help").split("\n").first
  end
end
