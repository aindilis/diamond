#!/bin/sh

ps aux | grep diamond | awk '{print $2}' | xargs sudo kill -9
ps aux | grep diamond