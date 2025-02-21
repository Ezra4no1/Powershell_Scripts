# Powershell_Scripts
A dump of different Powershell Scripts I have used for work and personal use.
-----------------------------------------------------------------------------
02/21/2025
All Powershell scripts were designed to run on Powershell ISE, 5.x
While working with thousands of servers in my employment all with different flavors of Windows Server OSes,
I found the default version of Powershell that came with Windows 2008R2 and above would need to work with my
my scripts when a new version of Powershell wasn't installed on the server - hence 5.x and ISE.

When possible, I will use my Powershell session credentials to run a Powershell script during my employment.
Since most of my work was from an Admin workstation, using elevated privileges, it was just easier for me to
use the session credentials than having to be prompted from Powershell to manually enter my credentials. As such 
my scripts are written with this in mind. Times when I needed a script to test service accounts, that script was
written to prompt the user to enter this information.

09/29/2023
This Readme file is a work in progress.

I am not a coder! 
Over the years as I became heavily involved in the world of IT for my career, I found Powershell scripts made my life a lot easier. 
I would spend hours searching the internet for other people's scripts to help make my work easier and better. 

Oddly enough, the collective hours I spent searching online for other people's PowerShell scripts and trying to tweak them for my specific needs
and uses, I could have just sat down and learned Powershell.

This repository will serve as a small and tiny way for me to give back to the internet community for what they helped give to me.
-----------------------------------------------------------------------------
--
About my Powershell Scripts.
----------------------------

--
These scripts worked for me in my environment. 
They may not work for you in your environment for many different reasons.
If they don't run for you, I'll apologize now, but I won't be able to troubleshoot the problem.
The best I can do is point you in the same direction I went through over the years - which is 
Google and other online forums. At the very least you might be able to view my scripts and find
other ways to modify them for your own use or create your own new scripts from the examples of my scripts.

If you are going to use any of my scripts for your own purpose, 
"USE AT YOUR OWN RISK!!"

You will need some working knowledge of Powershell. 
Depending on your environment you may need to have Admin access for the script to function.
You may need to adjust your Windows Execution Policy to run the script or at least know how to work around its security.
You could bring down your entire infrastructure. You could start WWIII - unlikely, but who knows.

--
Where possible, I've tried to add the following to my scripts:

- Remarks
I've tried to add Remarks in my code to make it a bit easier to follow,
However, this is usually an afterthought when I create my scripts. 

- Input\Output
Most of my scripts are designed to carry a large workload, such as checking
a thousand+ servers. As such I created my script to pull its Input from a text file
and to push its output to a CSV file.

- Visual Countdown\Progress of script
I began adding some kind of countdown or progress bar to my scripts to display
on the console when they are running, to help give an indication of how far along
the script is to completion. The last thing you want to do is kill a script
while it's running because you're not seeing a response after a period of
time and think the script froze when it was actually still running.

----------------------------
-----------------------------------------------------------------------------
xx
