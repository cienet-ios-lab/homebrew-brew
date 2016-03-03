class VirtualBoxRequirement < Requirement
  fatal true

  satisfy { which("VBoxManage") }

  def message; <<-EOS.undent
    "VirtualBox is required to install. Consider `brew install Caskroom/cask/virtualbox`."
    EOS
  end
end

class CiRunnerOsx < Formula
  desc "OS X GitLab CI Runner"
  homepage "http://git.cienetcorp.com/cienet-ios-lab/ci-runner-osx"
  url "git@git.cienetcorp.com:cienet-ios-lab/ci-runner-osx.git",
    :using => :git,
    :tag => "v0.1.0",
    :revision => "c04f8272e39bcee5b0e1c932e95a9c255a47dc39"

  head "git@git.cienetcorp.com:cienet-ios-lab/ci-runner-osx.git", :using => :git, :branch => "master"
  devel do
    url "git@git.cienetcorp.com:cienet-ios-lab/ci-runner-osx.git", :using => :git, :branch => "devel"
  end

  depends_on VirtualBoxRequirement

  # resource "ci-image-xcode71-v20160301.0.vdi" do
  #     # url "http://files.cienetcorp.com/ci-ios-dev-template_0.0.7.ovf"
  #     # sha256 "de2ac72f5d4fae1588df0f21086aec6a83a061d03203628e5addab94444b274b"
  #     # url "http://localhost:8080/test.vdi"
  #     # sha256 "7ad19147e7db9f2ecd7fd7a9c0b35e80b3afb3ec8d8f96748bd576828ef8a160"
  # end

  resource "ci-image-xcode72-v20160301.0.vdi" do
      url "http://files.cienetcorp.com/ci-image-xcode72-v20160301.0.vdi"
      sha256 "343a204c55e47aa8ac7c876d81fc167229521464251338c3af36499b3bba4fb9"
      # url "http://localhost:8080/test2.vdi"
      # sha256 "7ad19147e7db9f2ecd7fd7a9c0b35e80b3afb3ec8d8f96748bd576828ef8a160"
  end

  def install
    images = (prefix/"images")

    images.mkpath # vm images store
    (etc/"ci-runner-osx").mkpath # config store here
    (var/"ci-runner-osx").mkpath # runner workspace
    (var/"log/ci-runner-osx").mkpath # runner logs


    libexec.install "gitlab-ci-multi-runner_wrapper"
    libexec.install "gitlab-ci-multi-runner"
    (etc/"ci-runner-osx").install "insecure_login.key"

    ENV.append_path "PATH", libexec
    system "sh", "cleanup"

    # Install resources with hard link, as they are very big
    # For `resource` API, see https://github.com/Homebrew/homebrew/blob/master/Library/Homebrew/resource.rb
    resources.each do |r|
      image = "#{images}/#{r.name}"

      system "ln", r.fetch, image
      system "sh", "install", image
    end
  end

  def plist; <<-EOS.undent
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd" >
<plist version='1.0'>
<dict>
<key>Label</key><string>gitlab-runner</string>
<key>EnvironmentVariables</key>
<dict>
<key>PATH_DOES_NOT_WORK</key>
<string>/usr/local/bin</string>
</dict>
<key>ProgramArguments</key>
<array>
<string>#{libexec}/gitlab-ci-multi-runner_wrapper</string>
<string>-l</string>
<string>info</string>
<string>run</string>
<string>--working-directory</string>
<string>#{var}/ci-runner-osx</string>
<string>--config</string>
<string>#{etc}/ci-runner-osx/config.toml</string>
<string>--syslog</string>
</array>
<key>SessionCreate</key><true/>
<key>KeepAlive</key><true/>
<key>RunAtLoad</key><true/>
<key>Disabled</key><false/>
<key>StandardOutPath</key>
<string>#{var}/log/ci-runner-osx/gitlab-ci-multi-runner.log</string>
<key>StandardErrorPath</key>
<string>#{var}/log/ci-runner-osx/gitlab-ci-multi-runner.log</string>
</dict>
</plist>
    EOS
  end

  test do
    assert_match /gitlab-ci-multi-runner version #{version}/, shell_output("gitlab-ci-multi-runner --version")
  end
end
