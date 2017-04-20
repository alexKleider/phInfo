#!/bin/bash

sed -i s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g ph-setup.sh local_settings.py
