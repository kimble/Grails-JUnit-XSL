Alternative JUnit theme for Grails
==================================

Install instructions
--------------------
Just replace `$GRAILS_HOME/lib/junit-frames.xsl` with the one from this repository (you should probably make a backup first). 

*__Update:__ This is no longer necessarry as it has become a part of the standard Grails distribution! http://grails.org/doc/2.1.1/guide/introduction.html#developmentEnvironmentFeatures* 


Sample screenshot
-----------------

![Report sample showing failed test](https://raw.github.com/kimble/Grails-JUnit-XSL/master/screenshots/failure.png "Failed test")


Browser compability
--------------------
Looks fine in recent versions of Firefox and Chrome.

Todo
--------
I've just started playing with this to get some learn some XSL (man this stuff is verbose when you're used to Groovy!!). The XSL file and the stylesheet has suffered from my lack of XSL experience and would benefit from some refactoring TLC. 
