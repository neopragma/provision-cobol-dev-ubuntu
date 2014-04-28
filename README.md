# provision-point-of-sale-vm

Provision an instance of Ubuntu Linux with software to support programming exercises for a training course in Test-Driven Development and Object-Oriented Design in Java. These instructions are used by an instructor preparing a VM to be copied and distributed to participants in the class.

## Steps

The instructions assume you will provision a virtual machine with Ubuntu Linux and then install the course project on that instance. This has been tested with Ubuntu 14.04 LTS 64-bit.

### Step 1 - Download Ubuntu iso

Open a browser and navigate to http://www.ubuntu.com. Download the iso for the version of Ubuntu desktop you want to install.

### Step 2 - Create VM

Using the virtualization product you want your students to use, create a VM and install Ubuntu on it. (This procedure has been tested with VMware Player.)

### Step 3 - Apply system updates

Start the VM and ensure it has a connection to the Internet. Apply any available system updates. Use the icon that appears in the Unity launcher or open a Terminal and do it from the command line:

```shell
sudo apt-get -y -f update
sudo apt-get -y -f dist-upgrade
```

### Step 4 - Install git

 Install git.

```shell
sudo apt-get install git
```

### Step 5 - Clone this repo

With git installed, you can load the configuration scripts on the new instance:

```shell
cd
git clone https://github.com/neopragma/provision-point-of-sale-vm
```

### Step 6 - Run the setup script

Run the setup script.

```shell
cd ~/provision-point-of-sale-vm
./setup
```

### Step 7 - Verify the setup

The last thing the setup script does is to run a script named verify. Check the output from verify and see if any of the installation steps failed. If so, investigate and resolve the problems. If you discover a problem with the setup script, fix it.

### Step 8 - Verify the "authorization server" will run

In a Terminal window, navigate to ```~/point-of-sale/credit-authorization/app``` and start the server:

```shell
ruby authserver.rb
```

In a browser, navigate to ```http://localhost:4567````. If the server is running, it should serve a page with the text, ```Credit authorization service```. 

Leave the server running while you complete the configuration and verification of Eclipse.

### Step 9 - Install m2e Eclipse plugin

This manual step is necessary because of a problem in the way the slf4j api bundle is packaged. Headless install using Equinox p2 director fails because it cannot resolve the dependency on slf4j. Manual installation of the m2e plugin is necessary.

Start Eclipse and go to Help => Install New Software... on the top menu bar. Add the repository ```http://download.eclipse.org/technology/m2e/releases```. The name should appear as Maven Integration for Eclipse. Follow the prompts to install the m2e plugin. Restart Eclipse.

### Step 10 - Import the class project

In Eclipse, open the Java perspective. Right-click in the project panel (on the left) and choose Import... Then choose Import existing project into workspace. Navigate to ```~/workspace/point-of-sale``` and import the project.

### Step 11 - Point Eclipse and m2e to the correct version of Java

In Eclipse, Window => Preferences => Java Build Path => Compiler, set the options to Java 1.7.

In Eclipse, [double-check where], set the JRE for Maven to use to Java 1.7.

### Step 12 - Verify the build will run from the command line

In a Terminal window, navigate to ```~/workspace/point-of-sale``` and run:

```shell
mvn clean install
```

The build should run without errors.

### Step 13 - Verify the build will run from within Eclipse

In Eclipse, right-click on the point-of-sale ```pom``` and choose Run As => Maven install from the context menu. The build should run the same as it did when you ran it from the command line.







