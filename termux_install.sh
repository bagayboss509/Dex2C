if ! command -v termux-setup-storage; then
  echo "This script can be executed only on Termux"
  exit 1
fi

termux-setup-storage

cd $HOME

pkg update
pkg upgrade -y
pkg i -y ncurses-utils

green="$(tput setaf 2)"
nocolor="$(tput sgr0)"
red="$(tput setaf 1)"
blue="$(tput setaf 32)"
yellow="$(tput setaf 3)"
note="$(tput setaf 6)"

echo "${green}━━━ Basic Requirements Setup ━━━${nocolor}"

pkg install -y python git cmake rust clang make wget ndk-sysroot zlib libxml2 libxslt pkg-config libjpeg-turbo build-essential binutils openssl openjdk-17
# UnComment below line if you face clang error during installation procedure
# _file=$(find $PREFIX/lib/python3.11/_sysconfigdata*.py)
# rm -rf $PREFIX/lib/python3.11/__pycache__
# sed -i 's|-fno-openmp-implicit-rpath||g' "$_file"
pkg install -y python-cryptography
LDFLAGS="-L${PREFIX}/lib/" CFLAGS="-I${PREFIX}/include/" pip install --upgrade wheel pillow
pip install cython setuptools
CFLAGS="-Wno-error=incompatible-function-pointer-types -O0" pip install lxml


echo "${green}━━━ Starting SDK Tools installation ━━━${nocolor}"
if [ -d "android-sdk" ]; then
  echo "${red}Seems like sdk tools already installed, skipping...${nocolor}"
elif [ -d "androidide-tools" ]; then
  rm -rf androidide-tools
  git clone https://github.com/AndroidIDEOfficial/androidide-tools
  cd androidide-tools/scripts
  ./idesetup -c
else
  git clone https://github.com/AndroidIDEOfficial/androidide-tools
  cd androidide-tools/scripts
  ./idesetup -c
fi

echo "${yellow}ANDROID SDK TOOLS Successfully Installed!${nocolor}"

cd $HOME
echo
echo "${green}━━━ Starting NDK installation ━━━${nocolor}"
echo "Now You'll be asked about which version of NDK to isntall"
echo "${note}If your Android Version is 9 or above then choose ${red}'9'${nocolor}"
echo "${note}If your Android Version is below 9 or if you faced issues with '9' (A9 and above users) then choose ${red}'8'${nocolor}"
echo "${red} If you're choosing other options then you're on your own and experiment yourself ¯⁠\⁠_⁠ಠ⁠_⁠ಠ⁠_⁠/⁠¯${nocolor}"
if [ -f "ndk-install.sh" ]; then
  chmod +x ndk-install.sh && bash ndk-install.sh
else
  cd && pkg upgrade && pkg install wget && wget https://github.com/MrIkso/AndroidIDE-NDK/raw/main/ndk-install.sh --no-verbose --show-progress -N && chmod +x ndk-install.sh && bash ndk-install.sh
fi


if [ -d "$HOME/android-sdk/ndk/17.2.4988734" ]; then
  ndk_version="17.2.4988734"
elif [ -d "$HOME/android-sdk/ndk/18.1.5063045" ]; then
  ndk_version="18.1.5063045"
elif [ -d "$HOME/android-sdk/ndk/19.2.5345600" ]; then
  ndk_version="19.2.5345600"
elif [ -d "$HOME/android-sdk/ndk/20.1.5948944" ]; then
  ndk_version="20.1.5948944"
elif [ -d "$HOME/android-sdk/ndk/21.4.7075529" ]; then
  ndk_version="21.4.7075529"
elif [ -d "$HOME/android-sdk/ndk/22.1.7171670" ]; then
  ndk_version="22.1.7171670"
elif [ -d "$HOME/android-sdk/ndk/23.2.8568313" ]; then
  ndk_version="23.2.8568313"
elif [ -d "$HOME/android-sdk/ndk/24.0.8215888" ]; then
  ndk_version="24.0.8215888"
elif [ -d "$HOME/android-sdk/ndk/26.1.10909125" ]; then
  ndk_version="26.1.10909125"
else
  echo "${red}You didn't Installed any ndk terminating!"
  exit 1
fi
echo "${yellow}ANDROID NDK Successfully Installed!${nocolor}"

cd $HOME
echo
echo "${green}━━━ Setting up apktool ━━━${nocolor}"
if [ -f "$PREFIX/bin/apktool.jar" ]; then
  echo "${blue}apktool is already installed${nocolor}"
else
  sh -c 'wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -O $PREFIX/bin/apktool.jar'
  
  chmod +r $PREFIX/bin/apktool.jar
  
  sh -c 'wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O $PREFIX/bin/apktool' && chmod +x $PREFIX/bin/apktool || exit 2
fi

cd $HOME
if [ -d "Dex2c" ]; then
  cd Dex2c
elif [ -f "dcc.py" ] && [ -d "tools" ]; then
  :
else
  git clone https://github.com/bagayboss509/Dex2c || exit 2
  cd Dex2c || exit 2
fi

if [ -f "$HOME/Dex2c/tools/apktool.jar" ]; then
  rm $HOME/Dex2c/tools/apktool.jar
  cp $PREFIX/bin/apktool.jar $HOME/Dex2c/tools/apktool.jar
else
sh -c 'wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -O $HOME/Dex2c/tools/apktool.jar'
fi

cd ~/Dex2c
python3 -m pip install -U -r requirements.txt || exit 2

if [ -f ".bashrc" ]; then
  cat <<- EOL >> ~/.bashrc
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$HOME/android-sdk/cmdline-tools/latest/bin
export PATH=$PATH:$HOME/android-sdk/platform-tools
export PATH=$PATH:$HOME/android-sdk/build-tools/34.0.4
export PATH=$PATH:$HOME/android-sdk/ndk/$ndk_version
export ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version
EOL
elif [ -f ".zshrc" ]; then
  cat <<- EOL >> ~/.zshrc
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$HOME/android-sdk/cmdline-tools/latest/bin
export PATH=$PATH:$HOME/android-sdk/platform-tools
export PATH=$PATH:$HOME/android-sdk/build-tools/34.0.4
export PATH=$PATH:$HOME/android-sdk/ndk/$ndk_version
export ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version
EOL
else
  cat <<- EOL >> $PREFIX/etc/bash.bashrc
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$HOME/android-sdk/cmdline-tools/latest/bin
export PATH=$PATH:$HOME/android-sdk/platform-tools
export PATH=$PATH:$HOME/android-sdk/build-tools/34.0.4
export PATH=$PATH:$HOME/android-sdk/ndk/$ndk_version
export ANDROID_NDK_ROOT=$HOME/android-sdk/ndk/$ndk_version
EOL
fi

cat > $HOME/Dex2c/dcc.cfg << EOL
{
    "apktool": "tools/apktool.jar",
    "ndk_dir": "$HOME/android-sdk/ndk/$ndk_version",
    "signature": {
        "keystore_path": "keystore/debug.keystore",
        "alias": "androiddebugkey",
        "keystore_pass": "android",
        "store_pass": "android",
        "v1_enabled": true,
        "v2_enabled": true,
        "v3_enabled": true
    }
}
EOL
clear
termux-open-url https://t.me/apk2mods
echo "${green}============================"
echo "Great! Dex2c installed successfully!"
echo "============================${nocolor}"
