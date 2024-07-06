log=/tmp/roboshop.log
func_java(){
  echo  -e "\e[32m>>>> install maven <<<<\e[0m"   | tee -a  ${log}
  dnf install maven -y &>>${log}

  func_apppreq

  echo  -e "\e[32m>>>> cleaning package <<<<\e[0m"   | tee -a  ${log}
  mvn clean package   &>>${log}
  echo  -e "\e[32m>>>> movinig ${component}jar <<<<\e[0m"   | tee -a  ${log}
  mv target/${component}-1.0.jar ${component}.jar   &>>${log}

  func_schema_setup

  func_systemd
}
func_nodejs(){

  echo  -e "\e[32m>>>> mongo repo <<<<\e[0m"   | tee -a  ${log}
  cp mongo.repo /etc/yum.repos.d/mongo.repo   &>>${log}

  func_rpm

  echo  -e "\e[32m>>>> disable nodejs <<<<\e[0m"   | tee -a  ${log}
  dnf module disable nodejs -y   &>>${log}
  echo  -e "\e[32m>>>> enable nodejs`` <<<<\e[0m"   | tee -a  ${log}
  dnf module enable nodejs:18 -y    &>>${log}
  echo  -e "\e[32m>>>> install nodejs <<<<\e[0m"   | tee -a  ${log}
  dnf install nodejs -y   &>>${log}

  func_apppreq

  echo  -e "\e[32m>>>> dowlnloading dependencies <<<<\e[0m"   | tee -a  ${log}
  npm install   &>>${log}

  func_schema_setup

  func_systemd

}
func_python(){
  echo  -e "\e[32m>>>> install python <<<<\e[0m"   | tee -a  ${log}
  dnf install python36 gcc python3-devel -y   &>>${log}

  func_apppreq
  echo  -e "\e[32m>>>> install python requirements <<<<\e[0m"   | tee -a  ${log}
  pip3.6 install -r requirements.txt   &>>${log}

  func_systemd
}
func_rpm(){
  if [ "${rpm_type}" == "nodejs" ] ; then
    echo  -e "\e[32m>>>> rpm setup  <<<<\e[0m"   | tee -a  ${log}
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}
  fi
}
func_apppreq(){

  echo  -e "\e[32m>>>> creating ${component} service  <<<<\e[0m"   | tee -a  ${log}
  cp ${component}.service /etc/systemd/system/${component}.service  &>>${log}

  echo  -e "\e[32m>>>> adding user roboshop <<<<\e[0m"   | tee -a  ${log}
  useradd roboshop

  echo  -e "\e[32m>>>> cleaning old content<<<<\e[0m"   | tee -a  ${log}
  rm -rf /app
  mkdir /app

  echo  -e "\e[32m>>>> downloading ${component} <<<<\e[0m"   | tee -a  ${log}
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip  &>>${log}

  cd /app
  echo  -e "\e[32m>>>> unzipping content <<<<\e[0m"   | tee -a  ${log}
  unzip /tmp/${component}.zip &>>${log}
  cd /app
}

func_schema_setup(){
  if [ "${schema_type}" == "mongodb" ]; then
    echo  -e "\e[32m>>>> install DB shell <<<<\e[0m"   | tee -a  ${log}
    dnf install mongodb-org-shell -y   &>>${log}
    echo  -e "\e[32m>>>> load schema <<<<\e[0m"   | tee -a  ${log}
    mongo --host mongodb.vinithaws.online </app/schema/${component}.js  &>>${log}
  fi

  if [ "${schema_type}" == "mysql" ]; then

    echo  -e "\e[32m>>>> install mysql <<<<\e[0m"   | tee -a  ${log}
    dnf install mysql -y   &>>${log}

    echo  -e "\e[32m>>>> load shipping db schema <<<<\e[0m"   | tee -a  ${log}
    mysql -h mysql.vinithaws.online -uroot -pRoboShop@1 < /app/schema/${component}.sql  &>>${log}
    fi
    }

func_systemd(){
  echo  -e "\e[32m>>>> enabaling and restarting service <<<<\e[0m"   | tee -a  ${log}
  systemctl daemon-reload
  systemctl enable ${component}
  systemctl restart ${component}
}
