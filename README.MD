<html><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>Installing and Building SPIN</title>
</head>
<body vlink="#800080" link="#0000ff" bgcolor="#FAFAFA">

<b><font size="5" face="helvetica"><p align="CENTER">Installing and Building SPIN<br>
for the X86</p>
</font></b>
<center>
<table width="590">
<tbody><tr><td>
<p>
<font size="4" face="helvetica"><b>Applicability</b></font></p>
<font face="helvetica">
<p>This document is designed for anyone wishing to obtain, build and run
 the X86 version of the SPIN Operating System. The document covers 
setting up your build environment, getting the SPIN sources, building, 
and booting SPIN. Information on other aspects of SPIN can be obtained 
on the web at:<a href="http://www.cs.washington.edu/research/projects/spin/www/"> http://www.cs.washington.edu/research/projects/spin/www/</a>.</p></font>
<p>
<font size="4" face="helvetica"><b>Overview</b></font>
</p><p>
<font face="helvetica">
The first stage of this process is building the SRC Modula-3 release 
3.6.  To do this you will retrieve three tar.gz files via ftp.  You will
 then run m3build and m3ship to build and install Modula-3.  All of this
 is described below.
</font></p><p><font face="helvetica">
Next you will install and build some auxiliary tools that are required 
to build SPIN.  These are available from the SPIN distribution site as a
 single tar.gz file.
</font></p><p><font face="helvetica">The last step outlined in this 
document is building SPIN itself.  This is actually the least 
complicated portion of the entire process.
</font></p><p><font face="helvetica">
At the end of this process you will have a fully built SPIN kernel.  The next step is <a href="http://www-spin.cs.washington.edu/Distro/docs/ix86_bootsetup.html">booting</a> this kernel.
</font>
<font size="4" face="helvetica"><b></b></font></p><p><font size="4" face="helvetica"><b>System Requirements</b></font></p>
<font face="helvetica"><p>
The x86 version of SPIN needs at least a Pentium/PentiumPro class 
processor.  The operating system uses features that are not available on
 468 and below processors.  We have only tried running SPIN on Intel 
Pentium and PentiumPro processors.  Whether SPIN will work with x86 
processors from other vendors is unknown.
<br>
<a href="http://www-spin.cs.washington.edu/Distro/docs/ix86_hardware.html">List of known working hardware</a>.
</p><p>The fully built spin tree takes up <b>~220MB</b> of disk space.  
This is a lot of space but if you are building SPIN on more than one 
machine, you only need one fully built tree.  Other users can get by 
with a subset of the full tree.  This is described later in the 
description of FULLTREE in <a href="#spinvars">below</a>.
</p>
Please note that the version of libc (glibc-2.0.x aka libc-6) that comes
 with some of the newer Linux distributions is not compatible with the 
Modula-3 compiler used to build SPIN.  For this reason you need to use 
as earlier version of Linux that includes libc-5.  Redhat version 4.2 is
 known to work.<p></p>
<hr>
</font><font size="4" face="helvetica"><b><p>Setting Up Your Environment</p></b>
</font><font face="helvetica"><b><p><u>Install Linux</u></p></b>
<p>The build environment for X86-SPIN is currently Linux. This document was prepared using <a href="http://www.redhat.com/">Redhat</a>'s distribution of Linux. This is not to say that other distributions won't provide the necessary environment.</p>
<p><font color="#ff0000">
Please note that the newer version of libc (glibc-2.0.x aka libc-6) is 
not compatible with the Modula-3 compiler used to build SPIN.  For this 
reason you need to use a pre 5.0 version of Linux that includes libc-5. 
 Version 4.2 is known to work.</font></p>
