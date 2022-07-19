#!/usr/bin/env bash

az account show | grep -o '"id": "[^"]*' | grep -o '[^"]*$'