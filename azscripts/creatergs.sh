#!/bin/bash

rgname="apimlabrg"
location="westus"

uName="user"
domain="@apimlabs.onmicrosoft.com" # Domain name of the AAD

i=1
while [ ${i} -le 90 ]
do
    if [ ${i} -lt 10 ]
    then
        uName="user0${i}"
        rgname="apimlabrg0${i}"
    else
        uName="user${i}"
        rgname="apimlabrg${i}"
    fi

    # Create resource group
    az group create --location "${location}" --name "${rgname}" >/dev/null
    if [ "$?" -ne 0 ]
    then
        echo "az group create failed"
        exit 1
    fi

    # Assign contributor role to the corresponding user account
    az role assignment create --role "Contributor" --assignee "${uName}${domain}" --resource-group "${rgname}" >/dev/null
    if [ "$?" -ne 0 ]
    then
        echo "az role assignment failed"
        exit 1
    fi

    echo "${rgname} is created and ${uName}${domain} is assigned to it."
    i=$(($i+1))
done

echo "All done!"
