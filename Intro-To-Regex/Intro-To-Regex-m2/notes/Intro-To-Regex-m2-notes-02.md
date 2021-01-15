Character Class Ranges clip 3

I ended the previous demo by using regualr expression to validate an IP address. 
While that was somewhat useful wouldn't it be even more useful to validate that the ip address 
is within a valid range? Well, that's excatly what I'll do in this next example. 

Starting on line 7, I'm populating a variable called $IPaddresses with a bunch of different ips.
Then on line 9 I'm passing each of them to the match operator and validating them agains the expression
192.168.20.[123456]. This expression will only match if the ip is a valid host ip address for the network
192.168.20.0/29. 

If you're not familair with networking, just know that the only valid ip addresses for this range are
192.168.20.1 through 192.168.20.6. Anything outside that range doesn't belong to that network. I'll go ahead
and run these two lines now and you'll see which IP address are valid for this range.

[RUN CODE]

as it turns out only 192.168.20.1 and 192.168.20.3 are valid, the rest didn't match the expression and
are outside the range of valid host ip addresses. You might be wondering is there a better way to express
all these numbers? and if your thinking there is an easy better way your correct! 

Moving on to the next example, I'm doing the same thing as before validating the IP addresses for the network
192.168.20.0/29, but this time I'm using a range within the Character class. I've replaced the 123456 inside
the Character class with 1-6 which accomplishes the same thing, but is easier to write and read. 


On line 13 I'm re populating the $IPaddresses variable and on line 15 I'm doing the same thing as before 
validating the IP addresses for the network
192.168.20.0/29, but this time I'm using a range within the Character class. I've replaced the 123456 inside
the Character class with 1-6 which accomplishes the same thing, but is easier to write and read. 

I expected to see 192.168.20.1 and .3 but I didn't expect this expression to match .12. .12 is outside
the valid host range and should not of match, but did. The next question is why, why did it match. Let's
run that IP address against the expression and take a look inside the matches variable.

I will cover lookaheads in more detail later in the course, but I wanted to take this opporuntiy to 
show you that the expression I used wasn't wrong, it just was wasn't specific enough.
The reason .12 match was because I didn't say in the expression only match 1-6 if it's the last number.
one way to do that in regualr expression is with a negative lookaheads. This basically checks to see if 
another digit exists and if it does fails the expression. 

don't


In this first example, I'm going to use a range within a Character class to validate host ip address for
the network 192.168.20.0/29. If you're not familair with subnetting, just know that the ip address has to
be between 192.168.20.1 - 192.168.20.6.

A fairly common user naming convention is the first Character of the first name then the full last name. 
What line 11 does is it grabs all the active directory users with get-aduser -filter * and then filters that
output by the user's name with the expression [a-z]bailey. The results of this should be a listing of all
the users who have the last name bailey. The hope here is it also filters out any service accounts etc..
leaving only real user accounts. 


this expression was designed to only match users with the last name baily following the normal
user naming shceme

and the expression I'm using on line 15 is a lower case alphabetic range that is going to evaluate the first
Character of the word REGEX. Since Regex is all capital Characters this expression should fail, but let's
go ahead and run line 15 to find out.  

#<------ REMOVE SHIT FROM DEMO 3