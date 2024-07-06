mysql_root_password=$1
if [ -z "${mysql_root_password}" ]; then
  echo e "\e[34m>>>> INPUT PASSWORD MISSING <<<<\e[0m"
  exit 1
fi
source common.sh

echo  -e "\e[36m>>>> copy mysql repo <<<<\e[0m"   | tee -a  ${log}
cp mysql.repo /etc/yum.repos.d/mysql.repo &>>${log}
echo  -e "\e[36m>>>> disable mysql <<<<\e[0m"   | tee -a  ${log}
dnf module disable mysql -y &>>${log}
echo  -e "\e[36m>>>> install mysql  <<<<\e[0m"   | tee -a  ${log}
dnf install mysql-community-server -y  &>>${log}
echo  -e "\e[36m>>>> start mysql service <<<<\e[0m"   | tee -a  ${log}
systemctl enable mysqld  &>>{log}
systemctl restart mysqld  &>>{log}
echo  -e "\e[36m>>>> set root password  <<<<\e[0m"   | tee -a  ${log}
mysql_secure_installation --set-root-pass ${mysql_root_password}
