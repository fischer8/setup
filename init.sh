#!/bin/bash
echo -e "\n\n\n\n"
echo " background #171421"
echo " text #2AA1B3"
echo "---------- SSH ----------"
echo -e "\n\n\n\n"

read -p "pass:  " PASS
ssh-keygen -t ed25519 -C "$PASS"

eval "$(ssh-agent -s)"

ssh-add $HOME/.ssh/id_ed25519
cat $HOME/.ssh/id_ed25519.pub | xclip -selection clipboard

echo -e "\n\n\n\n"
echo "--  SSH PUB KEY COPIED TO CLIPBOARD  --"
echo "(PRESS ANY KEY TO CONTINUE)"
echo -e "\n\n\n\n"
read -s -n 1

sudo apt update
sudo apt-get update 
sudo apt install curl -y
sudo apt install xclip -y
sudo apt-get install git -y
sudo apt-get install wget -y
sudo apt install parallel -y
sudo apt install build-essential -y
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y

echo -e "\n\n\n\n"
echo "---------- NVM ----------"
echo -e "\n\n\n\n"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  

nvm install node
nvm use node
nvm alias default node

npm install -g --unsafe-perm node-red

echo -e "\n\n\n\n"
echo "---------- APPS ----------"
echo -e "\n\n\n\n"

mkdir -p $HOME/.config/nvim/ $HOME/backup/nvim/ $HOME/obs/remux $HOME/obs/mp4/ $HOME/dev/ $HOME/shotcut/raw/ $HOME/shotcut/mp4/

sudo apt-get purge firefox -y
sudo snap remove firefox
sudo snap remove --purge firefox
sudo rm -rf /etc/firefox/ /usr/lib/firefox/ /usr/lib/firefox-addons/

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim

git clone --depth 1 git@github.com:fischer8/nvim.git $HOME/.config/nvim/

sudo wget -O - https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/DroidSansMono.zip > $HOME/Downloads/DroidSansMono.zip
sudo unzip $HOME/Downloads/DroidSansMono.zip -d /usr/share/fonts/

wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

sudo wget -O - https://cdn.akamai.steamstatic.com/client/installer/steam.deb > $HOME/Downloads/steam.deb
sudo dpkg -i $HOME/Downloads/steam.deb

apps=(
    "sudo apt install --no-install-recommends software-properties-common dirmngr -y"
    "sudo apt install --no-install-recommends r-base -y"
    "sudo apt-get install clang-15 -y"
    "sudo apt install libstdc++-12-dev -y"
    "sudo apt-get install dconf-editor -y"
    "sudo apt install lua5.4 -y"
    "sudo apt install python3 -y"
    "sudo apt install piper -y"
    "sudo apt install gnome-tweaks -y"
    "sudo snap install nvim --classic"
    "sudo snap install audacity"
    "sudo snap install gimp"
    "sudo snap install gthumb-unofficial"
    "sudo snap install chromium"
    "sudo snap install brave"
    "sudo snap install postman"
    "sudo snap install vlc"
    "sudo snap install code --classic"
    "sudo snap install libreoffice"
    "sudo snap install shotcut --classic"
    "sudo snap install thunderbird"
    "sudo snap install obs-studio"
    "sudo snap install kolourpaint"
    "sudo snap install tldr"
)

parallel --jobs 4 ::: "${apps[@]}" 2> err_log.txt

if [ $? -eq 0 ]; then
    echo -e "\n\n\n\n"
    echo "--------- SUCCESS ----------"
    echo -e "\n\n\n\n"
else
    echo -e "\n\n\n\n"
    echo "--------- SOMETHING WENT WRONG ----------"
    echo "SEE err_log.txt"
    echo -e "\n\n\n\n"
    read -s -n 1
fi

echo -e "\n\n\n"
echo "---------- CONFIG ----------"
echo -e "\n\n\n"

gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.mutter center-new-windows true

echo 'param=$1
git add .
git commit -m "$param"
git push -f' | sudo tee /usr/bin/xgit

echo '#!/bin/bash
cp -r ~/.config/nvim/* ~/backup/nvim/
cd ~/.config/nvim/ && xgit nvim' | sudo tee /usr/bin/nvb

echo '#!/bin/bash
file=$1
g++ -g -std=c++20 "$(pwd)/$file" -o "$(pwd)/${file%.*}.c"' | sudo tee /usr/bin/ccc

echo '#!/bin/bash
file=$1
name="${file%.*}"
g++ -g -std=c++20 "$(pwd)/$file" -o "$(pwd)/$name.c"
"./$name.c"' | sudo tee /usr/bin/cc++

echo 'alias vi="nvim"
alias nano="nvim"
alias xc="xclip -selection clipboard"
alias cl="clear"
alias q="exit"
alias tl="tldr"' > $HOME/.bash_aliases

echo "keycode 112 = Home
keycode 117 = End" > $HOME/.keymap.map

echo '
xmodmap ~/.keymap.map

exṕort PS1="\[\e[38;2;0;95;135m\]\w\[\e[0m\]\$ "' >> $HOME/.bashrc

sudo chmod +x ~/.keymap.map ~/.bash_aliases /usr/bin/xgit /usr/bin/nvb /usr/bin/ccc /usr/bin/cc++

sudo ubuntu-drivers autoinstall
source ~/.bashrc

echo -e "\n\n\n"
echo "----- END -----"
echo -e "\n\n\n"
echo " PRESS ANY KEY TO REBOOT "
echo -e "\n\n\n"
read -s -n 1
rm -rf err_log.txt
sudo reboot -f
