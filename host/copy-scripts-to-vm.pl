#!/usr/bin/perl -l
-f$_ and/^.bashrc$/||open(FH,$_)&&($h=<FH>)&&($h=~m'^#!/')and system qq,<"$_" ssh -t $ENV{vm_target} 'cat>ubuntu.rc/host/"$_"',for<*>
