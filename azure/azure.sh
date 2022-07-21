#!/bin/bash

az account show | grep -o '"id": "[^"]*' | grep -o '[^"]*$'