<p>The first thing to do is install Linux on your machine. Be sure to 
install the development tools so that your system has all the libraries 
and binaries for the build environment.</p>
<!--
<P>You will need the static libc files which may not be included in your installation. Look for "/usr/lib/libc.a" and "/usr/lib/libm.a". If these files are not present, you can get them from the <a href="http://velvet.cs.washington.edu/spin/download/download.html">SPIN distribution site</a>.  Retrieve <b>libc.a</b> and <b>libm.a</b> and place them both in <b>/usr/lib/</b>.
/-->
<b><p><u>Install and Build Modula-3 from SRC</u></p>
</b><p>The Modula-3 distribution comes as three tar.gz files.  You can 
either download them from one of the sites listed below or you can 
download them from our site by clicking on the file names a little 
further below.  You should choose the location nearest you.
</p><ul>
<li><a href="ftp://gatekeeper.dec.com/pub/DEC/Modula-3/release-3.6/">gatekeeper.dec.com/pub/DEC/Modula-3/release-3.6/</a>
</li><li><a href="ftp://ftp-i3.informatik.rwth-aachen.de/pub/Modula-3/release-3.6">ftp-i3.informatik.rwth-aachen.de/pub/Modula-3/release-3.6/</a>
</li><li><a href="ftp://src.doc.ic.ac.uk/computing/programming/languages/modula-3/DEC/release-3.6/">src.doc.ic.ac.uk/computing/programming/languages/modula-3/DEC/release-3.6/</a>
</li></ul>
<p></p>
<p>The files are:
</p><center>
<table width="400" border="0">
<tbody><tr><td><b><a href="http://www.cs.washington.edu/research/projects/spin/www/Distro/download/boot-LINUXELF.tar.gz">boot-LINUXELF.tar.gz</a></b></td><td width="10"></td><td> (5.0Mb) </td><td width="10"></td><td> bootstrap archives</td>
</tr><tr>
<td><b><a href="http://www.cs.washington.edu/research/projects/spin/www/Distro/download/m3cc.tar.gz">m3cc.tar.gz</a></b></td><td></td><td> (7.0Mb) </td><td></td><td> compiler back end</td>
</tr><tr>
<td><b><a href="http://www.cs.washington.edu/research/projects/spin/www/Distro/download/m3.tar.gz">m3.tar.gz</a></b></td><td></td><td> (7.3Mb) </td><td></td><td> Modula-3 sources</td>
</tr></tbody></table>
</center>

<p>The rest of these instructions for building Modula-3 are derived from those provided by Digital at <a href="http://www.research.digital.com/SRC/modula-3/html/install-POSIX.html"><b><i>http://www.research.digital.com/SRC/modula-3/html/install-POSIX.html</i></b></a>.</p>
<ol>

<li>Unpack all the archives:</li>
<blockquote>	# gunzip &lt; boot-LINUXELF.tar.gz | tar xf -
<br>	# gunzip &lt; m3cc.tar.gz | tar xf -
<br>	# gunzip &lt; m3.tar.gz | tar xf -&nbsp;</blockquote>
<li>(Optional)<br>Remove the tar.gz files - </li>
<blockquote>	# rm boot-LINUXELF.tar.gz
<br>	# rm m3cc.tar.gz
<br>	# rm m3.tar.gz</blockquote>
<li>Move m3cc to boot-LINUXELF -</li>
<blockquote>	# mv m3cc boot-LINUXELF</blockquote>
<li>Next you have to configure Modula-3 for Linux by editing the template file: <br><b><i>boot-LINUXELF/m3build/templates/LINUXELF</i></b>.  Here is an <a href="http://www-spin.cs.washington.edu/Distro/docs/LINUXELF.html">example template</a>
 with changes already made, use this as a guide for understanding the 
instructions below.  Be sure you edit this file based on your particular
 Linux system.
<p> 
</p><ul>
<li>Define INSTALL_ROOT to be the location where you want Modula-3 installed. By default it is installed in <b><i>/usr/local/</i></b>; this has worked fine for us and there is a little less work during the install if you use the default location.</li>

<li>Define the location of the X libraries. In older Linux distributions, these libraries were stored in the directory <b>"/usr/X11/lib/elf"</b>; in newer distributions, they are stored in <b>"/usr/X11/lib"</b> or <b>"/usr/X11R6/lib"</b>.
 If your libraries are stored in one of the latter directories rather 
than the former one, you should change all (eight) occurrences of the 
former name to the appropriate latter name.</li>

<li>Define the location of your ELF executables.  In older Linux distributions they are in the directory <b><i>/usr/i486-linuxelf/bin/</i></b>; in newer distributions, they are stored in <b><i>/usr/bin/</i></b>. Look to see where the executables <b>ar</b>, and <b>as</b>
 are on your machine.  If these executables are stored in the latter 
