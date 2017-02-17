
i=0
output=0
handler="handler"
flag="True"

while [ $output -eq 0 ];
do 
	
	result=$(python /home/ubuntu/galaxy/scripts/dbconnection.py --handler=$handler$i)
   	if [[ "$result" == "False" ]];then
		flag="False"
	fi
	i=$(( $i + 1 ))
	crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:$handler$i host
	output=$?
done
#echo $flag
#echo $i	
#sleep 3m
echo $flag
output=0
i=0
flag2="True"

while [ $output -eq 0 ];
do
	result2=$(python /home/ubuntu/galaxy/scripts/dbconnection.py --handler=$handler$i)
	if [[ "$result2" == "False" ]]; then
		flag2="False"
	fi
	i=$(( $i + 1 ))
	crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:$handler$i host
	output=$?
done
echo $flag2
echo $i
if [[ "$flag2" == "True" ]]; then
	#launch ansible creation playbook
	NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	new_name=$handler-$NEW_UUID-$i
#	echo $new_name
        webAddress=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:main host) 
        webInternalAddress=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
        port=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:$handler$((i-1)) port)
        port=$((port + 1))
	ansible-playbook --extra-vars "vmName=$new_name" --extra-vars "webAddress=$webAddress" --extra-vars "webInternalAddress=$webInternalAddress" --extra-vars "port=$port" --extra-vars "handlerid=$handler$i" /home/ubuntu/playbook.yaml
	echo "Increase vm count"
#result equals False so one of the VMs was empy last time
else	
	i=0
	result3="True"
	while [[ "$result3" == "True" ]];do
		result3=$(python /home/ubuntu/galaxy/scripts/dbconnection.py --handler=$handler$i)
		if [[ "$result3" == "False" ]];then
			emptyhost=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:$handler$i host)
			echo "Delete a vm"
			#delete vm with ip equal to emptyhost. So need fixed ip to be variable in delete playbook. 
		fi
		i=$(( $i + 1 ))
	done
fi


