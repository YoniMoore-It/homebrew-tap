cask "sleeper-manager" do
  version "1.9.24"
  sha256 "1676d0e1332140963635bdfcd79a97957c9995a2d22ba8102394ba904167df73"

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
