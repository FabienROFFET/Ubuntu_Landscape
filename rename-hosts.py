#!/usr/bin/python3

###################################################################
#Script Name	: rename-hosts.py
#Description	: Rename so the hostname is equal to titles
#Email       	: fabien.roffet@gmail.com
#Date 		: 28.05.2023
###################################################################

import landscape_api.base
from landscape_api.base import API

api_key = ''
secret_key = ''
uri = ''
ca_bundle_path = ''

api = API(uri, api_key, secret_key,ca_bundle_path)

computers = api.get_computers()

computer_titles = {}

for computer in computers:
    computer_id = computer['id']
    hostname = computer['hostname']
    current_name = computer['title']

    if current_name != hostname:
        computer_titles[computer_id] = hostname

# Rename the computers
if computer_titles:
    api.rename_computers(computer_titles)
    for computer_id, new_name in computer_titles.items():
        print(f"Updated computer ID {computer_id} to new name: {new_name}")
else:
    print("No computers needed to be renamed.")
