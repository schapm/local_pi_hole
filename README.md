# Local Pi-Hole

A BASH script to simplify the process of using Pi-Hole on a single computer, as opposed to setting it up across a network.

If `/etc/hosts` exists, it will first create a backup, grab the master blocklist from GitHub and replace your hosts file with the list.

If your hosts file is not stock, the customisations will be lost - but replaceable from the backup (unless the script has been run multiple times).

## Usage
```
git clone https://github.com/schapm/local_pi_hole.git

chmod +x $HOME/local_pi_hole/local_pi_hole.sh
```

The script needs to be run as root to be able to make modifications to the hosts file.

`sudo $HOME/local_pi_hole/local_pi_hole.sh`

## Scheduling
### Crontab
`sudo crontab -e`

```
# local_pi_hole
00 18 * * * $HOME/local_pi_hole/local_pi_hole.sh
```

This crontab will run the script everyday at 18:00.

### Crontab With Logging
```
# local_pi_hole
00 18 * * * $HOME/local_pi_hole/local_pi_hole.sh >> /var/log/local_pi_hole.cron.log 2>&1
```

## License
Licensed under the [GNU GPLv3](LICENSE).
