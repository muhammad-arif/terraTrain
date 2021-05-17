#!/bin/bash
### t deploy lab|cluster|instances  
t-deploy() {
  case "$1" in
    "lab") t-deploy-lab 
	       exit;;
	"cluster") t-deploy-cluster
	       exit;;
	"instances") t-deploy-instances
	       exit;;
	*) echo "t deploy lab|cluster|instances"
	   exit ;;
  esac
}
t-deploy-lab() { 
  echo "t-deploy-lab() was called"
}
t-deploy-cluster() { 
  echo "t-deploy-cluster() was called"
}
t-deploy-instances() { 
  echo "t-deploy-instances() was called"
}
### t destroy lab|cluster  DONE 
t-destroy() {
  case "$1" in
    "lab") t-destroy-lab 
	       exit;;
	"cluster") t-destroy-cluster
	       exit;;
#	"instances") t-destroy-instances
#	       exit;;
    *) echo "t destroy lab|cluster"
	   exit;;
  esac
}
t-destroy-lab() {
  echo "t-destroy-lab was called "
}
t-destroy-cluster() { 
  echo "t-destroy-cluster was called "
}  
# what about t-destroy-instances ?? Will we implement such thing? 
### t stop managers|msrs|workers|windows   DONE 
### Have not implemented the : t stop manager1 (t stop manager 1)
t-stop() {
  case "$1" in
    "managers") t-stop-managers
			exit;;
	"msrs")  t-stop-msrs
			exit;;
	"workers") t-stop-workers
			exit;;
	"windows") t-stop-windows
			exit;;
	*) echo "t stop managers|msrs|workers|windows"
	   exit ;;
  esac
}
t-stop-managers() { 
  echo "t-stop-managers was called"
}
t-stop-msrs() { 
  echo "t-stop-msrs was called, checking if there are msr nodes, and then stopping them"
}
t-stop-workers() { 
  echo "t-stop-workers was called, checking if there are workers nodes, and then stopping them"
}
t-stop-windows() { 
  echo "t-stop-windows was called, checking if there are windows nodes, and then stopping them "
}
### t gen client-bundle|msr-login|swarm-service|k8s-service|msr-images
t-gen-client_bundle() {
  echo "t gen client-bundle was called"
}
t-gen-msr_login() {
  echo "t gen msr-login was called"
}
t-gen-swarm_service() {
  echo "t gen swarm-service was called"
}
t-gen-k8s_service() {
  echo "t gen k8s-service was called"
}
t-gen-msr_images() {
  echo "t gen msr-images was called"
}
#### t show ip managers|msrs|workers|windows|all 
t-show-ip() {
  case "$1" in
    "managers") t-show-ip-managers
			exit;;
	"msrs") t-show-ip-msrs
			exit;;
	"workers") t-show-ip-workers
			exit;;
	"windows") t-show-ip-windows
			exit;;
	"all") t-show-ip-all
	       exit;;
	*) echo "t show ip managers|msrs|workers|windows|all"
	   exit;;
  esac
}
t-show-ip-managers() { 
  echo "t show ip managers was typed"
}
t-show-ip-msrs() { 
  echo "t show ip msrs was typed"
}
t-show-ip-workers() { 
  echo "t show ip workers was typed"
}
t-show-ip-windows() { 
  echo "t show ip windows was typed"
}
t-show-ip-all() {
  t-show-ip-managers
  t-show-ip-msrs
  t-show-ip-workers
  # t-show-ip-windows   # if windows VMs exist 
}
#### t show dns managers|msrs|workers|windows|all   
t-show-dns() {
  case "$1" in
    "managers") t-show-dns-managers
			exit;;
	"msrs")    t-show-dns-msrs
			exit;;
	"workers") t-show-dns-workers
			exit;;
	"windows") t-show-dns-windows
			exit;;
	"all") t-show-dns-all
	      exit;;
	*) echo "t show dns managers|msrs|workers|windows|all"
	   exit ;;
  esac
}
t-show-dns-managers() { 
  echo "t show dns managers was typed"
}
t-show-dns-msrs() { 
  echo "t show dns msrs was typed"
}
t-show-dns-workers() { 
  echo "t show dns workers was typed"
}
t-show-dns-windows() { 
  echo "t show dns windows was typed"
}
t-show-dns-all() {
  t-show-dns-managers
  t-show-dns-msrs
  t-show-dns-workers
  # t-show-dns-windows   # if windows VMs exist 
}
#### t show hostname managers|msrs|workers|windows  
t-show-hostname() {
  case "$1" in
    "managers") t-show-hostname-managers
			exit;;
	"msrs")    t-show-hostname-msrs
			exit;;
	"workers") t-show-hostname-workers
			exit;;
	"windows") t-show-hostname-windows
			exit;;
	*) echo "t show dns managers|msrs|workers|windows|all"
	   exit ;;
  esac
}
t-show-hostname-managers() { 
  echo "t show hostname managers was typed"
}
t-show-hostname-msrs() { 
  echo "t show hostname msrs was typed"
}
t-show-hostname-workers() { 
  echo "t show hostname workers was typed"
}
t-show-hostname-windows() { 
  echo "t show hostname windows was typed"
}
#### t show creds mke|msr                           
t-show-creds-mke() { 
  echo "t show creds mke was typed "
}
t-show-creds-msr() { 
  echo "t show creds msr was typed "
}
### t show access​-ke​y-linux|access​-ke​y-windows
t-show-access​_ke​y_linux() { 
  echo "t show access​-ke​y-linux was typed"
}
t-show-access​_ke​y_windows() { 
  echo "t show access​-ke​y-windows was typed"
}
#### t show status managers|msrs|workers|windows|all  
t-show-status() {
  case "$1" in 
  "managers") t-show-status-managers
              exit;;
  "msrs") t-show-status-msrs
          exit;;
  "workers") t-show-status-workers 
            exit;;
  "windows") t-show-status-windows 
            exit;;
  "all") t-show-status-all
        exit;;
  *) echo "t show status managers|msrs|workers|windows|all"
  esac 
}
t-show-status-managers() { 
  echo "t show status managers was typed"
}
t-show-status-msrs() { 
  echo "t show status msrs was typed"
}
t-show-status-workers() { 
  echo "t show status workers was typed"
}
t-show-status-windows() { 
  echo "t show status windows was typed"
}
t-show-status-all() {
  t-show-status-managers 
  t-show-status-msrs
  t-show-status-workers
  # t-show-status-wins  # if windows VMs exist 
}
### t show versions 
t-show-versions() { 
  echo "t show versions  was typed"
}
### t show all 
t-show-all() { 
  echo "t show all  was typed"
}
### t exec etcdctl
t-exec-etcdctl() {
  echo "t exec etcdctl was typed "
}
#### t exec rethinkcli mke|msr
t-exec-rethinkcli() {
  case "$1" in
    "mke") t-exec-rethinkcli-mke
	      exit;;
	"msr") t-exec-rethinkcli-msr 
	      exit;;
	*) echo "t exec rethinkcli mke|msr"
	  exit;;
  esac
}
t-exec-rethinkcli-mke() {
  echo "t exec rethinkcli mke was typed"
}
t-exec-rethinkcli-msr() {
  echo "t exec rethinkcli msr was typed"
}
##### 1st level usage function : 
usage1() {
  echo "t deploy lab|cluster|instances "
  echo "  After you have a running cluster, you have the following available commands:"
  echo "t show versions|status|all "
  echo "t show ip|dns|creds ...."
  echo "t show status|hostname managers|workers|msrs|windows "
  echo "t exec etcdctl "
  echo "t exec rethinkcli ..."
  echo "  When you finish your work:"
  echo "t stop managers|workers|msrs|windows|manager1 "
  echo "t destroy lab|cluster "
}

