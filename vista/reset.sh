#!/bin/sh
read -p "THis will delete the entire VistA setup are you sure? (y/n)" CONT
if [ "$CONT" = "y" ]; then
  echo "Deleteing ~/vista directory, run setup.sh to start over";
  docker stop iris
  docker rm iris
  sudo rm -rf ~/vista
else
  echo "ok then, not doing anything";
fi
