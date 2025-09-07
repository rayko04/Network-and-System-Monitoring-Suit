#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <thread>
#include <chrono>
#include <sys/statvfs.h>



void read_cpu(unsigned long long& total, unsigned long long& idle) {
    
    std::fstream file("/proc/stat", std::ios::in);
    if (!file) {
        std::cerr << "Error: file '/proc/stat' not opened.";
        return;
    }

    std::string line{}, label{};

    if(std::getline(file, line) ) {
        
        std::istringstream iss(line);
        iss >> label;

        int i{0};
        unsigned long long val{0};
        while(iss >> val) {
            total += val;
            if(i == 3 || i == 4)    idle += val;
         
            i++;
        }
        
    }

    file.close();
}

void get_cpu() {

    unsigned long long total1{0}, total2{0}, idle1{0}, idle2{0};
    
    read_cpu(total1, idle1);
    std::this_thread::sleep_for(std::chrono::seconds(1));    
    read_cpu(total2, idle2);

    unsigned long long total{total2-total1};
    unsigned long long idle{idle2-idle1};

    double usage{100.0* (total-idle)/total};
    std::cout << "\"cpu\":" << usage;
}

void get_mem() {

    std::fstream file("/proc/meminfo", std::ios::in);
    if(!file) {
        std::cerr << "Error: file '/proc/meminfo' not opened.\n";
        return; 
    }

    std::string line{};
    unsigned long long total{}, avail{};

    while(std::getline(file, line)) {
        std::istringstream iss(line);
        std::string key{};

        iss >> key;
        if(key == "MemTotal:") {
            iss >> total;
        }
        else if(key == "MemAvailable:") {
            iss >> avail;
        }
    }

    double usage{ ((1.0 - (double)avail/(double)total)*100.0)};

    std::cout << "\"mem\":" << usage;
}

void get_disk() {
    struct statvfs buf;
    
    const char* path{"/"};
    if(statvfs(path, &buf) != 0) {
        std::cerr << "Error: could not get stats for '/'\n";
        return;
    }

    unsigned long long total{buf.f_blocks * buf.f_frsize};
    unsigned long long free {buf.f_bavail * buf.f_frsize};
    unsigned long long used{total - free};

    double usage{(1.0 - (double)free / (double)total)*100.0};

    std::cout << "\"disk\":" << usage;
}

int main() {
    
       std::cout << "{"; 
       get_cpu();
       std::cout << ", ";
       get_mem();
       std::cout << ", "; 
       get_disk(); 
       std::cout << "}\n";
       
       return 0;
}
