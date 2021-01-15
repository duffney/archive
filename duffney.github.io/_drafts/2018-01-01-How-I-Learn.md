---
layout: post
title:  "A Look Inside My Mind; How I learn"
date:   2018-01-01 13:37:00
comments: true
modified: 2018-01-01
---

Learning is argurably the most important skill you can have. Learning how to learn, has been a background obession of mine for sometime and I don't think I'll ever master it or ever stop improving it. With that said over the years my learning process has drastically improved through trial and error. I'm always on the look out for habits to adopt or tricks to experiment with all of which should improve my leanring process. It feels really weird writing this blog post because I was the kid in school with "learning disabilites". I was in special classes because I couldn't keep up with the rest of the class. The me then compared to the me now is only distinquishable by appearance. There are several reasons for this difference but some of the key reasons are interest, passion, and support. What I'd like to share with you in this post is the methods I use to learn and acquire new skills. Today we are in a constant state of change and there is just no way to keep up with it all. So what do we do? ... focus, we focus.

* TOC
{:toc}

# Gather

Finding new things to learn is easy, but what sources of information are most effective at identifying what to learn? Not to surpisingly, I've found the internet to be the best source for spotting trends. More specifically social media platforms, slack channels, and online forums. I personally use Twitter, reddit, and slack communites to spot these trends. These trends can be new technologies, new tools, and or new techniques, really anything you want to learn. Another way to discover things to learn is by learning new things. Allow me to explain, while diving into something you'll notice that you can go deeper and deepr into a subject thus discovering opporutnites for future learning. An example, would be learning how to write code in a new language and stumble upon a testing frame work for that lauguage. You might not have time to learn it now or you might not even be ready to learn it yet. In either case you should add it to your to learn list. All of this should give you a pretty long list of things to learn. You'll most likely not be able to store that all in your head so I highly recommend you write it down. I've used evernote, onenote, text files, markdown files, etc... to store this list, but the medium that has stuck is a physical notebook. I have an entire section in my notebook dedicated to things to learn. It's a simple line by line list of random stuff I want to learn someday. Other sources include books, blogs, and video training. As I mentioned before learning often leads to more learning. Most sources of information reference other things allowing you to go deeper and deeper into a specific subject. Chosing what resources to learn from is extremely important, quality does matter. I'll dive deeper into that thought next when disucssing how to decide.

_*TD:DR You can get ideas from anywhere, but make sure to write it down. Quality Matters.*_

## My Sources

1. Social Media
    * _follow people doing what you want to do_
    * Twitter is a great place for Technologist
