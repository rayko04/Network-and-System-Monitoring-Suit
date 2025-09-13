# Network and System Monitor Tool

Monitors System resource usage, scripted to run on reglar intervals and  integrated with mariadb to fetch information using SQL.


## Overview

[Daemon](./src/daemon.cpp)
        C++ program reading system information from Linux system files.
[Script](./scripts/script.sh)
        Bash script that compiles and run Daemon, logs the output, maintains log rotation and insert the data into database.
[Schema](./sql/schema.sql)
        Prototype used to create the database.

