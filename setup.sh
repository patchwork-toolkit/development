#!/bin/bash -e

###########################################################################
# Functions
#

# return 1 if global command line program installed, else 0
# example
# echo "node: $(program_is_installed node)"
function program_is_installed {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

# display a message in red with a cross by it
# example
# echo echo_fail "No"
function echo_fail {
  # echo first argument in red
  printf "\e[31m✘ ${1}"
  # reset colours back to normal
  printf "\033[0m\n"
}

# display a message in green with a tick by it
# example
# echo echo_fail "Yes"
function echo_pass {
  # echo first argument in green
  printf "\e[32m✔ ${1}"
  # reset colours back to normal
  printf "\033[0m\n"
}

# echo pass or fail
# example
# echo echo_if 1 "Passed"
# echo echo_if 0 "Failed"
function echo_if {
  if [ $1 == 1 ]; then
    echo_pass $2
  else
    echo_fail $2
  fi
}

###########################################################################
# Main
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

echo "This script configures current directory as Patchwork Toolkit development environment."
echo -n "Proceed? [y/n] "
while read answer
do
    if [ "$answer" = "n" ]; then
        echo "Terminated"
        exit 0
    elif [ "$answer" = "y"  ]; then
        break
    fi
    echo -n "Invalid entry. Proceed? [y/n] "
done


if [ "$GOPATH" = "" ]; then
    echo "[ERROR] You need to set GOPATH environment variable!"
    exit 1
fi


echo "Environment"
echo " -> GOPATH=$GOPATH"
echo " -> VERSION=$(go version)"


echo "Checking required software"
echo " -> Checking git... $(echo_if $(program_is_installed git))"
echo " -> Checking mosquitto... $(echo_if $(program_is_installed mosquitto))"
echo " -> Checking foreman... $(echo_if $(program_is_installed foreman))"
echo " -> Checking grunt... $(echo_if $(program_is_installed grunt))"
echo " -> Checking grip... $(echo_if $(program_is_installed grip))"


echo "Cloning/updating related repositories"
echo -n " -> agent-examples repository... "
if [ -d "$PWD/agent-examples" ]; then
    pushd $PWD/agent-examples >> /dev/null
    git pull >> /dev/null
    popd >> /dev/null
else
    git clone https://github.com/patchwork-toolkit/agent-examples >> /dev/null
fi
echo_pass

echo -n " -> dashboard repository... "
if [ -d "$PWD/static/dashboard" ]; then
    pushd $PWD/static/dashboard >> /dev/null
    git pull >> /dev/null
    popd >> /dev/null
else
    pushd $PWD/static >> /dev/null
    git clone https://github.com/patchwork-toolkit/dashboard.git >> /dev/null
    popd >> /dev/null
fi
echo_pass

echo -n " -> wiki repository..."
if [ -d "$PWD/wiki" ]; then
    pushd $PWD/wiki >> /dev/null
    git pull >> /dev/null
    popd >> /dev/null
else
    git clone https://github.com/patchwork-toolkit/patchwork.wiki.git wiki >> /dev/null
fi
echo_pass

echo -n " -> website repository... "
if [ -d "$PWD/website" ]; then
    pushd $PWD/website >> /dev/null
    git pull >> /dev/null
    popd >> /dev/null
else
    git clone https://github.com/patchwork-toolkit/patchwork-toolkit.github.io.git website >> /dev/null
fi
echo_pass


echo "Creating configuration from samples"

echo -n " -> conf/*.json... "
cp $PWD/conf/dashboard.json.sample $PWD/conf/dashboard.json
cp $PWD/conf/device-catalog.json.sample $PWD/conf/device-catalog.json
cp $PWD/conf/device-gateway.json.sample $PWD/conf/device-gateway.json
cp $PWD/conf/service-catalog.json.sample $PWD/conf/service-catalog.json
echo_pass

echo -n " -> conf/devices/*.json... "
cp $PWD/conf/devices/dummy.json.sample $PWD/conf/devices/dummy.json
cp $PWD/conf/devices/speakers.json.sample $PWD/conf/devices/speakers.json
cp $PWD/conf/devices/system.json.sample $PWD/conf/devices/system.json
echo_pass

echo -n " -> conf/services/*.json... "
cp $PWD/conf/services/mqtt-broker.json.sample $PWD/conf/services/mqtt-broker.json
echo_pass


echo "Building dashboard"
pushd $PWD/static/dashboard >> /dev/null
npm install .
grunt
popd >> /dev/null


echo "Building programs"
echo -n " -> executing build.sh... "
./build.sh
echo_pass

echo "Generating HTML docs from wiki"
./doc.sh

echo "DONE!"
exit 0