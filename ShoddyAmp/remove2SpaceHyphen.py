import os

def replace_hyphen_in_filenames(folder_path):
    """Finds '  -  ' in file names and replaces it with ' - '."""
    for filename in os.listdir(folder_path):
        # Check if the filename contains '  -  '
        if '  -  ' in filename:
            # Replace '  -  ' with ' - '
            new_filename = filename.replace('  -  ', ' - ')
            
            old_file_path = os.path.join(folder_path, filename)
            new_file_path = os.path.join(folder_path, new_filename)

            # Rename the file
            os.rename(old_file_path, new_file_path)
            print(f"Renamed: {filename} -> {new_filename}")

# Example usage:
folder_path = '/path/to/your/folder'  # Replace with the path to your folder
replace_hyphen_in_filenames(folder_path)
