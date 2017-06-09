# openconnect-ns
systemd units and config templates to start OpenConnect as a non-root inside a namespace

# Notes
This approach is not compatible with systemd-networkd. You need to remove "resolve" from /etc/nsswitch.conf to stop using systemd-networkd to have DNS working inside namespace, as well as not have 127.0.0.53 in /etc/resolv.conf. It might as well make sense to stop & disable systemd-networkd. You need to use vpnc-script which is not aware of systemd-networkd (shipped with vpnc as of May 2017), modified versions which communicate with systemd-networkd will fail (such as patched script from openconnect vpnc-scripts repo), you may need to modify such script to use resolvconf instead. The "netns@.service" unit ensures that a separate resolve.conf is used inside the namespace, allowing DNS to work as expected both inside VPN and outside VPN.

# Usage
1. Put files into `/etc`: `cp -r etc/* /etc`.
2. Rename all files with `example` by replacing `example` with a desired name for the VPN connection. You will use this new name to start the unit. I will use `myconn` in this readme.
3. Modify `/etc/openconnect/myconn.conf`, `/etc/openconnect/myconn.systemd-env` and `/etc/netns-veth.myconn.systemd-env` to match your VPN configuration and system environment. `/etc/netns-veth.myconn.systemd-env` is used for veth setup, make sure the IPs and netmask there do not collide with your local or VPN networks.
4. Ensure that the user defined in `/etc/openconnect/myconn.systemd-env` has automatic passwordless token generation properly configured (for ex. if using stoken, ensure that ~/.stokenrc is present and that `stoken` does not request a password or PIN) and that tokentype is correct in `/etc/openconnect/myconn.conf` (`tokentype=rsa` will use stoken)
5. Use visudo to allow your user to run `/etc/vpnc/vpnc-script` (or any other script defined in `/etc/openconnect/myconn.conf` in `script=` line) without password and with allowed -E option. Add: `%sudo   ALL=(ALL) NOPASSWD:SETENV: /etc/vpnc/vpnc-script`
6. `# sudo systemctl daemon-reload`
7. `# sudo systemctl start openconnect-ns@myconn`
8. Check that everything works - you should have `myconn` in output of "# ip netns", and you should have openconnect running inside this namespace. You should be able to access VPN resources from a console started like so `ip netns exec myconn bash`. You can use https://github.com/f3flight/netns-exec to spawn broswer or other apps inside this namespace.
9. Use `# sudo systemctl enable openconnect-ns@myconn` to start this VPN automatically at boot, if desired.
10. Enjoy.

# Start a shell with VPN access as a current user:
`sudo ip netns exec myconn sudo -u $(whoami) -i`
or
`netns-exec myconn bash` if https://github.com/f3flight/netns-exec is installed (uses sticky bit to execute as root).

# Start a separate window of Chromium inside namespace:
1. Install https://github.com/f3flight/netns-exec which helps passing dbus into namepsace.
2. Create a new folder for user data. Chromium cannot reuse the same user folder.
3. It is possible to copy current user data dir to retain configuration, but syncronisation of these folders my be a problem.
4. `nohup netns-exec myconn chromium --user-data-dir=/home/myuser/my-new-chromium-data-dir &`
