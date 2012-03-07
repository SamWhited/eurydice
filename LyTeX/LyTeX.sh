#!/bin/bash

set -e

FILENAME=$1
DIRNAME=${FILENAME%/*}
if [ "$DIRNAME" == "$FILENAME" ]; then
	DIRNAME="./"
fi
BASENAME=$(basename $FILENAME)
BASENAME=${BASENAME%.*}
SUFFIX=${FILENAME##*.}

echo "Directory = $DIRNAME"
echo "Basename = $BASENAME"
echo "Suffix = $SUFFIX"
if [ -a $BASENAME ]; then
	rm -rf $BASENAME
fi

lilypond-book --output=$BASENAME --pdf $FILENAME

(cd $BASENAME; pdflatex --synctex=1 $BASENAME.tex)

cp $BASENAME/$BASENAME.pdf ./$BASENAME.pdf >/dev/null 2>&1 || { echo >&2 "Error copying PDF!"; }

echo "Copying midi files..."
MIDIDIR=$(find `ls -l | awk ' /^d/ { print $NF } '` -type d | grep $BASENAME | tail -n 1)
cp $MIDIDIR/*.midi ./$BASENAME.midi >/dev/null 2>&1 || { echo >&2 "No midi output detected."; }

command -v timidity >/dev/null 2>&1 || { echo >&2 "Timidity is not installed. No flac file will be generated."; exit 0; }

echo "Generating flac files..."
timidity -OF $BASENAME.midi
