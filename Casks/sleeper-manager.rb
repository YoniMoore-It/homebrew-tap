cask "sleeper-manager" do
  version "1.9.24"
  sha256 "4d43ef0eb754c75a5caad6e115a752138e056cbeb37be575e0ccf21a2f211672"

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
