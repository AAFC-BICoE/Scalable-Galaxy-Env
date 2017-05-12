#/bin/bash
source /home/ubuntu/admin-openrc.sh
source /home/ubuntu/galaxy/.venv/bin/activate
min=1
max=5
output=$(grep -e "server:handler.*" /home/ubuntu/galaxy/config/galaxy.ini | wc -l)
i=0

if [ $output -eq 1 ];
then 
	iniHandlers=$(grep -o -e "server:handler.*" /home/ubuntu/galaxy/config/galaxy.ini | rev | cut -c 2- | rev) 
else
	iniHandlers=( $(grep -o -e "server:handler.*" /home/ubuntu/galaxy/config/galaxy.ini | rev | cut -c 2- | rev) )
fi

for k in "${iniHandlers[@]}"
do
	k=${k#server:}
	handlers[$i]=$k
	i=$(( $i+1 ))
done

handler="handler"

if [ ${#handlers[@]} -eq 0 ];
then
	NEW_UUID=$(uuidgen)
        new_name=$handler-$NEW_UUID
        echo $new_name >> handlers.txt
        webAddress=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:main host)
        webInternalAddress=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
	port=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:web0 port)
        port=$((port + 1))
        ansible-playbook --extra-vars "vmName=$new_name" --extra-vars "webAddress=$webAddress" --extra-vars "webInternalAddress=$webInternalAddress" --extra-vars "port=$port" --extra-vars "handlerid=$new_name" --extra-vars "image_id=$image_id" --extra-vars "flavor_name=$flavor" --extra-vars "private_network=$private_network" --extra-vars "key_name=$key_name" --extra-vars "private_key_name=$private_key_name" --extra-vars "security_group=$security_group" /home/ubuntu/handlerCreation.yaml
        exit 0
fi
i=0
output=0
flag="True"
#first check of whether or not handler has job on it
while [ $output -eq 0 ];
do 
	result=$(python /home/ubuntu/galaxy/scripts/dbconnection.py -handler=${handlers[$i]})
   	if [[ "$result" == "False" ]];then
		flag="False"
	fi
	i=$(( $i + 1 ))
	crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:${handlers[$i]} host
	output=$?
done

#sleep 3m

output=0
i=0
flag2="True"

while [ $output -eq 0 ];
do
	result2=$(python /home/ubuntu/galaxy/scripts/dbconnection.py --handler=${handlers[$i]})
	if [[ "$result2" == "False" ]]; then
		flag2="False"
	fi
	i=$(( $i + 1 ))
	crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:${handlers[$i]} host
	output=$?
done

if [[ "$flag2" == "True" ]]; then
	if [ "${#handlers[@]}" -lt "$max" -a "${#handlers[@]}" -ge "$min" ];
	then
		#launch ansible creation playbook
		NEW_UUID=$(uuidgen)
                new_name=$handler-$NEW_UUID
		echo $new_name >> handlers.txt
        	webAddress=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:main host) 
        	webInternalAddress=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
        	port=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:${handlers[$((i-1))]} port)
        	port=$((port + 1))
		ansible-playbook --extra-vars "vmName=$new_name" --extra-vars "webAddress=$webAddress" --extra-vars "webInternalAddress=$webInternalAddress" --extra-vars "port=$port" --extra-vars "handlerid=$new_name" --extra-vars "image_id=$image_id" --extra-vars "key_name=$key_name" --extra-vars "flavor_name=$flavor" --extra-vars "private_network=$private_network" --extra-vars "private_key_name=$private_key_name" --extra-vars "security_group=$security_group" /home/ubuntu/handlerCreation.yaml
		echo "Increase vm count"
	fi
#result equals False so one of the VMs was empy last time
else	
	i=0
	result3="True"
	while [[ "$result3" == "True" ]];do
		result3=$(python /home/ubuntu/galaxy/scripts/dbconnection.py --handler=${handlers[$i]})
		if [[ "$result3" == "False" ]];then
			emptyhost=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:${handlers[$i]} host)
			echo "Delete a vm"
			echo ${handlers[$i]}
 			vmName=`grep -e "${handlers[$i]}" handlers.txt`
			if [ "${#handlers[@]}" -gt "$min" ];
			then
				ansible-playbook --extra-vars "key_name=$key_name" --extra-vars "private_network=$private_network" --extra-vars "image_id=$image_id" --extra-vars "handlerid=${handlers[$i]}" --extra-vars "vmName=$vmName" /home/ubuntu/handlerDeletion.yaml 
			cp handlers.txt handlers.temp.txt
			sed '/$vmName/d' handlers.temp.txt >| handlers.txt
			fi
		fi
		i=$(( $i + 1 ))
	done
fi


