#!/bin/bash

installJDK() {
  echo "Installing JDK..."
}

installGodot() {
  echo "Installing Godot..."
}

installAndroidCMDTool() {
  echo "Installing Android Command Line Tools..."

  # Download official commandline only tool for android sdk from Android Site.
  ZIP_FILE="./resources/commandlinetools.zip"
  DESTINATION_DIR="/opt/android/sdk/"

  mkdir -p "$DESTINATION_DIR"
  unzip -q "$ZIP_FILE" -d "$DESTINATION_DIR"
}

installSDKSupportTools() {
  echo "Installing SDK support tools..."
  export ANDROID_HOME=$DESTINATION_DIR
  export SDK_MANAGER=$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager

  $SDK_MANAGER platform-tools
  $SDK_MANAGER emulator
  $SDK_MANAGER "platforms;android-34"
  $SDK_MANAGER "system-images;android-34;default;x86_64"
  $SDK_MANAGER "build-tools;34.0.0"
}

# how to setup a system variable ?
setupEnvironmentVars() {
  echo "Setting up environment variables..."
  export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/platform-tools
}

createAVD() {
  echo "Creating Android Virtual Device (AVD)..."
  export AVD_MANAGER=$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager

  $AVD_MANAGER create avd --name android34 --package "system-images;android-34;default;x86_64"

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
