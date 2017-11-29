#!/bin/bash

# File: set-pathagar-su.sh


echo "Time to set up the pathagar superuser..."
echo "1. cd into ~/pathagar:"
if cd ~/pathagar
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "2. source penv/bin/activate:"
# shellcheck disable=SC1091
if source penv/bin/activate
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "You'll now be asked to enter:"
echo "  a. A superuser (defaults to current user.)"
echo "  b. An email address for the superuser."
echo "  c. The password itself."
echo "  d. The same again."

echo "3. createsuperuser:"
if python manage.py createsuperuser
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi

echo "4. deactivate the environment:"
if deactivate
then
    echo "... success."
else
    echo "... failed! Terminating!"
    exit 1
fi
