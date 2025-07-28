#!/bin/bash

# Build runner script for Dosify Flutter app
# This script runs code generation for Hive adapters and JSON serialization

echo "Starting code generation..."

# Clean previous generated files
echo "Cleaning previous generated files..."
flutter packages pub run build_runner clean

# Run build runner to generate code
echo "Running build runner..."
dart run build_runner build --delete-conflicting-outputs

echo "Code generation completed!"

# Run flutter analyze to check for issues
echo "Running flutter analyze..."
flutter analyze

echo "Build script completed!"
