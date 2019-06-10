#!/bin/bash
cd ./raw_data && python3 ./raw_loader.py
echo Running R script.
cd ./../Re3Databases && Rscript ./parsere3data.R
