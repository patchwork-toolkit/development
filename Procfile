#
# Foreman's development Procfile
#
mqtt: mosquitto
sc: sleep 2 && exec service-catalog
dc: sleep 4 && exec device-catalog
sr: sleep 6 && exec service-registrator -discover -conf=conf/services/mqtt-broker.json
dgw: sleep 6 && exec device-gateway
