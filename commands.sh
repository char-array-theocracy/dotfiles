#!/bin/sh

username=$(id -u -n 1000)
builddir=$(pwd)

########################################
# System Update and Basic Setup
########################################
echo "Updating system and configuring basic environment..."
xbps-install -Suy
cd "$builddir"

echo "Creating necessary directories and adjusting permissions..."
mkdir -p /home/$username/Screenshots/temp
mkdir -p /home/$username/.config
chown -R $username:$username /home/$username

########################################
# Dotfiles and Shell Config
########################################
echo "Linking user dotfiles..."
rm -f /home/$username/.bashrc /home/$username/.bash_profile
ln -s /home/$username/dotfiles/bashrc /home/$username/.bashrc
ln -s /home/$username/dotfiles/river /home/$username/.config/
ln -s /home/$username/dotfiles/foot /home/$username/.config/
ln -s /home/$username/dotfiles/mako /home/$username/.config/
ln -s /home/$username/dotfiles/nvim /home/$username/.config/
ln -s /home/$username/dotfiles/kanshi /home/$username/.config/
ln -s /home/$username/dotfiles/fastfetch /home/$username/.config/
ln -s /home/$username/dotfiles/zathura /home/$username/.config/
ln -s /home/$username/dotfiles/bash_profile /home/$username/.bash_profile

########################################
# Theming and UI Fixes
########################################
echo "Fixing pavucontrol theming..."
ln -s /home/$username/dotfiles/gtk-3.0 /home/$username/.config/
ln -s /home/$username/dotfiles/gtk-3.0 /home/$username/.config/gtk-4.0
chown -R $username:$username /home/$username/.config/gtk-{3.0,4.0}

########################################
# Installing Base System Packages
########################################
echo "Installing base system packages..."
xbps-install -Sy clang-tools-extra river fzf mako libevdev wayland wayland-protocols wlroots libxkbcommon-devel dbus elogind polkit pixman mesa-dri vulkan-loader mesa-vulkan-radeon mesa-vaapi mesa-vdpau xf86-video-amdgpu \
  curl mpd flatpak pipewire wireplumber libspa-bluetooth neovim Adapta papirus-icon-theme pavucontrol network-manager-applet wl-clipboard ffmpeg yt-dlp wget nerd-fonts font-awesome6 lxappearance gvfs nemo setxkbmap kanshi ImageMagick \
  ufw mate-polkit xorg-fonts fonts-roboto-ttf foot grim chromium base-devel bluez xdg-desktop-portal-gtk lm_sensors neofetch btop xbacklight libnotify fastfetch slurp swappy eog zathura zathura-pdf-mupdf zathura-ps zathura-djvu \
  libvirt virt-manager virt-manager-tools qemu inotify-tools vscode acpi swaylock swayidle swww

########################################
# Service Management
########################################
echo "Linking necessary services..."
ln -s /etc/sv/dbus /var/service/

# Virtualization services
ln -s /etc/sv/libvirtd /var/service/
ln -s /etc/sv/virtlockd /var/service/
ln -s /etc/sv/virtlogd /var/service/

# Other essential services
ln -s /etc/sv/polkitd /var/service/
ln -s /etc/sv/bluetoothd /var/service/

########################################
# Flatpaks and Integration
########################################
echo "Setting up flatpaks..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.openhantek.OpenHantek6022 net.ankiweb.Anki com.github.tchx84.Flatseal

echo "Linking flatpak binaries to system PATH..."
ln -s /var/lib/flatpak/exports/bin/net.ankiweb.Anki /usr/bin/anki
ln -s /var/lib/flatpak/exports/bin/com.github.tchx84.Flatseal /usr/bin/flatseal
ln -s /var/lib/flatpak/exports/bin/org.openhantek.OpenHantek6022 /usr/bin/hantek

echo "Configuring Wayland environment for Hantek flatpak..."
flatpak override --user --env=QT_QPA_PLATFORM=wayland org.openhantek.OpenHantek6022

# OpenHantek6022 udev rule
echo "Applying OpenHantek6022 udev rules..."
mkdir -p /etc/udev/rules.d/
cp /home/$username/dotfiles/resources/60-openhantek.rules /etc/udev/rules.d/

