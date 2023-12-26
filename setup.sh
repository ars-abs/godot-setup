#!/bin/bash

set -e
cd "$(dirname "$0")"

installJDK() {
  echo "Installing JDK..."
  LTS_VERSION=17

  apt install openjdk-"$LTS_VERSION"-jdk
}

installGodot() {
  echo "Installing Godot..."
  DESTINATION_DIR="./resources/godot"
  FILE_NAME="Godot_v3.5-stable_x11.64"

  curl -LO https://github.com/godotengine/godot-builds/releases/download/3.5-stable/Godot_v3.5-stable_x11.64.zip
  mkdir -p "$DESTINATION_DIR"
  unzip -q "$FILE_NAME.zip" -d "$DESTINATION_DIR"
  mv "$DESTINATION_DIR"/"$FILE_NAME" /bin/godot
}

installAndroidCMDTool() {
  echo "Installing Android Command Line Tools..."
  ZIP_FILE="commandlinetools.zip"
  DESTINATION_DIR="/opt/android/sdk/"

  curl -o "$ZIP_FILE" https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
  mkdir -p "$DESTINATION_DIR"
  unzip -q "$ZIP_FILE" -d "$DESTINATION_DIR"
}

installSDKSupportTools() {
  echo "Installing SDK support tools..."
  export ANDROID_HOME="$DESTINATION_DIR"
  SDK_MANAGER="$ANDROID_HOME"/cmdline-tools/latest/bin/sdkmanager

  "$SDK_MANAGER" platform-tools
  "$SDK_MANAGER" emulator
  "$SDK_MANAGER" "platforms;android-34"
  "$SDK_MANAGER" "system-images;android-34;default;x86_64"
  "$SDK_MANAGER" "build-tools;34.0.0"
}

setupEnvironmentVars() {
  echo "Setting up environment variables..."
  export PATH=$PATH:"$ANDROID_HOME"/cmdline-tools/latest/bin
  export PATH=$PATH:"$ANDROID_HOME"/emulator
  export PATH=$PATH:"$ANDROID_HOME"/platform-tools
}

createAVD() {
  echo "Creating Android Virtual Device (AVD)..."
  AVD_MANAGER="$ANDROID_HOME"/cmdline-tools/latest/bin/avdmanager

  "$AVD_MANAGER" create avd --name android34 --package "system-images;android-34;default;x86_64"

  echo "To run emulator run this command $ emulator @android34"
}

main() {
  # installJDK
  # installGodot
  # installAndroidCMDTool
  # installSDKSupportTools
  # setupEnvironmentVars
  # createAVD

  echo "Setup completed successfully!"
}

main
