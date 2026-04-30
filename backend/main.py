# main.py
from src import beatMaker
import os

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))  # gets .../backend
    song_path = os.path.join(base_dir, "..", "assets", "songs")  # only one ..
    song_path = os.path.normpath(song_path)
    
    beatMaker.beatMaker(song_path)

if __name__ == "__main__":
    main()