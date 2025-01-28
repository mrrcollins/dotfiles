# Service commands


## User

Put service in the `systemd` folder: `sudo mv autossh-tunnel.service /etc/systemd/user/`

Enable and start

systemctl --user enable autossh-tunnel.service
systemctl --user start autossh-tunnel.service
systemctl --user stop autossh-tunnel.service
systemctl --user restart autossh-tunnel.service