directory, you should change the two occurrences of the former directory
 name to the latter name.</li>

<li>Define the name of your gnu C compiler.  In older Linux distributions it was <b><i>gcc-elf</i></b>; in newer distributions, it is named <b><i>gcc</i></b>. If you have a program named <b><i>gcc</i></b>
 in your executable directory (namely, the directory determined in the 
previous step), you should change all (nine) occurrences of the former 
name to the latter name. </li>

<li>Define CC, LINK, and BOOT_CC to point to your c-compiler (either cc or gcc).  These are now set to either <b>"gcc-elf"</b> or <b>"gcc"</b>; change this to include the full path.  For example "/usr/bin/gcc-elf" or "/usr/bin/gcc".</li>

<li>Define MAKELIB to point to your archiver (ar).  This is now set to either <b>/usr/i486-linuxelf/bin/</b> or <b>"/usr/bin/ar"</b>, this may already be correct.  Check the location of <b>ar</b> on your machine and change the definition of MAKELIB if necessary.
</li><li>Define RANLIB to point to <b>ranlib</b>, which converts 
libraries into more efficient random-access libraries.  This is 
currently defined as "touch".  If your machine has <b>ranlib</b>, change this to the full path to <b>ranlib</b> on your machine.</li>

<li>Define ASM to point to your assembler (as).  This is now set to either <b>/usr/i486-linuxelf/bin/</b> or <b>"/usr/bin/as"</b>.  Check to see that this is the location of <b>as</b> on your machine, and make the appropriate change if it is not.
</li></ul>
</li><li>Wheeew...those were some confusing instructions.
</li></ol>
<p>Now you are ready to build.</p>
<ol>
<li>Go to <b><i>boot-LINUXELF</i></b>, run <b><i>./m3boot</i></b>, then run <b><i>./m3ship</i></b>.
 The m3ship step will copy the essential pieces of the bootstrap system 
