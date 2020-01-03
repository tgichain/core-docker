#!/usr/bin/env bash
  
sudo docker stop $(sudo docker ps -aq)
sudo docker rm $(sudo docker ps -aq)
sudo docker rmi $(sudo docker images -q)
sudo docker volume prune -f
sudo docker network prune -f
