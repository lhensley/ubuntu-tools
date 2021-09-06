# Making New SSH Client Keys
1. For Linux host (adam, nuc01, oz), ssh to the host.
	a. Run ```ssh-keygen -C "nuc01 2021-09-05"``` (with appropriate comment/name in the quotes) and accept the defaults, overwriting the old key, with no passphrase.
	b. Run ```cat ~/.ssh/id_rsa.pub```, copy the output to the clipboard, and add it to the ```go/configs/ssh/home-.ssh-authorized_keys``` file in Microsoft Visual Studio. It will be propogated on the next run of ```upd``` from each host. DO NOT CLEAN UP THE FILE YET. It's best not to comment out or remove the old keys until testing of the new keys is completed.
	d. Exit.
2. For each Windows computer (L10), load the ```puttygen``` app (download if needed at https://www.puttygen.com/).
	a. Generate a key pair using default settings.
	b. Update key comment to something like ```L10 2021-09-05```, and leave passphrases blank.
	c. Select and copy the full text of the large window in ```puttygen``` labeled ```Public key for pasting into OpenSSH authorized_keys file:```, and add it to the ```go/configs/ssh/home-.ssh-authorized_keys``` file. It will be propogated on the next run of ```upd``` from each host.  NOT CLEAN UP THE FILE YET. It's best not to comment out or remove the old keys until testing of the new keys is completed.
	d. Press the ```Save Private Key``` button and save it without a passphrase to ```OneDrive\Keys``` with a name like ```L10 2021-09-05.ppk```.
3. For portable device (phone and tablets), load the ```SSH Term Pro``` app.
	a. Select the key manager (key icon in lower right) and choose ```Create new key```.
	b. Enter a key name like ```Lane's iPhone 12 2021-09-05``` and press ```Done```.
	c. Click the newly created key and choose ```Copy (Public Key) to Clipboard```.
	d. Paste the clipboard into an email to yourself with the device description as subject. OPTIONAL (recommended): Add a comment at the end like ```Lane's iPhone 12 2021-09-05```, separated from the key itself by at least one space character, and press ```Done```. Close Key Manager.
	e. Receive the email on your Windows computer, and add the key to the ```go/configs/ssh/home-.ssh-authorized_keys``` file in Microsoft Visual Studio. It will be propogated on the next run of ```upd``` from each host.  NOT CLEAN UP THE FILE YET. It's best not to comment out or remove the old keys until testing of the new keys is completed.
4. For Brother ACS-2700W Scanner, figure it out, and document it here.
5. Save and push ```go/configs/ssh/home-.ssh-authorized_keys``` in Microsoft Visual Studio to github.
6. For each ssh server (Linux hosts, mostly),
	a. Log in from Windows and don't jump box-to-box.
	b. Run ```sudo upd```. Newly created public keys recognized will be loaded. 
	c. Exit.
7. For each Windows computer (L10),
	a. Load ```putty```, load each session,
	b. Edit ```Connection / SSH / Auth```.
	c. Choose the ```.ppk``` file above. 
	d. Return to ```Session```, and press the ```Save``` button. 
	e. Exit.
8. For portable device (phone and tablets), 
	a. Load the ```SSH Term Pro``` app.
	b. Open each host entry and update the key to the one you just created.
9. Clean out ```go/configs/ssh/home-.ssh-authorized_keys``` in Microsoft Visual Studio.
	a. Get rid of old and unused keys.
	b. Save and push to github.
10. For each ssh server (Linux hosts, mostly),
	a. Log in from Windows and don't jump box-to-box.
	b. Run ```sudo upd```. Newly edited ```.ssh/authorized_keys``` will be loaded. 
	c. Exit.
