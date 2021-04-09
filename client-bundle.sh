#!/bin/zsh
printf "\n~~~~~~ Removing Old Client Bundle if there is any~~~~~~ \n"
if [[ -f bundle.zip ]] 
    then rm -rf bundle.zip
fi
if [[ -d client-bundle ]] 
    then rm -rf client-bundle
fi

printf "\n~~~~~~ Downloading the client bundle ~~~~~~~\n"
UCP_URL=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="managerNode") | .instances[] | select(.index_key==0)| .attributes.public_dns' 2>/dev/null)
uname=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
pass=$(cat terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.result' 2>/dev/null)

AUTHTOKEN=$(curl -sk -d "{\"username\": \"$uname\" , \"password\": \"$pass\" }" https://${UCP_URL}/auth/login | jq -r .auth_token)
curl -k -H "Authorization: Bearer $AUTHTOKEN" https://${UCP_URL}/api/clientbundle -o bundle.zip
mkdir client-bundle
unzip bundle.zip -d client-bundle
cd client-bundle
printf "\n~~~~~~ Activating the client bundle ~~~~~~~\n"
eval "$(printenv | grep AWS)"
eval "$(<env.sh)"
export uname=$uname
export pass=$pass
export auth=$AUTHTOKEN
export ucpurl=$UCP_URL
cd ..


printf "\n~~~~~~ Testing client bundle with kubectl~~~~~~ \n"
kubectl get nodes || ( printf "Not working. May be credential issue" && exit 1 )

printf "\n~~~~~~ Testing client bundle with docker-cli~~~~~~ \n"
docker node ls && printf "\n~~~~~~ Yeeeeup, working !! ~~~~~~ \n" || ( printf "Not working. May be credential issue" && exit 1 )

bash