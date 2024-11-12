#!/bin/bash
# MNE-LSL-based BCI installation script in Ubuntu 22.04. 
# Author: Minsu Zhang <minsuzhang@utexas.edu> (Updated: Nov. 2, 2024)

# Dependencies
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y \
    wget git build-essential cmake curl \
    libpugixml-dev freeglut3-dev libboost-all-dev plocate \
    qt6-base-dev qt6-tools-dev qt6-tools-dev-tools qt6-wayland-dev-tools \
    libqt6waylandclient6 libqt6waylandcompositor6
sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update && sudo apt-get install -y --reinstall libc6

# Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/opt/miniconda
rm Miniconda3-latest-Linux-x86_64.sh
$HOME/opt/miniconda/bin/conda init
source ~/.bashrc

# MNE
conda create -y --channel=conda-forge --strict-channel-priority --name=mne mne
echo 'conda activate mne' >> ~/.bashrc
source ~/.bashrc

# liblsl
git clone --depth=1 https://github.com/sccn/liblsl.git $HOME/opt/liblsl
cd $HOME/opt/liblsl
mkdir build
cd build
cmake ..
make
sudo make install
echo 'export CPLUS_INCLUDE_PATH="$HOME/opt/liblsl/include:$CPLUS_INCLUDE_PATH"' >> ~/.bashrc
echo 'export LIBRARY_PATH="$HOME/opt/liblsl/build:$LIBRARY_PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="$HOME/opt/liblsl/build:$LD_LIBRARY_PATH"' >> ~/.bashrc
source ~/.bashrc

# MNE-LSL and pyxdf
conda install -y mne-lsl pyxdf 

# LabRecorder
git clone https://github.com/labstreaminglayer/App-LabRecorder.git $HOME/opt/LabRecorder
cd $HOME/opt/LabRecorder
mkdir build
cd build
cmake ..
make
echo 'export PATH="$HOME/opt/LabRecorder/build:$PATH"' >> ~/.bashrc
source ~/.bashrc

# lsl-eego
mkdir $HOME/opt/lsl-eego
git clone https://github.com/minsuzhang/lsl-eego.git $HOME/opt/lsl-eego
cd $HOME/opt/lsl-eego
sudo cp 90-eego.rules /etc/udev/rules.d
sudo service udev restart
sudo cp $HOME/opt/lsl-eego/libeego-SDK.so /usr/local/lib/
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
sudo ldconfig
source ~/.bashrc
cd $HOME/opt/lsl-eego
mkdir build
cd build
sudo /usr/lib/qt6/bin/qmake ../eegoSports.pro
sudo make
echo 'export PATH="$HOME/opt/lsl-eego:$PATH"' >> ~/.bashrc
source ~/.bashrc