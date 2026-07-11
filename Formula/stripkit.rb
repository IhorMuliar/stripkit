# Homebrew formula for stripkit.
# To publish: create a repo named IhorMuliar/homebrew-tap, copy this file to its
# Formula/ directory, set `url`/`sha256` to a tagged release tarball, then:
#   brew tap IhorMuliar/tap && brew install stripkit
class Stripkit < Formula
  desc "Strip metadata from images, videos and PDFs (CLI + Finder + watch folder)"
  homepage "https://github.com/IhorMuliar/stripkit"
  url "https://github.com/IhorMuliar/stripkit/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_AFTER_TAGGING_v0.1.0"
  license "MIT"
  version "0.1.0"

  depends_on "exiftool"
  depends_on "ffmpeg"
  depends_on "qpdf"

  def install
    libexec.install "bin", "lib"
    (bin/"stripkit").write_env_script libexec/"bin/stripkit", {}
  end

  test do
    assert_match "stripkit #{version}", shell_output("#{bin}/stripkit version")
  end
end
