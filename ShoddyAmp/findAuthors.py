import os
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import lyricsgenius

# Spotipy will read your client id and secret from the environment variables
# Genius will read your access token from the environment variables
# Add these to your bashrc or zshrc file:
#
# export SPOTIPY_CLIENT_ID='your_spotify_client_id'
# export SPOTIPY_CLIENT_SECRET='your_spotify_client_secret'
# export GENIUS_ACCESS_TOKEN='your_genius_access_token'
#
# Or on windows, run these commands in powershell:
#
# setx SPOTIPY_CLIENT_ID "your_spotify_client_id"
# setx SPOTIPY_CLIENT_SECRET "your_spotify_client_secret"
# setx GENIUS_ACCESS_TOKEN "your_genius_access_token"

folder_path = ''  # Replace with the path to your folder

# Initialize Spotify and Genius API clients
sp = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials())
genius = lyricsgenius.Genius(os.getenv("GENIUS_ACCESS_TOKEN"))

def get_song_author(song_name):
    results = sp.search(q=song_name, limit=1, type='track')
    if results['tracks']['items']:
        track = results['tracks']['items'][0]
        artist_name = track['artists'][0]['name']
        return artist_name
    return None

def get_song_lyrics(song_name, artist_name):
    try:
        # Search for the song on Genius
        song = genius.search_song(song_name, artist_name)
        if song:
            return song.lyrics
        else:
            print(f"Lyrics not found for: {song_name}")
            return None
    except Exception as e:
        print(f"Error fetching lyrics: {e}")
        return None

def rename_files_and_save_lyrics(folder_path):
    for filename in os.listdir(folder_path):
        if filename.endswith('.nbs'):
            song_name = filename[:-4]
            if '-' in song_name:
                print(f"Skipping file (already has a hyphen): {filename}")
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

            # Get lyrics and save them to a .txt file
            lyrics = get_song_lyrics(song_name, artist)
            if lyrics:
                txt_filename = new_filename.replace('.nbs', '.txt')
                txt_file_path = os.path.join(folder_path, txt_filename)
                with open(txt_file_path, 'w', encoding='utf-8') as txt_file:
                    txt_file.write(lyrics)
                print(f"Lyrics saved to: {txt_filename}")
            else:
                print(f"No lyrics found for: {song_name}")


# Call the function
rename_files_and_save_lyrics(folder_path)
