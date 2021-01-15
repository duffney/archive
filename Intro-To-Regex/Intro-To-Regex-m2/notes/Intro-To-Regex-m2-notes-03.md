As I mentioned in the slides negated character classes allow you to specify what you don't want to match.
and the problem I'm hoping to solve with a negated character class is; How do I match a date when the 
delimiating character is different? 

I'm attempting to solve this problem by using both non-negated character classes and
a few negated character classes. Breakig down the expression used on lines 5 through 9 I start off with two 
non-negated character classes that are both looking for a digit. The first one will match the 0 and the
second will match 1 one. next I have the first negated character class. You can tell it's negated by the
carrot symbol right after the opening square bracket. The other character inside this negated class is a space.
Regular expression will interpet this as match any character that is not a space. The pattern of two non
negated classes looking for digits and a negated class looking for antying that isn't a space is repeated
to match the month section of the date. The expression then ends with four non-negated classes looking for
a digit to match. Those four classes will match the year portion of the date.






#The non-negated classes are looking for a range of digits while the
#negated ones are looking for anything that isn't a space.  




so enough about dates, I will now demonstrate how you can split up an email address with Regular expression