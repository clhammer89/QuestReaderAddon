# WoW - Quest Reader

**Note:** This only works with *The War Within* quests, so far.  
World of Warcraft addon that reads quest text using a similar voice as the NPC quest giver. Each quest text dialogue has a generated audio file that was read using an AI voice model generated from their in-game audio.

## Usage:

If downloading directly from GitHub, download the latest release [here](https://github.com/clhammer89/QuestReaderAddon/releases) and unzip the `wow-questreader` entire folder into your WoW addon folder, generally located at `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns`.

After unzipping the file, please make sure to rename the `QuestReaderAddon-X.X` folder to `QuestReaderAddon` in your `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns` folder.

## Commands:

- **/qrtoggle**  
  Toggle minimap button

- **/qrauto**  
  Toggle auto-read on/off

## Notes/Coming Soon:

- Only EN language support at the moment, additional language support is planned for the future.
- The voice/audio quality isn't great. Due to the sheer number of audio files generated, the first pass was kept at a minimal size. Better audio quality is coming in the future.
- This only covers *The War Within* quests at the moment, with other expansions coming soon.
- There may be some janky reading of quest text and sub-par voice audio for some quests. This project is in its early stages, and not all audio has been reviewed yet.
- Gossip text support will be added in the future as well. I'm still working on sourcing this data.

## Bugs:

- When auto-play is enabled, quest dialogue read overlaps with NPC greeting and sounds unpleasant.
- The settings toggle for the minimap doesn't work.

## Links:

- [Project on Curse](https://www.curseforge.com/wow/addons/questreaderaddon)
- [Project on Wago](https://addons.wago.io/addons/questreaderaddon)
- [Project on Github](https://github.com/clhammer89/questreaderaddon)
- [Donate](https://www.paypal.com/donate/?hosted_button_id=54FT9M5AAV9KG)