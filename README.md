newpl.pl
=====
Quick Perl programming for experienced lazy developers on small utilities. It will enable your switch from other script languages to Perl in short time without googling. If you believe that 20% of all Perl grammar can support 80% of use as I do, then newpl.pl is your good choice. Personally I will use it to recall key syntax when I have stopped using Perl for a while. newpl.pl will save 10 minutes each time we do language context switch.

Run Environment
---------------
Tested in Perl 5.16 under Windows.

Perl Installation
-----------------
Perl is so famous that you can easily figure out how to download&install it via google. Otherwise just visit below link to save 10 seconds.
    http://www.perl.org/get.html

Module Management
-----------------
Perl is powerful only because there are lots of useful modules. They are free for you, so you must learn to download&install modules.

Install cpanm to make installing other modules easier. You need to type these commands into a Terminal emulator (Mac OS X, Win32, X Windows/Linux)

    cpan App::cpanminus
note: if cpan does not work, try cpan.bat  
Now install any module you can find.

    cpanm Module::Name
Reference: http://www.cpan.org/modules/INSTALL.html


Install newpl.pl
----------------
Download newpl.pl from GitHub to your local disk. Edit newpl.pl with any text editor to overwrite below line with your email or other info as your author name.

    # Configuration Area Start for users of newpl.pl
    _author_ ='Yingjie.Liu@thomsonreuters.com'
    # Configuration Area End

Usage
-----

    Perl newpl.pl -h

Use Cases
-------
generate test.pl without samples.

    Perl newpl.pl test

list all existing samples

    Perl newpl.pl -l

generate test.pl with sample 1 included only.

    Perl newpl.pl test -s1

generate test.pl with sample 1 and 3 included as comment.

    Perl newpl.pl test -s13 -c

By defaule, newpl.pl will submit statistical data to global database for new file generation. In such case, a global newpl.pl ID will be assigned to your test.pl. Your IP address, Author name and Sample Selection will be recorded. Those data will only be used to improve newpl.pl. Use -n to disable it.

Support
-------
mailto: jackandking@gmail.com

