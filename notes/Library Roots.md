# Library Roots
```
oz
  /mnt/ssd1tb/plex/Movies (empty) [Movies Library]
  /mnt/ssd1tb/plex/TV-Austin [TV Austin Library]
  /mnt/ext10tb01/MakeMKV-Completed
  /mnt/ext10tb01/TV-Austin-2020-09-20-Uncompressed-TS-Files
  /mnt/ext10tb01/plex/Movies (empty) [Movies Library]
  /mnt/ext10tb01/plex/TV-Austin [TV Austin Library]
  /mnt/ext10tb01/plex/TV-DSM (empty)
  /mnt/ext10tb01/plex/TV-Shows/TV-Austin
  /mnt/ext10tb01/plex/TV-Shows/TV-Austin-2020-09-20-Uncompressed-TS-Files
  /mnt/ext10tb01/plex/TV-Shows/TV-Shows-DVR
  /mnt/ext10tb01/plex/TV-Shows/TV-Shows-DVR/TV-Austin (empty)
  /mnt/ext10tb01/plex/TV-Shows/TV-Shows-DVR/TV-DSM (empty)
  /mnt/ext10tb01/Zoom
  /mnt/ext10tb01/ZoomTranscoded (flat)
pd1
  /mnt/cloteal/Plex/Pool01-1TB/TV-Shows/TV-Shows-Regular [TV Shows Library]
  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Austin [TV Shows Library]
  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Austin-2020-09-20-Uncompressed-TS-Files [TV Shows Library]
  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Shows-DVR [TV Shows Library]
  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Shows-DVR/mnt/ssd1tb/plex/TV-Austin
  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Shows-DVR/TV-Austin
  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Shows-DVR/TV-DSM
  /var/lib/plexmediaserver/Library/work/TV-DSM [TV Shows, TV Des Moines Library]

Changes

pd1
  Merge  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Austin-2020-09-20-Uncompressed-TS-Files [TV Shows Library]
    into /mnt/ext10tb01/plex/TV-Shows/Uncompressed on oz
  Create /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/DVR (add to TV Shows Library)
  Merge  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Austin [TV Shows Library]
    into /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/tv
  Merge  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Shows-DVR/mnt/ssd1tb/plex/TV-Austin
    into /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/tv
  Merge  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Shows-DVR/TV-Austin
    into /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/tv
  Merge  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Shows-DVR/TV-DSM
    into /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/tv
  Merge  /mnt/cloteal/Plex/Pool06-1TB/TV-Shows/TV-Shows-DVR [TV Shows Library]
    into /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/tv
oz
  Rename  /mnt/ssd1tb/plex/TV-Austin [TV Austin Library] (rename dvr-oz): pre-transcode
  Rename  /mnt/ext10tb01/TV-Austin-2020-09-20-Uncompressed-TS-Files
    as    /mnt/ext10tb01/plex/TV-Shows/ts
    and   Add to TV Austin Library
  Rename  /mnt/ext10tb01/plex/TV-Austin [TV Austin Library] (rename dvr-oz)
  Drop    /mnt/ext10tb01/plex/TV-DSM (empty)
  Merge   /mnt/ext10tb01/plex/TV-Shows/TV-Austin
    into  /mnt/ext10tb01/plex/TV-Austin (dvr-oz)
  Merge   /mnt/ext10tb01/plex/TV-Shows/TV-Austin-2020-09-20-Uncompressed-TS-Files
    into  /mnt/ext10tb01/plex/TV-Shows/ts
  Drop    /mnt/ext10tb01/plex/TV-Shows/TV-Shows-DVR/TV-Austin (empty)
  Drop    /mnt/ext10tb01/plex/TV-Shows/TV-Shows-DVR/TV-DSM (empty)
  Merge   /mnt/ext10tb01/plex/TV-Shows/TV-Shows-DVR
    into  /mnt/ext10tb01/plex/TV-Austin (dvr-oz)

New Configuration

oz
  /mnt/ssd1tb/plex/dvr-oz/movies
  /mnt/ssd1tb/plex/dvr-oz/tv
  /mnt/ext10tb01/plex/dvr-oz/movies
  /mnt/ext10tb01/plex/dvr-oz/tv
  /mnt/ext10tb01/Zoom
  /mnt/ext10tb01/ZoomTranscoded (flat)
pd1
  /var/lib/plexmediaserver/Library/dvr-pd1/movies
  /var/lib/plexmediaserver/Library/dvr-pd1/tv
  /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/movies
  /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/movies-ts
  /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/tv
  /mnt/cloteal/Plex/Pool06-1TB/dvr-pd1/tv-ts

