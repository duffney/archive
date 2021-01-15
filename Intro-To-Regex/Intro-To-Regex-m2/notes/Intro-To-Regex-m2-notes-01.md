Before I dive into the rest of the demo, I'm going to walk through the grey example used previously.
Just to reset the scene the problem I'm trying to solve is. How do I craft a single expression to match two
potential spellings of the word grey? One spelled with an a and the other with an e.

If you look further into the problem what I'm really wanting regular expression to do is allow an a or an e at 
the third character position. When you put it in those terms, it makes it easy to solve. The answer to that
question is of course a character class. As you see on line 5, starting at the third character position
is the opening square bracket followed by the two character I'm allow a and e then a closing square bracket.

As I execute line 5, pay special attention to the output. 

Did you notice it didn't return a true or false?
It simply returned the matched results to the console. If I take a look inside the $matches variable, it
isn't populated either. How strange.... The reason for all this is that I passed two different strings
to the -match operator. When you do this it simply runs the expression against the string and outputs
it only if it matches. If I added another string to line 5 that didn't match and ran it again only
the two versions of grey would be output. This is just something to keep in mind when working with the
-match operator. 

You might now be wondering so what happens when you have both versions of the word grey in the same string?
Great question, line 7 demonstrates this. I'll go ahead and run this and you'll find out what happens.

This is a little closer to what I expcted, it returned true. Now I'll check to see if $matches was populated.

so.... $matches was populated, but it only has one match. Long story short, the match operator only looks for
one match hence the name match not matches. To find more than one match you could use something like a repeator,
but I'll cover those in an upcoming module. The other way you could do this is by using the select-string cmdlet.

Line 11 demonstrates this for you. It has a single string which contains both spellings of the word grey.
It then pipes that string to the select-string cmdlet. The -pattern parameter is specified followed by the
regular expression that will be used against the string. Then, the -all parameter is used to find all matches.
Lastly, all of that is piped to a foreach-object alais the percent sign and then the keyword matches is used to
call out all of the matches select-string found. 

When I run this, you'll see two match objects returned. One for each varation of the spelling grey. Select-string
comes in handy when dealing with a large blob of text and you want to parse it. Moving on now, let's take a look
at using regular expression to discovery active directory cmdlets.

Lines 15 and 17 are using get-command and where-object to find all the get and set cmdlets within the active
directory module. 

Line 19 combines that search by using a character class. Since Get and Set both end in et
all you need to do is use a character class to handle the first character which can be either an e or a s.

When I run line 19 I'll get all the get and set cmdlets from the active directory module, but to confirm it
worked properly. I'll run lines 21 through 23. This gets all the get and set cmdlets adds them together then
compares the count to the results of the character class search I previously execute.

[execute code]

as you can see the result is true they are equal.

In this next example which starts on line 26. I'm using the -replace operator to remove invlaid character from
a user's name. Taking a closer look at the expression, I'm using a character class to say if found replace all
these invlaid special character with nothing. Since these are all special character I couldn't just use a range
I had to list them all out. The results of running line 26 is a valid user name, you could then use to create
an active directory user account with.

The last example I have before moving on to character class ranges is validaing an IP address with regular
expression. Line 30 gets the IPv4 address of the server and stores it to a variable $ipaddress. Taking a look
inside the variable, you can see the address is 192.168.1.76. 

Line 34 shows you one way you might valid this address. Since this IP has two digits in the last octet 76. You'll
need two character classes. The first will match the 7 and the second will match the 6. Looking closer at the 
expression on line 34. It is saying a valid ip address starts with 192.168.1 and can end with any value bewteen
00-99. If you're thinking there has to be an easier way to list out all these number, there is and you'll learn How
in the next demo.