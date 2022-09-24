# Terraform Project

This is my journey to learn Git and Terraform.  I am new to both but wanted to document my journey and have a document that I can reference in the future.  I am on a windows machine for reference.  If you have updates, questions, or I wrote something wrong, please let me know!   

The goal of this project is to use Terraform to install a multi-region network in Azure. 

# Notes
1.	<>  This tells you to put your info inside and delete the <>
2.	 Choco is a site that helps you download software.  It can be used in a bash terminal to go get the software for you.  
3.	 
4.	 
5.	 

# System setup
1.	Git 

    a.	or choco install git

2.	Visual Studio Code 

    b.	or choco install vscode.install

3.	Terraform 

    c.	or choco install terraform

4.	Azure CLI 

    d.	or choco install azure-cli

5.	Azure PowerShell 

    e.	 or choco install azurepowershell

# GIT setup (bash terminal)
1.	git config --global user.name “<Brian>“
2.	git config --global user.email “<Brian@mydomain.com>”
3.	git config --global core.editor “notepad.exe” 
or “atom --wait” or your favorite
4.    git config --global color.ui true (false is black and white)
5.	git config –list (shows configs)

# VS code setup
1.	Download the following 
2.	Docker
3.	Github
4.	Powershell
5.	Azure Tools
6.	Azure Terraform
7.	Azure Account
8.	Azure Storage Explorer
9.	YAML
10.	Markdown All in One


# GitHub setup (web browser)
1.    Log in to GitHub and create a new repository 
2.    You need the link to the code.  The best way is to navigate to the repository and on the code tab there is a dropdown.  Copy the https

# Folder/File setup (bash terminal)
1.	Ls or dir (look where you are located) 
2.	Cd to the dir you want to be
3.	Mkdir (name your dir) (if needed)
4.	Git clone (paste the link from your github repository) 
5.	Git init (creates a dot file) (you wont see it with ls unless you ls -la)
6.	
	
# VS code
1.	Open VS code and select file, open folder
2.	Select file, new file, name it main.tf

# main.tf
1.	The goal of our first Terraform code is to make sure everything is working.  Add the following to the main.tf file you created.  

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "East_US_RG" {
  name     = "East_US_RG"
  location = "East US"
}

	






