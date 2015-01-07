# provision-cobol-dev-ubuntu

Provision an instance of Ubuntu Linux with software to support software development using GNU COBOL. 

## Steps

The instructions assume you will provision a virtual machine with Ubuntu Linux. This has been tested with the following operating systems:

* Ubuntu 14.04 LTS 64-bit

### Step 1 - Download Ubuntu iso

Open a browser and navigate to http://www.ubuntu.com. Download the iso for the version of Ubuntu desktop you want to install.

### Step 2 - Create VM

Using the virtualization product you want to use, create a VM and install Ubuntu on it. This procedure has been tested with the following virtualization products:

* VMware Player 6.0.2 on Ubuntu Linux 14.04 LTS 64-bit
* VMware Player 6.0.2 on Windows 8.1
* VMware Fusion 7 on OS X 10.9.5
* VirtualBox 4.3.20 on OS X 10.0.5

### Step 3 - Apply system updates

Start the VM and ensure it has a connection to the Internet. Apply any available system updates. Use the Software Updater icon that appears in the Unity launcher or open a Terminal and apply updates using the command line:

```shell
sudo apt-get -y update
sudo apt-get -y -f dist-upgrade
```

### Step 4 - Install git

 Install git.

```shell
sudo apt-get -y -f install git
```

### Step 5 - Clone this repo

With git installed, you can load this provisioning project on the new instance:

```shell
cd
git clone https://github.com/neopragma/provision-cobol-dev-ubuntu
```

### Step 6 - Run the setup script

Run the setup script.

```shell
cd ~/provision-cobol-dev-ubuntu
./setup
```

### Step 7 - Verify the setup

The last thing the setup script does is to run a script named verify. Check the output from verify and see if any of the installation steps failed. If so, investigate and resolve the problems. If you discover a problem with the setup script, fix it and make a pull request.

## Sample projects

A couple of sample projects are available. They include bash scripts to run compiles and tests, sample source programs, and a practical directory structure for each project. Those elements may be used as templates to set up new projects.

* https://github.com/neopragma/cobol-unit-test - automated unit testing and functional testing for batch programs
* https://github.com/neopragma/cics-unit-test - automated unit testing for CICS programs
