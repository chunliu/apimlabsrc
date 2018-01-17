#!/bin/bash

# Output csv file
printf "No,User Name,Password\n" >> users.csv

dName="APIMLab User"  # Display name of the account
domain="@apimlabs.onmicrosoft.com"  # Domain name of the AAD

i=1
password=""
p1=""
p2=""
p3=""
p4=""
pName="user"
while [ ${i} -le 90 ]
do
  # Prepare the principal name and password
  p1="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-7})"
  p2="$(< /dev/urandom tr -dc a-z | head -c1)"
  p3="$(< /dev/urandom tr -dc 0-9 | head -c1)"
  p4="$(< /dev/urandom tr -dc A-Z | head -c1)"
  password="${p1}${p2}${p3}${p4}"

  if [ ${i} -lt 10 ]
  then
    pName="user0${i}${domain}"
    dName="${dName}0${i}"
  else
    pName="user${i}${domain}"
    dName="${dName}${i}"
  fi

  # Create user in AAD
  az ad user create --display-name "${dName}" --password "${password}" --user-principal-name "${pName}" --force-change-password-next-login false >/dev/null  
  if [ "$?" -ne 0 ] 
  then 
    echo "command failed"
    exit 1
  fi

  echo "${pName} is created."

  # Write info to csv
  printf "${i},${pName},${password}\n" >> users.csv
  i=$(($i+1))
done

echo "All users have been created!"

