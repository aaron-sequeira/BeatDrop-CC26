import librosa
import json
import os

def beatMaker(song_path):
    """
    Args:
        song_path (str): path to folder that contains MP3 song files
    """
    
    base_dir = os.path.dirname(os.path.abspath(__file__))
    data_dir = os.path.normpath(os.path.join(base_dir, "..", "..", "data"))

    # Create data folder if it doesn't exist
    os.makedirs(data_dir, exist_ok=True)

    for song in os.listdir(song_path):
        if song.endswith(".mp3"):
            full_path = os.path.join(song_path, song)
            
            y, sr = librosa.load(full_path)

            tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
            beat_times = librosa.frames_to_time(beat_frames, sr=sr)

            onset_frames = librosa.onset.onset_detect(y=y, sr=sr)
            onset_times = librosa.frames_to_time(onset_frames, sr=sr)

            data = {
                "bpm": float(tempo[0]),
                "beats": beat_times.tolist(),
                "onsets": onset_times.tolist()
            }

            json_filename = os.path.splitext(song)[0] + ".json"  # song.mp3 → song.json
            json_path = os.path.join(data_dir, json_filename)

            with open(json_path, "w") as f:
                json.dump(data, f)

            print(f"[LOG] created {json_path}")
            print(f"BPM: {float(tempo[0]):.1f}, Found {len(beat_times)} beats, {len(onset_times)} onsets")