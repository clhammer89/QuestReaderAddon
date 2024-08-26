# WoW - Quest Reader Addon

# Note - This only works with The War Within quests, so far.
World of Warcraft addon that reads quest text using a similar voice as the NPC quest giver. Each quest text dialogue has a generated audio file that was read using an AI voicemodel generated from their in-game audio.

Usage:
If downloading directly, download latest release here https://github.com/clhammer89/wow-questreader/releases and unzip wow-questreader entire folder into your WoW addon folder, generally located at `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns`. After unzipping file, please make sure to rename the wow-questreader-X.X folder to QuestReaderAddon in your `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns` folder.

This will add a "Read Quest" button to the bottom of the quest frame that will read the quest. There are also some Addon options for enabling/disabling the minimap icon and toggling auto-read on or off.

# /Commands:

/qrtoggle

Toggle minimap button

/qrauto

Toggle auto-read on/off


# NOTES/COMING SOON:
 - Only EN language support at the moment, I'll work on additional language support in the future
 - The voice/audio quality isn't great. Due to the sheer number of audio files generated, I wanted to keep the first pass at a minimal size. Better audio quality coming in the future
 - This only covers The War Within quests at the moment, other expansions coming soon.
 - There will be some janky reading of quest text and sub-par voice audio for some of them. I just started throwing this together this week and haven't had a chance to review all audio yet.
 - I'll be adding in Gossip text in the future as well. I'm still working on sourcing this data.


# BUGS
- When auto-play is enabled, quest dialogue read overlaps with npc greeting and sounds horrible
- Settings toggle for minimap doesn't work

# LINKS
 - Project on Curse: https://curseforge.com/wow/addons/wow-questreader
 - Project on Wago: https://addons.wago.io/addons/wow-questreader
 - Project on Github: https://github.com/clhammer89/wow-questreader
 - Donate: https://www.paypal.com/donate/?hosted_button_id=54FT9M5AAV9KG
