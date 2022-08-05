settings {
	logfile = "/var/log/lsyncd/lsyncd.log",
	statusFile = "/var/log/lsyncd/lsyncd.status",
	statusInterval = 20,
	nodaemon = false
}

--[[
sync {
	default.rsyncssh,
	source = "/home/$ADMIN_USER/to/nuc01",
	host = "nuc01.lanehensley.org",
	targetdir = "/home/$ADMIN_USER/from/oz",
	rsync = { rsh = "ssh -l $ADMIN_USER -i /home/$ADMIN_USER/.ssh/id_rsa -o UserKnownHostsFile=/home/$ADMIN_USER/.ssh/known_hosts -o User=$ADMIN_USER" }
}
--]]

sync {
	default.rsyncssh,
	source = "/home/$ADMIN_USER/Videos/HandBrake-Completed",
	host = "nuc01.lanehensley.org",
	targetdir = "/mnt/cloteal/Plex/Pool02-1TB/in/",
	rsync = { rsh = "ssh -l $ADMIN_USER -i /home/$ADMIN_USER/.ssh/id_rsa -o UserKnownHostsFile=/home/$ADMIN_USER/.ssh/known_hosts -o User=$ADMIN_USER" }
}
