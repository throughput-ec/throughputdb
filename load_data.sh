#!/bin/bash
cd ./raw_data && python3 ./raw_loader.py
echo Loading Data from re3data:
cd ./../populate/Re3Databases && python3 parsere3data.py
cd ./../ropensci_libraries && python3 ./ropensci.py
cd ./../nsf_awards && bash get_awards.sh && python3 ./nsf_awards.py
