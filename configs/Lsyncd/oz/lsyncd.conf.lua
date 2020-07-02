settings {
   logfile = "/var/log/lsyncd/lsyncd.log",
   statusFile = "/var/log/lsyncd/lsyncd.status",
   statusInterval = 20,
   nodaemon   = false
}

sync {
   default.rsyncssh,
   source = "/home/lhensley/Videos/HandBrake-Completed/",
   host = "nuc01.lanehensley.org",
   targetdir = "/mnt/cloteal/Plex/Pool02-1TB/in"
}