echo "Forcing Wayland sockets on all flatpak apps..."
sed -i 's|exec /usr/bin/flatpak run|exec /usr/bin/flatpak run --socket=wayland|g' /var/lib/flatpak/exports/bin/*

########################################
# Fonts and Bitmaps
########################################
echo "Disabling bitmap fonts..."
ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
xbps-reconfigure -f fontconfig

########################################
# Hardware Specific Fixes
########################################
echo "Configuring backlight fix..."
echo "%video ALL=(ALL) NOPASSWD: /usr/bin/xbacklight" >> /etc/sudoers

########################################
# Pipewire Configuration
########################################
echo "Setting up pipewire configurations..."
mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

########################################
# Firewall Setup
########################################
echo "Configuring firewall with ufw..."
ufw limit 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw default deny incoming
ufw default allow outgoing
ufw enable
ln -s /etc/sv/ufw /var/service/

echo "Denying all incoming SSH connections..."
touch /etc/hosts.deny
echo "sshd: ALL" >> /etc/hosts.deny

########################################
# Power Management with TLP
########################################
echo "Installing and configuring TLP..."
xbps-install -Sy tlp tlp-rdw smartmontools ethtool
rm -f /etc/tlp.conf
ln -s /home/$username/dotfiles/tlp.conf /etc/
tlp start
ln -s /etc/sv/tlp /var/service/

########################################
# Swap and Hibernation
########################################
echo "Creating and initializing swapfile..."
btrfs subvolume create /var/swap
truncate -s 0 /var/swap/swapfile
chattr +C /var/swap/swapfile
btrfs property set /var/swap compression none
chmod 600 /var/swap/swapfile
dd if=/dev/zero of=/var/swap/swapfile bs=1G count=20 status=progress
mkswap /var/swap/swapfile
swapon /var/swap/swapfile
echo "/var/swap/swapfile none swap sw 0 0" >> /etc/fstab

echo "Setting up hibernation resume parameters..."
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/luks*)
resume_offset=$(btrfs inspect-internal map-swapfile -r /var/swap/swapfile)
sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ resume=UUID=$ROOT_UUID resume_offset=$resume_offset\"/" /etc/default/grub
update-grub

########################################
# AMD Optimizations
########################################
echo "Adding AMD optimizations to GRUB..."
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ radeon.dpm=1 amd_pstate=disable"/' /etc/default/grub
update-grub

########################################
# Virtualization User Group Membership
########################################
echo "Adding $username to libvirt and kvm groups..."
usermod -aG libvirt,kvm $username

########################################
# VM Networking Configuration
########################################
echo "Disabling default libvirt network to avoid conflicts..."
virsh net-destroy default || true
virsh net-autostart default --disable || true

echo "Enabling and configuring NetworkManager..."
xbps-install -Sy NetworkManager iproute2 dhclient
ln -s /etc/sv/NetworkManager /var/service/

echo "Waiting for NetworkManager to initialize..."
sleep 5

echo "Setting up macvtap0 interface on wlp3s0 for VM networking..."
nmcli connection add type macvlan ifname macvtap0 con-name macvtap0 dev wlp3s0 mode bridge tap yes
nmcli connection modify macvtap0 ipv4.method auto
nmcli connection modify macvtap0 ipv6.method ignore
nmcli connection up macvtap0

########################################
# Additional Security & Stability
########################################
echo "Applying additional security measures..."

# Network Hardening via sysctl
echo "Hardening network settings with sysctl..."
mkdir -p /etc/sysctl.d
cat <<EOF > /etc/sysctl.d/99-security.conf
# Ignore ICMP broadcast requests (prevent smurf attacks)
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Enable IP spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable IP source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Disable secure redirects
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Log martians
net.ipv4.conf.all.log_martians = 1

# Enable TCP SYN cookies (prevent SYN flood DoS)
net.ipv4.tcp_syncookies = 1
EOF
sysctl --system

# Fail2Ban for intrusion prevention
echo "Installing fail2ban..."
xbps-install -Sy fail2ban
ln -s /etc/sv/fail2ban /var/service/ || true

# Time Synchronization for Stability with chrony
echo "Installing chrony for time synchronization..."
xbps-install -Sy chrony
ln -s /etc/sv/chronyd /var/service/ || true

# AMD Microcode Updates
echo "Installing AMD microcode updates..."
xbps-install -Sy amd-ucode
update-grub

echo "Additional security measures applied."

########################################
# VM Performance Tweaks
########################################
echo "Enabling hugepages for better VM performance..."
echo "vm.nr_hugepages=1024" >> /etc/sysctl.conf
sysctl -p

echo "Restarting libvirtd to apply changes..."
sv restart libvirtd

########################################
# Autologin Setup (Last Step)
########################################
echo "Setting up autologin on tty1..."
SERVICE_NAME="agetty-tty1"
AUTOLOGIN_SERVICE_NAME="agetty-autologin-tty1"
CONF_FILE="/etc/sv/${AUTOLOGIN_SERVICE_NAME}/conf"

cp -R /etc/sv/${SERVICE_NAME} /etc/sv/${AUTOLOGIN_SERVICE_NAME}
mkdir -p $(dirname $CONF_FILE)

cat <<EOF > "$CONF_FILE"
if [ -x /sbin/agetty -o -x /bin/agetty ]; then
        # util-linux specific settings
        if [ "\${tty}" = "tty1" ]; then
                GETTY_ARGS="--autologin $username --noclear"
        fi
fi

BAUD_RATE=38400
TERM_NAME=linux
EOF

rm -f /var/service/${SERVICE_NAME}
ln -s /etc/sv/${AUTOLOGIN_SERVICE_NAME} /var/service/

########################################
# Reboot Immediately
########################################
echo "Setup complete. Rebooting now..."
reboot
