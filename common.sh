log=/tmp/roboshop.log
func_java(){
  echo  -e "\e[36m>>>> install maven <<<<\e[0m"   | tee -a  ${log}
  dnf install maven -y &>>${log}
  func_exit_status
  func_apppreq

  echo  -e "\e[36m>>>> cleaning package <<<<\e[0m"   | tee -a  ${log}
  mvn clean package   &>>${log}
  func_exit_status
  echo  -e "\e[36m>>>> movinig ${component}jar <<<<\e[0m"   | tee -a  ${log}
  mv target/${component}-1.0.jar ${component}.jar   &>>${log}
  func_exit_status
  func_schema_setup

  func_systemd
}
func_nodejs(){

  echo  -e "\e[36m>>>> mongo repo <<<<\e[0m"   | tee -a  ${log}
  cp mongo.repo /etc/yum.repos.d/mongo.repo   &>>${log}
  func_exit_status
  func_rpm

  echo  -e "\e[36m>>>> disable nodejs <<<<\e[0m"   | tee -a  ${log}
  dnf module disable nodejs -y   &>>${log}
  func_exit_status
  echo  -e "\e[36m>>>> enable nodejs`` <<<<\e[0m"   | tee -a  ${log}
  dnf module enable nodejs:18 -y    &>>${log}

  func_exit_status
  echo  -e "\e[36m>>>> install nodejs <<<<\e[0m"   | tee -a  ${log}
  dnf install nodejs -y   &>>${log}
  func_exit_status
  func_apppreq

  echo  -e "\e[36m>>>> dowlnloading dependencies <<<<\e[0m"   | tee -a  ${log}
  npm install   &>>${log}
  func_exit_status
  func_schema_setup

  func_systemd

}
func_python(){
  echo  -e "\e[36m>>>> install python <<<<\e[0m"   | tee -a  ${log}
  dnf install python36 gcc python3-devel -y   &>>${log}
  func_exit_status
  func_apppreq
  sed -i "s/rabbitmq_app_password/${rabbitmq_app_password}/"  /etc/systemd/system/${component}.service
  echo  -e "\e[36m>>>> install python requirements <<<<\e[0m"   | tee -a  ${log}
  pip3.6 install -r requirements.txt   &>>${log}
  func_exit_status
  func_systemd
}
func_rpm(){
  if [ "${rpm_type}" == "nodejs" ] ; then
    echo  -e "\e[36m>>>> rpm setup  <<<<\e[0m"   | tee -a  ${log}
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
    func_exit_status
  fi
}
func_apppreq(){

  echo  -e "\e[36m>>>> creating ${component} service  <<<<\e[0m"   | tee -a  ${log}
  cp ${component}.service /etc/systemd/system/${component}.service  &>>${log}
  func_exit_status

  echo  -e "\e[36m>>>> adding user roboshop <<<<\e[0m"   | tee -a  ${log}
  id roboshop &>>${log}
  if [ $? -ne 0 ]; then
    useradd roboshop
  fi
  func_exit_status

  echo  -e "\e[36m>>>> cleaning old content<<<<\e[0m"   | tee -a  ${log}
  rm -rf /app
  mkdir /app
  func_exit_status
  echo  -e "\e[36m>>>> downloading ${component} <<<<\e[0m"   | tee -a  ${log}
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip  &>>${log}
  func_exit_status
  cd /app
  echo  -e "\e[36m>>>> unzipping content <<<<\e[0m"   | tee -a  ${log}
  unzip /tmp/${component}.zip &>>${log}
  func_exit_status
  cd /app
}

func_schema_setup(){
  if [ "${schema_type}" == "mongodb" ]; then
    echo  -e "\e[36m>>>> install DB shell <<<<\e[0m"   | tee -a  ${log}
    dnf install mongodb-org-shell -y   &>>${log}
    func_exit_status
    echo  -e "\e[36m>>>> load schema <<<<\e[0m"   | tee -a  ${log}
    mongo --host mongodb.vinithaws.online </app/schema/${component}.js  &>>${log}
    func_exit_status
  fi

  if [ "${schema_type}" == "mysql" ]; then

    echo  -e "\e[36m>>>> install mysql <<<<\e[0m"   | tee -a  ${log}
    dnf install mysql -y   &>>${log}
    func_exit_status
    echo  -e "\e[36m>>>> load shipping db schema <<<<\e[0m"   | tee -a  ${log}
    mysql -h mysql.vinithaws.online -uroot -pRoboShop@1 < /app/schema/${component}.sql  &>>${log}
    func_exit_status
    fi
    }

func_systemd(){
  echo  -e "\e[36m>>>> enabaling and restarting service <<<<\e[0m"   | tee -a  ${log}
  systemctl daemon-reload  &>>${log}
  systemctl enable ${component}   &>>${log}
  systemctl restart ${component}  &>>${log}
  func_exit_status
}
func_exit_status(){
  if [ $? -eq 0 ] ; then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m FAILURE \e[0m"
  fi
}
