# 🎵 BeatDrop
 
**Creative Coding Assignemnt 2026**
 
BeatDrop is a rhythm game built in Godot 4, inspired by Sound Space and osu!. Notes appear on a 3×3 grid in time with music, and the player hovers their cursor over each note to hit it at the perfect time. The game uses Python-generated beatmaps from audio samples, a procedurally generated hit sound, and a custom osu-style cursor.
 
---
 
## 🎮 How to Play
 
- Notes appear on a 3×3 grid, synced to the song
- Move your mouse cursor over a note as it peaks (no clicking required)
- Hit it at the right moment to score Perfect
- Miss the window and the note turns red
- Your score and combo are displayed
---
 
## 🛠️ Computational Elements
 
- **Audio analysis pipeline** — Python script using `librosa` detects onsets and beats from an MP3/OGG file and outputs a `.json` beatmap with BPM, beat times, and onset times.
- **Procedural hit sound** — Perfect hits trigger a procedurally generated sound.
- **Beatmap loading & note spawning** — JSON is parsed and notes are assigned random grid cells at runtime.
- **Hover-based timing system** — Each note runs its own `_process` loop, checks mouse distance against a circle radius, and judges Perfect/Good/Miss based on the song.
- **Custom cursor** — System cursor hidden, replaced with a drawn ring + dot that follows the mouse.

---
 
## 📁 Project Structure
 
```
res://
├── assets/
│   └── songs/          ← .ogg audio files
├── data/               ← .json beatmaps (Python generated)
├── game_manager/
│   ├── game_runner.gd    ← Game runner (spawning, scoring, beatmap loading)
│   ├── game_runner.tscn  ← Main game scene
│   ├── Note.gd         ← Per-note hover detection and judgment
│   ├── Note.tscn       ← Note scene (circle + approach ring)
│   ├── NoteCircle.gd   ← Draws filled circle note
│   ├── Ring.gd         ← Draws shrinking approach ring
│   └── Cursor.gd       ← Custom cursor
└── backend/
    └── beatMaker.py    ← Python audio analysis script (librosa)
```
 
---
 
## ⚙️ Beatmap Generation
 
Run the Python script on any song to generate a `.json` beatmap:
 
```bash
pip install librosa
python backend/beatMaker.py
```
 
The script outputs:
```json
{
  "bpm": 136.0,
  "duration": 136.42,
  "beats": [...],
  "onsets": [...]
}
```
 
---
 
## 📹 Video Demo
 
[![BeatDrop Demo](https://img.youtube.com/vi/ClK3HOcs7Vo/0.jpg)](https://youtu.be/ClK3HOcs7Vo)
 
---
 
## 🔗 Repository
 
[github.com/aaron-sequeira/BeatDrop-CC26](https://github.com/aaron-sequeira/BeatDrop-CC26)
 
---
 
## 🧰 Built With
 
- [Godot 4.2](https://godotengine.org/)
- [Python 3](https://www.python.org/) + [librosa](https://librosa.org/) for audio analysis