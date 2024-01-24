#!/bin/bash

set -e
cd "$(dirname "$0")"

JAVA_LTS_VERSION=17
GODOT_VERSION="4.1"
GODOT_FILE_NAME="Godot_v$GODOT_VERSION-stable_linux.x86_64"
ANDROID_HOME="/opt/android/sdk"
API_LEVEL=34
AVD_NAME=android-level-34

installJDK() {
  echo "Installing JDK..."

  apt install openjdk-"$JAVA_LTS_VERSION"-jdk
}

installGodot() {
  echo "Installing Godot..."
  DESTINATION_DIR="./.temp/godot"

  curl -LO https://github.com/godotengine/godot-builds/releases/download/"$GODOT_VERSION"-stable/"$GODOT_FILE_NAME".zip
  mkdir -p "$DESTINATION_DIR"
  unzip -q "$GODOT_FILE_NAME.zip" -d "$DESTINATION_DIR"
  mv "$DESTINATION_DIR/$GODOT_FILE_NAME" /bin/godot"$GODOT_VERSION"
}

installAndroidCMDTool() {
  echo "Installing Android Command Line Tools..."
  ZIP_FILE="commandlinetools.zip"
  DESTINATION_DIR="./.temp/androidcmd/"
  ANDROID_SRC="./.temp/androidcmd/cmdline-tools/*"
  ANDROID_DEST="$ANDROID_HOME/cmdline-tools/latest/"

  curl -o "$ZIP_FILE" https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
  mkdir -p "$DESTINATION_DIR"
  unzip -q "$ZIP_FILE" -d "$DESTINATION_DIR"
  mkdir -p "$ANDROID_DEST"
  mv $ANDROID_SRC $ANDROID_DEST
}

installSDKSupportTools() {
  echo "Installing SDK support tools..."

  SDK_MANAGER=$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager

  $SDK_MANAGER platform-tools
  $SDK_MANAGER emulator
  $SDK_MANAGER "platforms;android-$API_LEVEL"
  $SDK_MANAGER "system-images;android-$API_LEVEL;default;x86_64"
  $SDK_MANAGER "build-tools;$API_LEVEL.0.0"
}

setupEnvironmentVars() {
  echo "Setting up environment variables..."
  EMULATOR_PATH="$ANDROID_HOME/emulator"
  PLATFORM_TOOLS_PATH="$ANDROID_HOME/platform-tools"
  BIN_TOOLS_PATH="$ANDROID_HOME/cmdline-tools/latest/bin"

  SETUP_PATH=$EMULATOR_PATH:$PLATFORM_TOOLS_PATH:$BIN_TOOLS_PATH

  {
    echo "export ANDROID_HOME=$ANDROID_HOME"
    echo "export ANDROID_AVD_HOME=$ANDROID_HOME/avd"
    echo "export PATH=\$PATH:$SETUP_PATH"
  } | tee -a /etc/bash.bashrc

  source /etc/bash.bashrc
}

createAVD() {
  echo "Creating Android Virtual Device (AVD)..."

  avdmanager create avd --name $AVD_NAME --package "system-images;android-$API_LEVEL;default;x86_64"

  echo "To run emulator, Run this command $ emulator @$AVD_NAME"
}

main() {
  installJDK
  installGodot
  installAndroidCMDTool
  setupEnvironmentVars
  installSDKSupportTools
  createAVD

  echo "Setup completed successfully!"
}

main
