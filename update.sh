#!/bin/bash

cd common || exit
pub get
pub upgrade
cd ..

cd bindings || exit
pub get
pub upgrade
./generate.sh
cd ..

cd embedder || exit
pub get
pub upgrade
cd ..

cd tool || exit
pub get
pub upgrade
cd ..

cd example || exit
flutter pub get
flutter pub upgrade
cd ..
