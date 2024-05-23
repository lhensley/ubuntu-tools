# Merging Directories with rsync

If the source directory is /source and the target (merged) directory is /target:
```
rsync -[flags] /source/* /target
```

Merging video container directories

Does NOT delete source files. 
```
cd
SOURCE_DIR="/mnt/ext10tb01/plex/TV-Shows/TV-Austin"
TARGET_DIR="/mnt/ext10tb01/plex/dvr-oz"
sudo rsync -aloprtv "$SOURCE_DIR/"* "$TARGET_DIR"
sudo rm -r "$SOURCE_DIR"
sudo chown -R plex:plex "$TARGET_DIR"
sudo find "$TARGET_DIR" -type d -print -exec chmod 775 {} \;
sudo find "$TARGET_DIR" -type f -print -exec chmod 664 {} \;
```

SYNTAX FOR MAKING A TARGET PATH CONFORM TO A SOURCE PATH:
rsync -aloprtvER --delete [source_username@source_host:]/source_path/* [target_username@target_host:]/target_path
