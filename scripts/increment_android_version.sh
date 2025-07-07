#!/bin/bash

# Script til at øge Android build nummer automatisk
# Brug: ./scripts/increment_android_version.sh

# Læs nuværende version fra pubspec.yaml
current_version=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
version_name=$(echo $current_version | cut -d'+' -f1)
build_number=$(echo $current_version | cut -d'+' -f2)

# Øg build nummer med 1
new_build_number=$((build_number + 1))
new_version="$version_name+$new_build_number"

# Opdater pubspec.yaml
sed -i.bak "s/^version: .*/version: $new_version/" pubspec.yaml

echo "Build nummer øget fra $build_number til $new_build_number"
echo "Ny version: $new_version"
echo ""
echo "Kør nu: flutter build appbundle --release"

# Created on $(date) 