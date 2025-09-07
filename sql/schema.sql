CREATE DATABASE monitor_db;
USE monitor_db;

CREATE TABLE metrics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hostname VARCHAR(255),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  cpu_usage FLOAT,
  mem_usage FLOAT,
  disk_usage FLOAT
);

