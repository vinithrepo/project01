
source common.sh
rabbitmq_app_password=$1
if [ -z "${rabbitmq_app_password}" ]; then
  echo Input Rabbitmq Password Missing
  exit 1
fi

echo  -e "\e[36m>>>> download erlang script <<<<\e[0m"   | tee -a  ${log}
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>>${log}
func_exit_status

echo  -e "\e[36m>>>> download rabbitmq server <<<<\e[0m"   | tee -a  ${log}
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>>${log}
func_exit_status
echo  -e "\e[36m>>>> install rabbitmq <<<<\e[0m"   | tee -a  ${log}
dnf install rabbitmq-server -y   &>>${log}
func_exit_status
echo  -e "\e[36m>>>> start rabbitmq service <<<<\e[0m"   | tee -a  ${log}
systemctl enable rabbitmq-server   &>>${log}
systemctl restart rabbitmq-server   &>>${log}
func_exit_status
echo  -e "\e[36m>>>> add userpass <<<<\e[0m"   | tee -a  ${log}
rabbitmqctl add_user roboshop ${rabbitmq_app_password}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"