cask "sleeper-manager" do
  version "1.9.24"
  sha256 "d75c23fce290763bfc04827dce5e60033e71f8318fca62700496ba23e1ee6a7e"

  url "https://sleeper.darthworks.io/downloads/sleeper-manager-mac.zip"
  name "Sleeper Manager"
  desc "AI commissioner for Sleeper fantasy football leagues"
  homepage "https://sleeper.darthworks.io"

  app "Sleeper Manager.app"

  zap trash: [
    "~/sleeper-manager",
    "~/Library/Caches/sleeper-manager",
  ]
end
