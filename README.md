# WoW - Quest Reader

# Note - This only works with The War Within quests, so far.
World of Warcraft addon that reads quest text using a similar voice as the NPC quest giver. Each quest text dialogue has a generated audio file that was read using an AI voicemodel generated from their in-game audio.

Usage:
If downloading directly, download latest release here https://github.com/clhammer89/wow-questreader/releases and unzip wow-questreader entire folder into your WoW addon folder, generally located at `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns`

This will add a "Read Quest" button to the bottom of the quest frame that will read the quest. There are also some Addon options for enabling/disabling the minimap icon and toggling auto-read on or off.

If you are using a quest UI addon like Immersion make sure to turn auto-play on. Test

# /Commands:

/qrtoggle

Toggle minimap button

/qrauto

Toggle auto-read on/off


# NOTES/COMING SOON:
 - Only EN language support at the moment, I'll work on additional language support in the future
 - The voice/audio quality isn't great. Due to the sheer number of audio files generated, I wanted to keep the first pass at a minimal size. Better audio quality coming in the future
 - This only covers The War Within quests at the moment, other expansions coming soon.
 - There will be some janky reading of quest text and sub-par voice audio for some of them. I'll be working on improving this in the future.
 - I'll be adding in Gossip text in the future as well. I'm still working on sourcing this data.


# BUGS
 - Missing quests. If you receive "Quest sound file not found: " or "Failed to play audio: " the quest is missing. Feel free to shoot me a comment with the missing quest ID and I'll add it to the list. 
 - Missing quests cont. The source I utilize for quest info can sometimes take several days before it has complete info. I try to source new quests every day, so if one is missing it may be added the next.

# SHOUT OUTS AND THANKS
 - Shout out to Curseforge user Paratusjv for providing an update that provided additional stop functionality and support for quest UI addons! 
 - Everyone who has provided feedback and support! Thank you HAQ!
 
# LINKS
 - Project on Curse: https://curseforge.com/wow/addons/wow-questreader
 - Project on Wago: https://addons.wago.io/addons/wow-questreader
 - Project on Github: https://github.com/clhammer89/wow-questreader
 - Donate: https://www.paypal.com/donate/?hosted_button_id=54FT9M5AAV9KG
