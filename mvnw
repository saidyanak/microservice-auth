#!/bin/sh
# Maven Wrapper script
# This script downloads and runs Maven Wrapper

set -e

MAVEN_WRAPPER_VERSION="3.2.0"
MAVEN_VERSION="3.9.6"

# Determine the Java command
if [ -n "$JAVA_HOME" ]; then
    JAVA_CMD="$JAVA_HOME/bin/java"
else
    JAVA_CMD="java"
fi

# Download maven-wrapper.jar if not present
WRAPPER_JAR=".mvn/wrapper/maven-wrapper.jar"
WRAPPER_URL="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/${MAVEN_WRAPPER_VERSION}/maven-wrapper-${MAVEN_WRAPPER_VERSION}.jar"

if [ ! -f "$WRAPPER_JAR" ]; then
    mkdir -p .mvn/wrapper
    echo "Downloading Maven Wrapper..."
    if command -v curl > /dev/null; then
        curl -sL -o "$WRAPPER_JAR" "$WRAPPER_URL"
    elif command -v wget > /dev/null; then
        wget -q -O "$WRAPPER_JAR" "$WRAPPER_URL"
    else
        echo "Error: Neither curl nor wget found. Cannot download Maven Wrapper."
        exit 1
    fi
fi

exec "$JAVA_CMD" \
    -jar "$WRAPPER_JAR" \
    "$@"
