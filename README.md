Prerequisites for the Project
=============

Custom version of NS-3 and specified version of ndnSIM needs to be installed.

The code should also work with the latest version of ndnSIM, but it is not guaranteed. We have developed the project in ndnSIM 2.6. You need to fix NFD include files. In order to fix NFD include files for ndnSIM scenario template, please check out ndnSIM email repository. 

    mkdir ndnSIM
    cd ndnSIM

    git clone https://github.com/named-data-ndnSIM/ns-3-dev.git ns-3
    git clone https://github.com/named-data-ndnSIM/pybindgen.git pybindgen
    git clone -b ndnSIM-2.6 --recursive https://github.com/named-data-ndnSIM/ndnSIM ns-3/src/ndnSIM

    # Build and install NS-3 and ndnSIM
    cd ns-3
    ./waf configure -d optimized
    ./waf
    sudo ./waf install

    # When using Linux, run
    # sudo ldconfig

    # When using Freebsd, run
    # sudo ldconfig -a

    cd ..
    git clone https://github.com/named-data-ndnSIM/scenario-template.git my-simulations
    cd my-simulations

    ./waf configure
    ./waf --run scenario

After which you can proceed to compile and run the code

For more information how to install NS-3 and ndnSIM, please refer to http://ndnsim.net website.

Compiling
=========

To configure in optimized mode without logging **(default)**:

    ./waf configure

To configure in optimized mode with scenario logging enabled (logging in NS-3 and ndnSIM modules will still be disabled,
but you can see output from NS_LOG* calls from your scenarios and extensions):

    ./waf configure --logging

To configure in debug mode with all logging enabled

    ./waf configure --debug

If you have installed NS-3 in a non-standard location, you may need to set up ``PKG_CONFIG_PATH`` variable.

Running
=======

Normally, you can run scenarios either directly

    ./build/project

or using waf

    ./waf --run project

If NS-3 is installed in a non-standard location, on some platforms (e.g., Linux) you need to specify ``LD_LIBRARY_PATH`` variable:

    LD_LIBRARY_PATH=/usr/local/lib ./build/<project

or

    LD_LIBRARY_PATH=/usr/local/lib ./waf --run project

To run scenario using debugger, use the following command:

    gdb --args ./build/project


Running with visualizer
-----------------------

There are several tricks to run scenarios in visualizer.  Before you can do it, you need to set up environment variables for python to find visualizer module.  The easiest way to do it using the following commands:

    cd ns-dev/ns-3
    ./waf shell

After these command, you will have complete environment to run the vizualizer.

The following will run scenario with visualizer:

    ./waf --run project --vis

or

    PKG_LIBRARY_PATH=/usr/local/lib ./waf --run =project --vis

If you want to request automatic node placement, set up additional environment variable:

    NS_VIS_ASSIGN=1 ./waf --run  project --vis

or

    PKG_LIBRARY_PATH=/usr/local/lib NS_VIS_ASSIGN=1 ./waf --run project --vis

Compile Attack Scenario and Graphs
=====================
Project compile 
-----------------------
compile the scenario "project" first. 
./waf 

For simple project run. For .py virtualise please add --vis

./waf --run=project 

Project run
-----------------------

 Project scenario run=10 times for each cache algorithm. The results can be found at /results/attackISP (note: may take some days to finish)
 
./run.py -s attack-isp


Building graphs
-----------------------
Building graphs for the project. Please check out R package dependencies first. The .pdf graphs can be found at /graphs/pdfs/attackISP

./run.py -p attack-isp 

Cache hit Ratios by Algorithms Graph 
-----------------------
Cache hit ratio graps combined algorithms from all gw routers with min. max.  and average values. 

./run.py -p ratios-isp 

Cache hit Ratios  vs. Adversaries Graph 
-----------------------

min. max. cache hit ratios versus time and cache hit ratios versus number of adversaries. 

./run.py -p attacker-isp // 
