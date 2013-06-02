Byakko
===========
Reuben Castelino - projectdelphai@gmail.com
[Byakko Website](http://byakko.herokuapp.com/)

Description
-------------
Byakko is a ruby on rails application that tracks manga releases. You can read or download new manga chapters or follow links to external readers.

### What Byakko is ####

 - Byakko tracks new chapter releases of manga
 - Byakko provides an online manga reader
 - Byakko allows you to download new releases
 - Byakko provides links to external readers (usually Batoto or the scanlators themselves)
 - Byakko exists to provide the aboves services and will never deviate from these. 

### What Byakko isn't ###

 - Byakko isn't an archive. To read old manga, you have to go to the scanlators' websites or to sites such as Batoto.net
 - Batoto isn't a for-profit website. While donations are welcome and monetization may occur in one form or another, all proceeds will always go to server costs and to providing a better reading experience. Always.
 - Batoto isn't a scanlator replacement. Whenever possible, Byakko will try to follow scanlator rules and provide links to scanlator resources.

### Information on this repo ###

This github repo was created primarily as a backup for me and as a way for other developers to view the source code behind Byakko. It is where curious people can see more development-oriented talk and action occur. Feel free to contribute through bug reports, feature requests, or commits.

Future Plans
--------------
Getting new manga through my own service rather than relying on mangaeden's api.
Adding ability to collaborate with scanlators for better support of links and downloads.
Feedback form for user input.
Method to allow scanlators to provide download and online reader links for Byakko.
Method to allow Byakko to custom interact with each manga based on scanlators' wishes.

Developers
-------------

### Helping Out ###
All contributions are encouraged. However, realize that any new features or optimizations must follow the above-mentioned goals. If they do not follow Byakko's "mission statment", they will not be accepted. Byakko is a manga tracker, not a manga jack-of-all trades. There is also no tests so far, because I have never worked with them before (Byakko is my first ruby on rails application). So if anyone is willing to write some tests or contribute whenever possible, that's great. I probably won't be doing it anytime soon.

### API ###
There is an API, but unless there is an overwhelming plea for them, I will not publicly disclose it. Byakko is run on a one-dyno Heroku app and might not be able to support too many requests. If you can find the API in the code, then use it, but try not to barrage me with requests, please. 

### Development environment ###

Not documented yet. Someone please write this.

Changelog
------------

1.0
started writing tests
started a changelog
rewrote users controller