to the directories (BIN_INSTALL, LIB_INSTALL, ...) specified in <b><i>m3build/templates/LINUXELF</i></b>.</li>  Note that the <b>m3ship</b> command will have to be executed as <b><i>root</i></b>.
<blockquote>	# cd boot-LINUXELF
<br>	# ./m3boot
<br>	# ./m3ship
<br>	# cd ..</blockquote>
<li>Now you should add BIN_INSTALL to your path. For example, if you are installing Modula-3 in <b><i>/usr/local</i></b>, add <b><i>/usr/local/bin</i></b> to your path (if it's not already there). If you're running csh, this is done by adding the following line to your .cshrc file:</li>
<blockquote>setenv PATH $PATH:/usr/local/bin </blockquote>
<p>If you change your .cshrc (or .tcshrc) file, you will need to reload 
it into your shell, and then run "rehash" to notify the shell of the 
changes to PATH.</p>
<blockquote># source ~/.cshrc
<br># rehash</blockquote>
<li>At this point you have installed the Modula-3 compiler and driver. 
If everything went well and if you are pressed for space, you can now 
delete the bootstrap directory:</li>
<blockquote>	# cd ../<br>
            	# rm -rf boot-LINUXELF</blockquote>
<li>By default, the release is configured to build a large collection of packages. You only need to build the <b><i>m3core</i></b> and <b><i>libm3</i></b> libraries. In the file <b><i>m3/src/m3makefile</i></b>, comment out the <i>BuildChunk</i> lines associated with packages other than <b><i>m3core</i></b> and <b><i>libm3.</i></b></li>
<p>
</p><li>Go into the Modula-3 source directory and run m3build:</li>

<blockquote>	# cd m3
<br>	# m3build
</blockquote>
</ol>
Congratulations, you are done building SRC Modula-3 release 3.6.

<b><p><u>Installing and Building the bsdtools</u></p>
</b><p>Now you need to get the Linux-&gt;FreeBSD cross development 
tools.  Some of these were created here at the UW, others might be 
available from the internet.  Again, this step is only needed as long as
 we are doing development on Linux.  In the future this will not be a 
requirement.  These tools are available as a single tar.gz file from our
 distribution site.

</p><ul>
<li>Download the file: 
<table width="400" border="0">
<tbody><tr><td><b><a href="http://www.cs.washington.edu/research/projects/spin/www/Distro/download/bsdtools.tar.gz">bsdtools.tar.gz</a></b></td><td width="10"></td><td> (3.7Mb) </td><td width="10"></td><td> cross development tools</td>
</tr></tbody></table>
</li></ul>
<ul>
<li>Unpack this file:

<blockquote>	# gunzip &lt; bsdtools.tar.gz | tar xf -</blockquote>
</li></ul>
<ul>
<li><i>(Optional)</i> Remove the tar.gz file:

<blockquote>	# rm bsdtools.tar.gz</blockquote>
</li></ul>
<ul>
<li>Change to the bsdtools directory:

<blockquote>	# cd bsdtools</blockquote>
</li></ul>
<ul>
<li>If you installed Modula-3 in the default location, <b><i>/usr/local/,</i></b> then you can skip this step and go to the next.
<p>If you didn't install Modula-3 in <b><i>/usr/local/</i></b>, then in the <b><i>bsdtools/Makefile:</i></b>

<table><tbody><tr>
<td align="RIGHT">Change: </td> <td>BUILDDIR=/usr/local</td>
</tr><tr>
<td valign="TOP" align="RIGHT">To: </td> <td>BUILDDIR=<b>YOUR</b> Modula-3 build directory<br>
(This is the same as INSTALL_ROOT in the LINUXELF template file above).
</td>
</tr></tbody></table>
</p></li></ul>

<ul>
<li>Build the bsdtools: (<i>You will have to perform this operation as <b>root</b></i>)

<blockquote># make</blockquote>

<p>This will create the following executables and place them in <b><i>/usr/local/bin/</i></b> (unless you changed your "Makefile" above).
</p>

<table width="400" cellspacing="0" cellpadding="3" border="0">
<tbody><tr><td width="25%" valign="TOP">
<p><font face="helvetica">bsd-ar</font></p></td>
<td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-as</font></p></td>
<td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-cc</font></p></td>
<td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-cc1</font></p></td>
</tr>
<tr><td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-config</font></p></td>
<td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-cpp</font></p></td>
<td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-ld</font></p></td>
<td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-nm</font></p></td>
</tr>
<tr><td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-ranlib</font></p></td>
<td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica">bsd-size</font></p></td>
<td width="25%" valign="TOP">
<font face="helvetica"></font><p><font face="helvetica"></font></p></td>
<td width="25%" valign="TOP">
<p>&nbsp;</p></td>
</tr>
</tbody></table>
<p>
This also copies three library files into <b><i>/usr/local/lib/</i></b> , <b><i>libc.a</i></b> and <b><i>libm.a</i></b>, <b><i>crt0.o</i></b>.
</p>
</li></ul>

<ul>
<li><i>(Optional)</i>  You can now remove the <b><i>bsd-tools</i></b> source directory.

<blockquote>	# cd ..
<br>	# rm -rf bsdtools</blockquote>
</li></ul>
<!--
<UL>
<LI>Change directories to <b><i>/usr/local/bin</i></b> or the directory you specified in the Makefile above.

<blockquote>&#9;# cd /usr/local/bin</blockquote>
</LI></UL>
<UL>
<LI>Create a new directory named <b><i>LINUXELF</i></b> and change to this new directory:

<blockquote>&#9;# mkdir LINUXELF
<br>&#9;# cd LINUXELF</blockquote>
</LI></UL>
<UL>
<LI>In this new directory you want to create symbolic links to all of the standard Linux versions that correspond to the <b><i>bsd-*</i></b> executables you created above:

<BLOCKQUOTE>&#9;# ln -s /usr/bin/ar ar
<BR>&#9;# ln -s /usr/bin/as as
<BR>&#9;# ln -s /usr/bin/cc cc
<BR>&#9;# ln -s /lib/cpp cpp
<BR>&#9;# ln -s /usr/bin/ld ld
<BR>&#9;# ln -s /usr/bin/nm nm
<BR>&#9;# ln -s /usr/bin/ranlib ranlib
<BR>&#9;# ln -s /usr/bin/size size
<BR>&#9;# ln -s /usr/bin/strip strip</blockquote>
</LI></UL>
/-->

<hr>
</font><b><font size="4" face="helvetica"><p>Install and Build SPIN</p>
</font></b><font face="helvetica"><p>

<b><u>Install</u></b>
</p><p>If you already downloaded the SPIN sources you can skip down to the <a href="#spinvars">Pre-Build Modifications</a>.  For the rest of these instructions,  I'll pretend that the SPIN source tree will be installed in <b><i>/home/myspin/</i></b>.
</p><ul>
<li>Select where you want SPIN to reside on your system.
<blockquote>	#cd /home/myspin</blockquote>
</li></ul>
<ul>
<li>Get the file <b><i>spin.XX.tar.gz</i></b> from the SPIN <a href="http://www.cs.washington.edu/research/projects/spin/www/Distro/docs/downloadInfo.html">distribution</a> page, and  place it in the directory you selected above; in our example this is <b><i>/home/myspin</i></b>.  (Here XX is a release number).
</li></ul>
<ul>
<li>Unpack the SPIN sources:
<blockquote>	# gunzip &lt; spin.XX.tar.gz | tar xf -<br>
</blockquote>
</li></ul>


<p>
<b><u>Directory Structure</u></b>
</p><p>
As an example, I'll pretend that the SPIN sources are installed in <b>/home/myspin/</b>.
</p></font><p><font face="helvetica">
This is what your SPIN tree should look like at this point.
</font>
</p><pre>                         /home/myspin
			          |
			        spin
			          |
           ------------------------------------------------------------
	  |           |         |	 |	     |	       |       |
    various files   mke.conf    doc/    local/    kernel/    user/  x86_docs/
   
</pre>
<font face="helvetica">
<p>
<b><a name="spinvars"></a></b></p><p><b><a name="spinvars"><u>Pre-Build Modifications</u></a></b></p>

<p>
</p><ul>
<li>Edit the file: <b>/home/myspin/spin/make.conf</b>.
<p>There are seven variables that you will need to define according to 
the way you set up your system. You may need to install and configure 
your <a href="http://www-spin.cs.washington.edu/Distro/docs/ix86_bootsetup.html#nfs">nfs server</a> before you do this so that you know what values to use. Here are the variables and a description of their functions.

<table>
<tbody><tr>
<td valign="TOP"><font face="helvetica">
<p><b>MOUNT_POINT</b></p></font></td>
<td><font face="helvetica">
</font><p><font face="helvetica">This is the nfs mount point you export to the machine where you will boot SPIN. We refer to this machine as a <a href="http://www-spin.cs.washington.edu/Distro/docs/ix86_bootsetup.html#crash">crashbox</a>.
 This will be the top-level directory underneath which your SPIN tree is
 located. For example, if your SPIN sources are located in <b><i>/home/myspin/spin</i></b> then <b>MOUNT_POINT=/home</b>.</font>
</p></td>
</tr>
<tr><td valign="TOP"><font face="helvetica">
<b></b></font><p><font face="helvetica"><b>MOUNT_PAD</b></font>
</p></td>
<td><font face="helvetica">
</font><p><font face="helvetica">This is the path from MOUNT_POINT to the directory that contains your <b>spin</b> tree. For example, if you unpacked your SPIN sources in <b><i>/home/myspin/</i></b>, <b>MOUNT_PAD</b> is the empty string, that is, <b>MOUNT_PAD=</b>. However, if your source tree is further removed from MOUNT_POINT for example, if you unpacked your SPIN sources in <b>/home/mydir/myspin/</b>, then <b>MOUNT_PAD=mydir/</b>(and MOUNT_POINT=/home). DON'T FORGET THE TRAILING "<b>/</b>" IN THE SECOND CASE.</font>
</p></td>
</tr><tr>
<td valign="TOP"><font face="helvetica">
<b></b></font><p><font face="helvetica"><b>FETCH_METHOD</b></font>
</p></td>
<td><font face="helvetica">
</font><p><font face="helvetica">This determines how the initial extensions are fetched at boot time. By default this is set to <b>http</b>. If you don't wish to set up and configure an <a href="http://www-spin.cs.washington.edu/Distro/docs/ix86_bootsetup.html#http">http server</a> then you may want to change this to <b>nfs</b>. Even with the default setting only the initial fetch is done via http, the rest via nfs.</font>
</p></td>
</tr><tr>
<td valign="TOP"><font face="helvetica">
<b></b></font><p><font face="helvetica"><b>HTTP_ADDR</b></font>
</p></td>
<td><font face="helvetica">
</font><p><font face="helvetica">This defines the IP address of the http
 server you will use to fetch extensions during and after booting SPIN. 
 In the two-machine scenario this will be the IP address of your 
development (Linux) machine.  It is not absolutely necessary to use an 
http server for this purpose as it can all be done via nfs.  See the <a href="http://www-spin.cs.washington.edu/Distro/docs/ix86_bootsetup.html#http">boot set-up page</a> for details.</font>
</p></td>
</tr><tr>
<td><font face="helvetica">
<b></b></font><p><font face="helvetica"><b>HTTP_PORT</b></font></p></td>
<td><font face="helvetica">
</font><p><font face="helvetica">The port number for the  http server identified above. </font></p></td>
</tr><tr>
<td valign="TOP"><font face="helvetica">
<b>INSTALL_DIR</b></font>
</td>
<td><font face="helvetica">
<p>This is the path to your Modula-3 build directory.  It is the same as
 INSTALL_ROOT in the LINUXELF template file above.  If you installed 
Modula-3 SRC in the default location this will already be defined 
correctly as <b>INSTALL_DIR=/usr/local</b>.</p></font></td>
</tr><tr>
<td valign="TOP"><font face="helvetica">
<b>FULLTREE</b></font>
</td>
<td><font face="helvetica">
</font><p><font face="helvetica">This variable describes the location of
 a fully built SPIN tree.  If you are building the entire SPIN tree on 
your machine, you can use the default definition - <b>FULLTREE=$(THISTREE)</b>.
  If you are not building the full SPIN tree and you expect to use some 
portion of a remote, fully-built tree, you will need to define <b>FULLTREE</b>
 to be the path to this remote tree.  This variable specifies where to 
find those portions of the tree that you don't have locally.  The entire
 tree must be built on at least one node on your network.</font>
</p></td>
</tr><tr>
<td colspan="2"><font face="helvetica">Take a look at an <a href="http://www-spin.cs.washington.edu/Distro/docs/makeconf.html">example make.conf</a> that is based on the following environment parameters.
<ul><li>The <b><i>spin</i></b> directory is located in <b><i>/home/myspin</i></b>.
    </li><li>The development (Linux) machine's IP address is 128.95.2.184.
    </li><li>Modula-3 was installed in the default location (/usr/local).
</li></ul>
</font>
</td>
</tr></tbody></table>
</p></li></ul>
<b></b><p><b><u>Build SPIN</u></b>&nbsp;</p>
<p>
</p><ul>
<li>Change directories to <b><i>spin</i></b> and type make!<p></p>
<blockquote>	# cd /home/myspin/spin
<br>	# make </blockquote>
</li></ul>
<p>
The next step is to perform some <a href="http://www-spin.cs.washington.edu/Distro/docs/ix86_bootsetup.html">set-up</a> prior to <a href="http://www-spin.cs.washington.edu/Distro/docs/ix86_boot.html">booting</a> your kernel.</p>
<p>
</p><hr>
<b><u>Cleaning Commands</u></b>
<p>
<b><font color="#ff0000">Note: This is not part of building SPIN</font></b>.
</p><p>
</p><ul>
<li>To remove all files created as a result of building:
<blockquote>#make clobber</blockquote>
</li><li>To remove all files created as a result of building while keeping those files necessary for building other parts of the system:
<blockquote>#make clean</blockquote>
This command will remove all intermediate generated files in the local 
and kernel trees.  The object files are not removed in the user tree 
because they are loaded as extensions.  The programs built in local 
remain in local's bin directory and the kernel images remain in their 
build directory.<p>
</p></li><li><b>make clean</b> in any subtree will remove only the platform-specific objects and binaries in that subtree.
</li></ul>

<center><a href="mailto:spin-support@cs.washington.edu"><font size="2">Questions/Comments</font></a></center>
<hr>
<font size="2">
<p>Copyright (c) 1997 The University of Washington. All rights reserved.
</p>
</font>
</font></td></tr>
</tbody></table>
</center>
<font size="2" face="helvetica"><p>	</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>		</p></font>

</body></html>