cask "sleeper-manager" do
  version "1.9.6"
  sha256 "299b51272e035a39771457641b6d3fd86f1d55eb4b4989bdda83ffd8007ca879"

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
