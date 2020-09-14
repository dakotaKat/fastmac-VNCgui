#configure.sh NGROK_AUTH_TOKEN TELEGRAM_TOKEN TELEGRAM_CHAT
#let's make some random passwords

USERPASSWORD=$(openssl rand -base64 16)
VNCPASSWORD=$(openssl rand -base64 16)

#Telegram Proof of Life check
chmod +x telegram
./telegram -t $2 -c $3 -M "*$(date)*"$'\n'"macOS VM \`$(hostname)\` is starting up, stand by _(approx 2 minutes)_"

#disable spotlight indexing
sudo mdutil -i off -a

#Create new account
sudo dscl . -create /Users/vncuser
sudo dscl . -create /Users/vncuser UserShell /bin/bash
sudo dscl . -create /Users/vncuser RealName "VNC User"
sudo dscl . -create /Users/vncuser UniqueID 1001
sudo dscl . -create /Users/vncuser PrimaryGroupID 80
sudo dscl . -create /Users/vncuser NFSHomeDirectory /Users/vncuser
sudo dscl . -passwd /Users/vncuser $USERPASSWORD
sudo dscl . -passwd /Users/vncuser $USERPASSWORD
sudo createhomedir -c -u vncuser > /dev/null

#Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 

#VNC password - http://hints.macworld.com/article.php?story=20071103011608872
echo $VNCPASSWORD | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

#Start VNC/reset changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

#install ngrok
brew cask install ngrok

#configure ngrok and start it
ngrok authtoken $1
ngrok tcp 5900 &

sleep 3

./telegram -t $2 -c $3 -M "*$(date)*"$'\n'"macOS VM \`$(hostname)\` is online, VNC is available now at \`$(curl --silent http://127.0.0.1:4040/api/tunnels | jq '.tunnels[0].public_url' | sed 's .\{7\}  ' | tr -d \")\`"$'\n'"*Your password to the* \`VNC User\` *account is* \`$(echo $USERPASSWORD)\`"$'\n'"Your VNC Basic Auth password is \`$(echo $VNCPASSWORD)\`"
