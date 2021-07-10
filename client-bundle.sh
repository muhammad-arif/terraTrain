#!/bin/zsh
printf "\n~~~~~~ Removing Old Client Bundle if there is any~~~~~~ \n"
if [[ -f bundle.zip ]] 
    then rm -rf /terraTrain/bundle.zip
fi
if [[ -d client-bundle ]] 
    then rm -rf /terraTrain/client-bundle
fi
pdir=$(pwd)
printf "\n~~~~~~ Downloading the client bundle ~~~~~~~\n"
UCP_URL=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0)| .attributes.public_dns' 2>/dev/null)
uname=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
pass=$(cat /terraTrain/terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null)

AUTHTOKEN=$(curl -sk -d "{\"username\": \"$uname\" , \"password\": \"$pass\" }" https://${UCP_URL}/auth/login | jq -r .auth_token)
curl -k -H "Authorization: Bearer $AUTHTOKEN" https://${UCP_URL}/api/clientbundle -o bundle.zip
mkdir /terraTrain/client-bundle
unzip /terraTrain/bundle.zip -d /terraTrain/client-bundle
cd /terraTrain/client-bundle
printf "\n~~~~~~ Activating the client bundle ~~~~~~~\n"
eval "$(printenv | grep AWS)"
eval "$(<env.sh)"
export uname=$uname
export pass=$pass
export auth=$AUTHTOKEN
export A=$AUTHTOKEN
export U=$uname
export P=$pass


export ucpurl=$UCP_URL
cd $pdir

# Exporting node ip with appropriate variable. Eg. m1=1st manager ip, w2= 2nd worker ip ....
manager_count=$(awk -F= -v key="manager_count" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
for count in $(seq $manager_count)
    do 
    index=`expr $count - 1` #because index_key starts with 0
    mgr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
    export m$count=$mgr_address
    export um$count="https://$mgr_address"
done	
worker_count=$(awk -F= -v key="worker_count" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
for count in $(seq $worker_count)
    do 
    index=`expr $count - 1` #because index_key starts with 0
    wkr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="workerNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
    export w$count=$wkr_address
done
msr_count=$(awk -F= -v key="msr_count" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
for count in $(seq $msr_count)
    do 
    index=`expr $count - 1` #because index_key starts with 0
    msr_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="msrNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
    export d$count=$msr_address
    export ud$count=$msr_address
done
win_worker_count=$(awk -F= -v key="win_worker_count" '$1==key {print $2}' /terraTrain/config.tfvars  | tr -d '"' | cut -d' ' -f1 | tr -d "\n")
for count in $(seq $win_worker_count)
    do 
    index=`expr $count - 1` #because index_key starts with 0
    win_worker_address=$(cat /terraTrain/terraform.tfstate |  jq --argjson cnt "$index" -r '.resources[] | select(.name=="winNode") | .instances[] | select(.index_key==$cnt) | .attributes.public_dns')
    export win$count=$win_worker_address
done

printf "\n~~~~~~ Testing client bundle with kubectl~~~~~~ \n"
kubectl get nodes || ( printf "Not working. May be credential issue" && exit 1 )

printf "\n~~~~~~ Testing client bundle with docker-cli~~~~~~ \n"
docker node ls && printf "\n~~~~~~ Yeeeeup, working !! ~~~~~~ \n" || ( printf "Not working. May be credential issue" && exit 1 )

printf "\nA few Environment Variables has been created for this cluster\n"
printf "\nFor example,\n\tm1 = public dns of the manager-1\n\tum1 = https://dns-of-the-manger-1\n\tU = username\n\tP = password\n"
printf "\nA few usages,\n\techo \$m1 \n\tcurl -k \$um1/_ping\n\tcurl -k -u \$U:\$P \$um1/info"
bash