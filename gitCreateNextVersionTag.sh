#!/bin/bash

usage() {
  echo "# Usage: $0 [-prefix <version prefix>] [-M|-m|-p]"
  echo "# Current git description: $CURRENT"
  echo "# -M: update major version to $NEXT_MAJOR"
  echo "# -m: update minor version to $NEXT_MINOR"
  echo "# -p: update patch version to $NEXT_PATCH"
  exit 255
}

if [ -n "$(git status --porcelain)" ]; then
  echo "# There are uncommitted changes!"
  exit 255
fi

USAGE=0
test $# -eq 1 || USAGE=1

PREFIX=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -M)
      NEXT_VERSION="NEXT_MAJOR"
      shift
      ;;
    -m)
      NEXT_VERSION="NEXT_MINOR"
      shift
      ;;
    -p)
      NEXT_VERSION="NEXT_PATCH"
      shift
      ;;
    -prefix)
      shift
      if [[ $# -eq 0 ]]; then usage; fi
      PREFIX="$1"
      shift
      ;;
    *)
      echo "# Unrecognized option: $1"
      USAGE=1
      ;;
  esac
done

GLOB="${PREFIX}[0-9].[0-9].[0-9]*"
CURRENT=$(git describe --match "$GLOB")

if [[ $? -ne 0 ]]; then
  echo "Cannot describe git version matching $GLOB"
  exit 255
fi

REPOSITORY=$(git rev-parse  --abbrev-ref --symbolic-full-name '@{push}' | sed -e 's|^\(.*\)/.*$|\1|')

if [[ $? -ne 0 ]]; then
  echo "Cannot get git repository name"
  exit 255
fi

MAJOR0=$(echo $CURRENT | sed -e "s/^$PREFIX\([0-9]*\)\.[0-9]*\.[0-9]*.*$/\1/")
MINOR0=$(echo $CURRENT | sed -e "s/^$PREFIX[0-9]*\.\([0-9]*\)\.[0-9]*.*$/\1/")
PATCH0=$(echo $CURRENT | sed -e "s/^$PREFIX[0-9]*\.[0-9]*\.\([0-9]*\).*$/\1/")

MAJOR1=$(( 1 + $MAJOR0 ))
MINOR1=$(( 1 + $MINOR0 ))
PATCH1=$(( 1 + $PATCH0 ))

NEXT_MAJOR="$PREFIX$MAJOR1.0.0"
NEXT_MINOR="$PREFIX$MAJOR0.$MINOR1.0"
NEXT_PATCH="$PREFIX$MAJOR0.$MINOR0.$PATCH1"

if [[ $USAGE -eq 1 ]]; then usage; fi

NEXT=${!NEXT_VERSION}
echo    "# Current git description: $CURRENT"
echo -n "# OK to tag and push : $NEXT (y/n) ? "

read -r -e yn
case ${yn:0:1} in
  y|Y )
    git tag -s -m"$NEXT" "$NEXT"
    if [[ $? -ne 0 ]]; then
      echo "Cannot create tag: $NEXT"
      exit 255
    fi

    git push $REPOSITORY HEAD tag $NEXT
    if [[ $? -ne 0 ]]; then
      echo "Cannot push tag: $NEXT to repository $REPOSITORY"
      exit 255
    fi
    ;;

  *)
    echo "# Aborting"
    exit 255
    ;;
  esac
