# terraformAnsible_MySQL
Terraform para instalação do MySQL via Ansible

Segunda atividade do curso Infrastructure and Cloud Computing 

Professor: João Victorino

## Alunos:

Leonardo Ananias do Nascimento Azogue 

Vinissius Vioti dos Santos 

## ***Descrição Atividade:*** 
Subir uma máquina virtual no Azure, AWS ou GCP instalando o MySQL e que esteja acessível no host da máquina na porta 3306, usando Terraform. 
Se quiser usar o Ansible para configurar a máquina é interessante mas não obrigatório, pode configurar via script também. 
Enviar a URL GitHub do código  

*Utilizado a imagem Ubunto Server 18.14, e utilizado Azure"*

> Passo a passo
```
Baixar o código no github https://github.com/vinivioti/atividadeVagrant.git
abra o Visual Code na pasta do projeto
Execute o comando:$ az login 
Execute o comando:$ Terraform init 
Execute o comando:$ Terraform plan
Execute o comando:$ Terraform apply (-auto-approve)
Execute o comando:$ ssh na VM principal ( pode ser pelo IP statico criado "10.0.2.12")
Execute o comando:$ mysql -u root -p na
Após o comando digite a senha:$ "teste123456"
Então será apresentado a mensagem: "Welcome to the MySQL monitor"

```