2. reddit
    * _join subreddits for things you wish to learn_
    * [/r/PowerShell](https://www.reddit.com/r/PowerShell/)
3. Slack
    * [powershell.slack.com](http://slack.poshcode.org/)
4. Online Forums
    * [PowerShell.org](https://powershell.org/forums/)
5. Resources (books,blogs,online training,etc...)
    * [Personal Amazon Wishlist](http://a.co/haQ9KUZ)
    * [Books4Work Amazon Wishlist](http://a.co/6Wzyml4)
    * [Pluralsight for Video Training](https://www.pluralsight.com/)
    * Blogs (What ever shows up when I google something for research) _tip: If you keep landing on the same blog, follow the author_


## Sources of Information

# Decide

Deciding for me is by far the most difficult step. In all honesty, I sometimes get depressed when deciding what to learn next. The amount of things I want to do and learn is go great that picking which of them is the most important exhaustes my mind. I'll sometimes take a few weeks to decide what my next focus will be. Because this process is so taxing, I often reach out to peers and mentors to see what they'd suggest I learn. This input helps give me a more balanced view of what's important. I keep a notebook with a list of things I want to learn, as I think about things I want to learn and as I talk to people I add things to this list. I've found slack channels and Twitter to be good ways to reach out to people. So, how do I decide what I'm going to focus on, what am I going to learn next? To answer that question I ask more questions. Here is an example of when I decided to learn [Pester](https://github.com/pester/Pester) a ubiquitous test and mock framework for PowerShell. There were other things on my list to learn, but after running them all through these questions Pester was the clear winner.

## Questions for Filtering What to Learn
* Do my peers know this? 
    * Only 2/10 of my co-workers new it well. 
    * `if ( No ){ You're ahead } else { You're behind }`
* Do I need to know this to complete my projects at work?
    * No
* Is this a skill or trait my mentors have that I do not have?
    * Yes
* Is this technology trending?
    * Yes, it's all over Twitter, blogs and Pluralsight
* How can this be applied? Do I have a usecase for this knowledge? Can I use this at work? Do I want to teach this?
    * Yes, I can apply it do daily coding
    * Yes, I have a usecase by adding tests to all my PowerShell Code
    * Yes, I can use it at work
    * Maybe?
* Will this bring me to the next level?
    * Yes, it will make me a beter a developer. 
    * _If question one is no, my peers don't know this well and question three is yes this is almost always a yes answer_

* Do you have any questions that you ask yourself when deciding what to learn? Please leave them in the comments below.

As you can see from these questions the answer should I learn this was a pretty clear yes and it had been clear for about a year before I decided to buckle down and do it. Throughout that year however, I did try and learn it. I attended user groups presenting on Pester, I read and tried to follow blogs, I even watched a few hour Pluralsight course on it but it didn't stick and to be honest it didn't click yet for me. It wasn't until Adam Bertram released [The Pester Book](https://leanpub.com/pesterbook) that I really understood and started to learn Pester. And this is what I mean by quality matters, Adam wrote a quality book from my point of view, a system administrator. I'll talk more about what makes up a quality resource after on in the post.

# Deconstruct

Most likely the thing you've chosen to learn is broad. The first question that comes to my mind after deciding what to learn is, where do I start? or how do I start?
When faced with these questions, it's best to deconstruct the topic into manageable pieces you can learn. To deconstruct something I use a meta learning method called DiSSS. I picked it up from a book called [The 4-Hour CHEF](https://www.amazon.com/exec/obidos/ASIN/0547884591/offsitoftimfe-20) by Tim Ferriss. Here is what it means. _Sidenote: I don't follow this to a T_

D = Deconstruction
S = Selection
S = Sequencing
S = Stakes

## Reduce through Research

That's a cool acronym, but how do I deconstruct something? Great question, the first step is to reduce it. What are the minimal learning units? Using Pester as the example again, I had no idea what testing code even meant or what Pester looked like. For me the minimal learning unit was to try and figure out what Pester was. This resulted in those failed attempts to learn Pester I mentioned earlier. The first thing I learned was what a test was. My definition of a test is any execution of code that confirmed, validates or debugs logic. Before this I didn't consider running my code over and over again while creating it a test, but it was and Pester's purpose is to automate that effort. The next thing I needed to learn was the Pester synatx, since it's a DSL _Domain Specific Language_ I needed to understand it. This is how you reduce a topic. You learn enough about it to see the next step forward. During this phase in the learning process it's okay to be everywhere jumping around blog to blog, video to video. You are more or less in the discovery phase and it's used to explor the topic not understand it fully.

# Sequencing

Reducing through research should give you a lot of minimal learning units, but sequencing those is the most important element for learning something effectivly. If you stumble upon a high quality resource like I did when I discovered the Pester Book the sequencing is already done for you. Adam did a great job of baby stepping you through the process of learning Pester by starting off with what it is and how it benefits you which is huge. If you can't find a high quality resource you have two options. One, tough it out and try and arrage them yourself or Two, ask around. It's always worth the extra effort to find the best available resource for learning something new. You get the benefit of the countless hours the aurthor put in to make the content digestable. Some topics are to new or niche to have good resources in that case you'll have to do your best to arrange the learning units yourself. The best method for this is trail and error as I did when I first tried to learn Pester. I consumed all I could find on the subject and I did gain some knowledge but it was time consuming and a little frustrating.

## High Quality Resources

A high quality resource is something that takes care of the reducing, the sequencing and to some degree the selection from the DiSSS acronym mentioned ealier. The resource can come in any format a book, a Pluralsight course, or a well written blog post or series of blog posts. When you discover it you should feel as if the gates of knowledge have opened and white light is shining on it. More realistically you should think to yourself this is it, I understand from a high level the table of contents. So how do you find such a resource?

### Searching for High Quality Resources

Finding a high quality resource isn't all that difficult in today's information age. A quick Google search `best regex book` will take you a long way. It get's tricky when what your trying to learn is inbetween beginner and advanced or on a topic that is say spread between system administrator and developement. This is when you have to utalize your social skills... This is what I meant by ask around. Ask peers, mentors or blast the question of socail media to strangers. I've found vauge questions like "What's the best c# resource to learn from?" to be not very effecitve. It's ineffective for a number of reasons one it doesn't provide context to how I want to learn. I learn best fron a well structured book. In that case I should rephrase to "What's the best book for learning c#? That is better but still didn't get me what I wanted. What I really want and I don't know if it exists is "What's the best book for c# for a persom from operations?" See my reason for wanting to learn C# is different than most, I don't want to learn how to create apps I want to create servies and understand .net better to improve my PowerShell skills. 





### Experiment

# Apply

# Teach

# Repeat

but cycle through your interests to keep from burning out