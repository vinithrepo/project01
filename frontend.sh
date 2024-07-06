source common.sh

echo  -e "\e[36m>>>> install nginx service <<<<\e[0m"   | tee -a  ${log}
dnf install nginx -y &>>${log}
func_exit_status

echo  -e "\e[36m>>>> copy roboshop configuration <<<<\e[0m"   | tee -a  ${log}
cp nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${log}
func_exit_status

echo  -e "\e[36m>>>> cleaning old content <<<<\e[0m"   | tee -a  ${log}
rm -rf /usr/share/nginx/html/* &>>${log}
func_exit_status

echo  -e "\e[36m>>>> downloading application content <<<<\e[0m"   | tee -a  ${log}
curl -o /tfunc_exit_statusmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log}
func_exit_status

cd /usr/share/nginx/html
echo  -e "\e[36m>>>> extracting app content <<<<\e[0m"   | tee -a  ${log}
unzip /tmp/frontend.zip &>>${log}
func_exit_status

echo  -e "\e[36m>>>> start nginx service <<<<\e[0m"   | tee -a  ${log}
systemctl enable nginx &>>${log}
systemctl restart nginx &>>${log}
func_exit_status
