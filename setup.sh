#!/bin/bash

set -e
cd "$(dirname "$0")"

ANDROID_HOME="/opt/android/sdk"

installJDK() {
  echo "Installing JDK..."
  LTS_VERSION=17

  apt install openjdk-"$LTS_VERSION"-jdk
}

installGodot() {
  echo "Installing Godot..."
  DESTINATION_DIR="./.temp/godot"
  FILE_NAME="Godot_v3.5-stable_x11.64"

  curl -LO https://github.com/godotengine/godot-builds/releases/download/3.5-stable/Godot_v3.5-stable_x11.64.zip
  mkdir -p "$DESTINATION_DIR"
  unzip -q "$FILE_NAME.zip" -d "$DESTINATION_DIR"
  mv "$DESTINATION_DIR/$FILE_NAME" /bin/godot
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

setupAndroidHome() {
  echo "export ANDROID_HOME=\"$ANDROID_HOME\"" | tee -a /etc/bash.bashrc
  source /etc/bash.bashrc
}

installSDKSupportTools() {
  echo "Installing SDK support tools..."

  SDK_MANAGER="$ANDROID_HOME"/cmdline-tools/latest/bin/sdkmanager

  "$SDK_MANAGER" platform-tools
  "$SDK_MANAGER" emulator
  "$SDK_MANAGER" "platforms;android-34"
  "$SDK_MANAGER" "system-images;android-34;default;x86_64"
  "$SDK_MANAGER" "build-tools;34.0.0"
}

setupEnvironmentVars() {
  echo "Setting up environment variables..."
  EMULATOR_PATH="$ANDROID_HOME/emulator"
  PLATFORM_TOOLS_PATH="$ANDROID_HOME/platform-tools"
  BIN_TOOLS_PATH="$ANDROID_HOME/cmdline-tools/latest/bin"

  SETUP_PATH=$EMULATOR_PATH:$PLATFORM_TOOLS_PATH:$BIN_TOOLS_PATH

  echo "export ANDROID_AVD_HOME=$ANDROID_HOME/avd" | tee -a /etc/bash.bashrc
  echo "export PATH=\$PATH:$SETUP_PATH" | tee -a /etc/bash.bashrc
  source /etc/bash.bashrc
}

createAVD() {
  echo "Creating Android Virtual Device (AVD)..."

  avdmanager create avd --name android34 --package "system-images;android-34;default;x86_64"

  echo "To run emulator, Run this command $ emulator @android34"
}

createKeyStores() {
  echo "Creating both debug and release keystores..."

  cat .debugpass.txt | keytool -genkeypair -v -keystore debug.keystore -keyalg RSA -keysize 2048 -validity 365 -alias debug_key -dname "CN=Name,OU=Your Organization,O=Your Company,L=Your City,ST=Your State,C=Your Country"

  cat .releasepass.txt | keytool -genkeypair -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias debug_key -dname "CN=Name,OU=Your Organization,O=Your Company,L=Your City,ST=Your State,C=Your Country"
}

main() {
  installJDK
  installGodot
  installAndroidCMDTool
  setupAndroidHome
  installSDKSupportTools
  setupEnvironmentVars
  createAVD
  createKeyStores

  echo "Setup completed successfully!"
}

main
