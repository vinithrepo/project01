source common.sh

echo  -e "\e[36m>>>> rpm remirepo download <<<<\e[0m"   | tee -a  ${log}
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
func_exit_status

echo  -e "\e[36m>>>> enable redis service <<<<\e[0m"   | tee -a  ${log}
dnf module enable redis:remi-6.2 -y
func_exit_status

echo  -e "\e[36m>>>> install redis service <<<<\e[0m"   | tee -a  ${log}
dnf install redis -y
func_exit_status

echo  -e "\e[36m>>>> listen address <<<<\e[0m"   | tee -a  ${log}
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf
func_exit_status

echo  -e "\e[36m>>>> start redis service <<<<\e[0m"   | tee -a  ${log}
systemctl enable redis
systemctl restart redis
func_exit_status
