# 0.4.0 : Gloomy Days (Memory Bundle 1) - 11/1/2026

## Songs

- Chase
- Save

- TBA: Planning
- TBA: Ambush
- TBA: Lu

- TBA: Train Getaway (Resolved)
- TBA: Train Wreak (Resolved)
- TBA: Encapture (Resolved)

## Gameplay Related

- All cutscenes had the hud gone and fade back in or visible and fade out

- bro-mental no longer has a flippable idle (Just like the other bruised bro skins)

- First Steps (Resolved) and Shift Around (Resolved) now have faded Beat Monsters

- Every stage that could get optimizations, changes, or fixes has gotten an optimization, change, or fix (You may notice slight differences cuz of this)
    - The Lost Media sky now stays
    - Train Getaway stage has you lower now
    - Train Wreak stage has been modified cause I now have the crowd in one image + reprogrammed the creation of it so yeah
    - The Lost Media stage sky color is now the intended color
    - And more!!!

## Backend

- Stages are now in a class system now!

- The stages for songs are JSON driven now!! ([#6](https://github.com/v207-matty/rhythmWalker/issues/6))
    - Set the "stage" field in your song JSON
    - Stages still hardcoded so uh yeah sories

- Players are now JSON driven and not hardcoded!!
    - Set the "player" field in your song JSON and make sure that player has a graphic and json in "assets/game/players" with that name

- SAVE SHIT HAS BEEN CHANGED ( No conversion, sorry :( )
    - New Path
    - Scores are saved different

## UX

- Now using logarithmic sound curves

- ADDED MOBILE SUPPORT!! (heres stuff that happens when on mobile)
    - [MOBILE] Text gets sized up
    - [MOBILE] Results gets a leave button
    - [MOBILE] Gameplay gets a leave button
    - [MOBILE] Dialogue Scene gets 2 buttons for skipping and proceeding
    - [MOBILE] Freeplay gets a play button
    - [MOBILE] Freeplay layout flips

- Added crash handler

## UI

- Added "Quality Warning" screen that shows up to warn you that the music and gameplay aren't actually that good ([#8](https://github.com/v207-matty/rhythmWalker/issues/8))
    - [WEB] This 'replaces' the Click Anywhere screen

- Added Time Bar

- Freeplay song texts has padding now when not centered
- Gameplay now lets you click the screen to move (the player will move to where your cursor is)
- Freeplay lets you swipe to change selection and volume

- Dialogue Scenes can now have null portraits (they just turn invisible)
- Rephrased Dialogue Scene "ESCAPE to leave" and it is now "ESCAPE to skip"

## Bug Fixes

- Fixed when you have a less than 1 millisecond long song it would still make the entire game scene
- Fixed beat monsters not being able to hit you while the game camera opacity is less then 10%
    - I accidentally used an and operator instead of an or

- Fixed being able to change selection or volume in freeplay while transitioning
- Fixed Scroll Down Chinatown last 2 lines of dialogue being associated with the wrong speaker
- Fixed freeplay crashes relating to null song audio
- Fixed save not saving on crashes
- Fixed Dialogue Portrait loading

# 0.3.2 - 5/25/2026

- Fixed Dialogue Loading
- Added Scroll Down Chinatown (Resolved) dialogue
- Added Bro Mental Skin
- Update Bro Captured, Chinatown Torn & Chinatown Wanted Skin

# 0.3.1 - 5/25/2026

- New Song: Mental

- When saving a song score, the rank will be set to BAD if it's NONE
- [WEB] Visualizers, Song Score, Rank display, and Song Played Display are disabled
- [WEB] Fixed Crashes loading waveforms
- You now get score from beat monsters just being alive
- Songs can add custom freeplay filters now without it having to be in the filters songlist field
- Freeplay Filters now only appear if a song has it

# 0.3.0 - 5/25/2026

- New Song: Scroll Down Chinatown (Resolved)
- New Song: Lost Media
- New Song: Shift Around (Resolved)
- New Song: First Steps (Resolved)

- Added 32bit support
    - Just disables freeplay waveform mass-caching

- Freeplay Update!
    - It's now displayed if you have or haven't played a song through the song text color changing and the text having "(Unplayed)" at the end
    - The song texts have been moved to the right
    - Added Visualizer of the current song to the left side of the screen
    - The song you have selected now plays in the bg
    - Added Filters!
    - Split into 2 segments now
        - Bottom segment is what filter / volume is currently selected
        - Top segment is your score, rank, and the random tip

- The window title has the version now
- Changed file organization
- All Audio files have been compressed via [OptiVorbis](https://optivorbis.github.io/OptiVorbis/)
- All image assets have been compressed via [oxipng](https://github.com/oxipng/oxipng)
- Skipping now turns of all cutscenes properly
- Fixed Transition not playing when an intro cutscene plays
- Added Red Gradient at the top of the screen that is to help when beat monsters spawn
- Freeplay now displays song variations always as follows:
    - Example Variation: "erect" (Displayed: "Erect")
    - Example Variation: "resolved" (Displayed: "Resolved")
- Fixed flicker of the song playing when trying to see if there is dialogue

# 0.2.6 - 5/24/2026

- New Song: Encapture

- Fixed Freeplay Tip Text BG
- The Chinatown Torn skin of Bro now has his eye bruise darken when he's hurt
- Fixed Freeplay Rank Text BG
- You now only go to the results screen when you have a new high score
- Train Wreak ends a few seconds early now
- Fixed Train Getaway sky going ZOOM when leaving
- Fixed beat monsters being able to hit you while the camera is off or has an opacity less then 10%
- Fixed camera-on, cam-on, camera-off, and cam-off song events (Usin the wrong camera lol!)
- Fixed the lack of a transition into gameplay

# 0.2.5 - 5/24/2026

- Added Marcella to Train Wreak BG Crowd (None of yall know who that is hehehe >:))
- Added Results Screen
- Added Score + Rank text to Freeplay!
- Added Song Ranks!
- Added Saving!

# 0.2.4 - 5/24/2026

- New Song: Train Wreak

- Changed App Icon slightly
- You now receive scoring when you're not in a cutscene, when you're not stunned, when monsters are allowed to spawn, and the step rate is more then 0
- The Train Getaway sky gets faster as the song progressed
- Changed Window Title to "Rhythm Walker"

# 0.2.3 - 5/23/2026

- Added Hurt Sound
- Changed "Hits" text to "Hits Taken"
- Added App Icon

# 0.2.2 - 5/23/2026

- New Song: Train Getaway

- You can press ESCAPE to leave gameplay to the freeplay (if not in a cutscene)
- Fixed Scroll Down Chinatown intro cutscene sometimes missing the beat monster

# 0.2.1 - 5/23/2026

- Updates during the transition in gameplay are disabled now for First Steps & Shift Around
- Added Menu UI Sounds by [Nathan Gibson](https://nathangibson.myportfolio.com)

# 0.2.0 - 5/23/2026

- New Song: Scroll Down Chinatown!!
- New Song: Shift Around!

- You can move during the transition in gameplay now
- The Score Text has an outline now
- Beat Monsters can't hurt you if the camera is off or faded below 10% now
- Added Freeplay!
    - You can select songs here, its cool
- Fixed mouse being visible

# 0.1.0 - 5/23/2026

- Demo Release
