cask "sleeper-manager" do
  version "1.0.0"
  sha256 :no_check

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
