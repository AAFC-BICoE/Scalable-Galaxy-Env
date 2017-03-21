
min=1
max=5

i=0
iniHandlers=($(grep -e "\[server:handler.*\]" /home/ubuntu/galaxy/config/galaxy.ini))
for k in "${iniHandlers[@]}"
do
	k=${k#[server:}
	k=${k%]}
	handlers[$i]=$k
	i=$(( $i+1 ))
done
handler="handler"
#echo ${handlers[*]}
echo ${#handlers[@]}
if [ ${#handlers[@]} -eq 0 ];
then
	NEW_UUID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)
        new_name=$handler-$NEW_UUID
        echo $new_name >> handlers.txt
#               echo $new_name
        webAddress=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:main host)
        webInternalAddress=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
	port=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:web0 port)
        port=$((port + 1))
        ansible-playbook --extra-vars "vmName=$new_name" --extra-vars "webAddress=$webAddress" --extra-vars "webInternalAddress=$webInternalAddress" --extra-vars "port=$port" --extra-vars "handlerid=$new_name" /home/ubuntu/playbook.yaml
        exit 0
fi
i=0
output=0
flag="True"


while [ $output -eq 0 ];
do 
	
	result=$(python /home/ubuntu/galaxy/scripts/dbconnection.py --handler=${handlers[$i]})
   	if [[ "$result" == "False" ]];then
		flag="False"
	fi
	i=$(( $i + 1 ))
	crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:${handlers[$i]} host
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
	result2=$(python /home/ubuntu/galaxy/scripts/dbconnection.py --handler=${handlers[$i]})
	if [[ "$result2" == "False" ]]; then
		flag2="False"
	fi
	i=$(( $i + 1 ))
	crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:${handlers[$i]} host
	output=$?
done
echo $flag2
echo $i
if [[ "$flag2" == "True" ]]; then
	if [ "${#handlers[@]}" -lt "$max" ];
	then
		#launch ansible creation playbook
		NEW_UUID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)
		new_name=$handler-$NEW_UUID
		echo $new_name >> handlers.txt
#		echo $new_name
        	webAddress=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:main host) 
        	webInternalAddress=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
        	port=$(crudini --get /home/ubuntu/galaxy/config/galaxy.ini server:${handlers[$((i-1))]} port)
        	port=$((port + 1))
		ansible-playbook --extra-vars "vmName=$new_name" --extra-vars "webAddress=$webAddress" --extra-vars "webInternalAddress=$webInternalAddress" --extra-vars "port=$port" --extra-vars "handlerid=$new_name" /home/ubuntu/playbook.yaml
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
				
			echo $vmName
			if [ "${#handlers[@]}" -gt "$min" ];
			then
				ansible-playbook --extra-vars "handlerid=${handlers[$i]}" --extra-vars "vmName=$vmName" /home/ubuntu/delete.yaml 
			cp handlers.txt handlers.temp.txt
			sed '/$vmName/d' handlers.temp.txt >| handlers.txt
			fi
		fi
		i=$(( $i + 1 ))
	done
fi


