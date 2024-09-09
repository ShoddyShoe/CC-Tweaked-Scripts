import os
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

# Spotipy will read you client id and secret from the environment variables 
# Add these to your bashrc or zshrc file:
#
# export SPOTIPY_CLIENT_ID='your_spotify_client_id'
# export SPOTIPY_CLIENT_SECRET='your_spotify_client_secret'
#
# Or on windows, run these commands in powershell:
# 
# setx SPOTIPY_CLIENT_ID "your_spotify_client_id"
# setx SPOTIPY_CLIENT_SECRET "your_spotify_client_secret"
folder_path = ''  # Replace with the path to your folder

sp = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials())

def get_song_author(song_name):
    results = sp.search(q=song_name, limit=1, type='track')
    if results['tracks']['items']:
        track = results['tracks']['items'][0]
        artist_name = track['artists'][0]['name']
        return artist_name
    return None

def rename_files_in_folder(folder_path):
    for filename in os.listdir(folder_path):
        if filename.endswith('.nbs'):
            song_name = filename[:-4]
            if '-' in song_name:
                print(f"Skipping file (already has a hyphen): {filename}")
                continue

            artist = get_song_author(song_name)
            if artist:
                artist = artist.replace('/', '\\')

                new_filename = f"{artist}  -  {song_name}.nbs"
                old_file_path = os.path.join(folder_path, filename)
                new_file_path = os.path.join(folder_path, new_filename)

                os.rename(old_file_path, new_file_path)
                print(f"Renamed: {filename} -> {new_filename}")
            else:
                print(f"Artist not found for: {song_name}")
rename_files_in_folder(folder_path)