######### Parsing starts here, t is $0 , and we can have $1 $2 , or $1 $2 $3 ########
if [ $# -eq 2 ]; then 
  case "$1" in 
  "deploy") t-deploy "$2"    # t deploy lab|cluster|instances
          exit ;;
  "destroy") t-destroy "$2"  # t destroy lab|cluster
           exit ;;
  "stop")  t-stop "$2"       # t stop managers|msrs|workers|windows
         exit;;
  "show") case "$2" in 
		    "versions") t-show-versions
			             exit ;;
		    "all") t-show-all 
			        exit ;;
			"access​-ke​y-linux") t-show-access​_ke​y_linux
			        exit;;
			"access​-ke​y-windows") t-show-access​_ke​y_windows
			        exit;;
			 *) echo "t show versions|all|access-key-linux|access-key-windows "
			    echo "t show status managers|msrs|workers|windows|all "
				exit;;
		  esac 
         exit;;
   "gen")  # t gen client-bundle|msr-login|swarm-service|k8s-service|msr-images
         case "$2" in 
		 "client-bundle") t-gen-client_bundle 
		                 exit;;
		 "msr-login") t-gen-msr_login 
		              exit;;
		 "swarm-service") t-gen-swarm_service
		                 exit;;
		 "k8s-service") t-gen-k8s_service
		                exit;;
		 "msr-images") t-gen-msr_images
		               exit;;
		  *) echo "t gen client-bundle|msr-login|swarm-service|k8s-service|msr-images"
		 esac
        exit;;  
   "exec") # t exec etcdctl
          case "$2" in 
		  "etcdctl") t-exec-etcdctl  
		             exit ;; 
		   *) echo "t exec etcdctl|rethinkcli "
		      exit ;;
          esac		   
          exit;;
   *) echo "t deploy|destroy|stop|show|gen ... "
     exit ;;
  esac 
elif [ $# -eq 3 ]; then 
  case "$1" in 
  "show") # t show ip|dns|hostname|creds|status ...
         case "$2" in 
		 "ip") t-show-ip "$3"
				exit;;
		 "dns") t-show-dns "$3"
				exit;;
		 "hostname") t-show-hostname "$3"
		        exit;;
		 "creds")  t-show-creds "$3"
				exit;;
		 "status") t-show-status "$3"
		        exit;;
		  *) echo " t show ip|dns|hostname|creds|status ... "
		     exit;;
		 esac 
	    exit;;
  "exec") case "$2" in 
          "rethinkcli") t-exec-rethinkcli "$3"
		  exit;;
		  *) echo "t exec rethinkcli mke|msr"
		  exit;;
		  esac 
         exit;;
   *) usage1
      exit;;
  esac
else 
  usage1 
fi
