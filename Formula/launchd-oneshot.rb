class LaunchdOneshot < Formula
  desc "Add a oneshot launchd jobs"
  homepage "https://github.com/cybertk/launchd-oneshot"
  url "https://github.com/cybertk/launchd-oneshot.git",
    :tag => "v0.0.4",
    :revision => "d683d0856eb760ad30a7f9410a94b6e39a2b83d6"

  head "https://github.com/cybertk/launchd-oneshot.git"

  depends_on "coreutils"

  def install
    bin.install "launchd-oneshot"
  end

  test do
    assert_match /Usage/, shell_output("launchd-oneshot tests/job.sh")
  end
end
