#!/bin/bash

sudo systemctl restart nginx
cd /home/ubuntu/app
export DB_HOST=${db_host}
. ~/.bashrc
node seeds/seed.js
forever stopall
forever start app.js
