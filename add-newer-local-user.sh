#!/bin/bash

# This script creates a new user on the local system.
# You must supply a username as an argument to the script.
# Optionally, you can also provide a comment for the account as an argument.
# A password will be automatically generated for the account.
# The username, password, and host for the account will be displayed.

# Check for superuser privileges
ROOT_UID='0'

if [[ "${UID}" -ne "${ROOT_UID}" ]]
then
    echo "User cannot be created without root privileges" >&2
    exit 1
fi

# The total number of parameters passed
NUMBER_OF_PARAMETERS="${#}"

# Check if the number of parameters is less than 1
if [[ "${NUMBER_OF_PARAMETERS}" -lt 1 ]]
then
    echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
    echo 'Create an account on the local system with the name of USER_NAME and a comments field of COMMENT' >&2
    exit 1
fi

# First parameter = username
USER_NAME=${1}

# The rest of the parameters are for the account comments.
shift
COMMENT=${@}

# Create a strong password with a special character
PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c48)
SPECIAL_CHARACTER=$(echo '!@#$%^&*()_+-=' | fold -w1 | shuf | head -c1)

# Create the user
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null

# Check if the account is created
if [[ "${?}" -ne 0 ]]
then
    echo 'The account could not be created.' >&2
    exit 1
fi

# Pass the password as the password for that user
echo ${PASSWORD}${SPECIAL_CHARACTER} | passwd --stdin ${USER_NAME} &> /dev/null

# Check to see if the passwd command succeeded.
if [[ ${?} -ne 0 ]]
then
    echo 'The password for the account could not be set.' >&2
    exit 1
fi

# Force password change on first login.
passwd -e ${USER_NAME} &> /dev/null

# Diplay the username, password, and the host where the user was created.
echo 'Username:'
echo "${USER_NAME}"
echo
echo 'Password:'
echo "${PASSWORD}"
echo
echo 'Host:'
echo "${HOSTNAME}"

exit 0