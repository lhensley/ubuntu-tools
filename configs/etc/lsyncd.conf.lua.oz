settings {
	logfile = "/var/log/lsyncd/lsyncd.log",
	statusFile = "/var/log/lsyncd/lsyncd.status",
	statusInterval = 20,
	nodaemon = false
}

--[[
sync {
	default.rsyncssh,
	source = "/home/lhensley/to/nuc01",
	host = "nuc01.lanehensley.org",
	targetdir = "/home/lhensley/from/oz",
	rsync = { rsh = "ssh -l lhensley -i /home/lhensley/.ssh/id_rsa -o UserKnownHostsFile=/home/lhensley/.ssh/known_hosts -o User=lhensley" }
}
--]]

sync {
	default.rsyncssh,
	source = "/home/lhensley/Videos/HandBrake-Completed",
	host = "nuc01.lanehensley.org",
	targetdir = "/mnt/cloteal/Plex/Pool02-1TB/in/",
	rsync = { rsh = "ssh -l lhensley -i /home/lhensley/.ssh/id_rsa -o UserKnownHostsFile=/home/lhensley/.ssh/known_hosts -o User=lhensley" }
}
