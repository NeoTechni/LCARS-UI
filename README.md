B4A can be downloaded here:  
https://www.b4x.com/b4a.html

API keys needed: (I can't give you mine)  

Weather module (used for checking the weather)  
OpenWeatherMap: line 7

Main module (used to read social media feeds of people involved with Star Trek):  
Google Plus: line 274 (no longer works)
Facebook Client ID: line 275
Facebook Client Secret: line 276
Twitter Consumer Key and Secret: line 278

Main module (used for the universal translator):  
Bing: line 2966

Directories:    
Additional Libraries - All the B4A libraries I used, it'd be a real pain to make you download them yourself. Especially since some don't exist, and I made one specifically for the dialer.  
Cardassian Vector Engine - The editor I made for my vector art format, used first in the Cardassian/DS9 animated bridge screens  
LCARS DIALER  
LCARS for Windows - The original VB6 sourcecode/program  
LCARS UI - The one you're probably looking for  
Misc tools used - For some screens, I made a program to handle creation of assets/data rapidly. You may need to manually add some modules as they expect them in a certain place on my hard drive. I included these for historical purposes

History:  
The original LCAR (yes, LCAR. I thought it was LCAR not LCARS back when I started) program I made for Windows using Visual Basic 6. I built a Windows file explorer in the LCARS theme because I wanted to use LCARS on my UMPC (Ultra Mobile PC) which is basically a smaller tablet PC with a touchscreen. A big feature it supported was rotation in software, because rotation in hardware did not work properly on my UMPC (it would rotate the screen, but not the touchscreen coordinates! So you couldn't touch things properly). And since it only used a few colors, all on a black background, I was able to make my own anti-aliasing code which blended the edges of shapes into the background, caching the color gradients for speed. If you click the dot/period button in the bottom left corner, you also get an editor for the circular LCARS from the movies. I sent this program to Michael Okuda's email via his old website, but never got a response. Not that it matters, since he's a Macintosh user and couldn't use it anyway. Something I enjoyed doing when I went to computer stores was load this program on their giant touchscreen monitors. This engine only supports LCARS elbows, buttons (which to the engine are really elbows with no angle to them), a special element (the animated grid when the keyboard is visible) and lists.

Then I became an Android developer. And went to Fan Expo. I saw a bunch of people using the original Galaxy Tab, and a bunch of them had Star Trek programs on it. And all of them looked absolutely terrible. So I thought, I can do better than that! And a cellphone booth was there offering a free Galaxy Tab if I signed up for 2 years. So I signed up. Then I was curious how well Android could handle anti aliasing on it's own, so I made a test program (LCARTEST, which I never got around to changing) that used PNG stencils, to basically draw a black shape, over a colored square. The black would draw the curves of the LCAR buttons/elbows. And since PNGs had 8-bit transparency, I could build the anti-aliasing into the PNG by use of Photoshop. I then ported the code from VB6 (which is why the early code carried over my LCAR mistake...) to get the engine started. With one major change. The old engine only really supported 1 element type (buttons and elbows, I used a hardcoding trick to get the grid showing, and lists were something else entirely) so I added a variable to each element to define it's type. This is what let me expand to support almost a hundred element types. Michael Okuda somehow became aware of my initial app and posted it on his facebook page, and then I signed up to facebook to thank him. One user was upset that I had no zooming options. I thank him for that complaint because that was a VERY valid complaint, especially on Android where the screens went from 800x480 at 4" on my first cell phone (same as my 7" UMPC), to a whopping 1080p ~5" on my Nexus 5. And now there is 4K phones! Because of the race of screen resolutions, I had to make more stencils several times. 

That first phone I mentioned was the Sony Ericcson Xperia Play, the phone with the game controls built in. I supported game controls pretty early, as much as I could. But the big thing, was the SEXPLAY only had 512 MB of internal flash. And to use widgets or live wallpapers, the app had to be installed internally. So I was obsessed with keeping the file size down. I tried to make it download any big files from my web site to the SD card. All PNG files were compressed via tinypng.com, and audio was compressed heavily too. My filesize in the end was only 5 MB, which puts a lot of other Android apps to shame. Especially since my app does about a hundred other things. As I mentioned, this all started with a visit to Fan Expo. I had expected/hoped my app would be very popular, so I built a mode into the wifi detection screen where if it detected my Galaxy Tab in wifi hotspot mode, it would unlock a secret screen (The Omega Directive). I don't know if I ran into anyone at Fan Expo though... So I had to make it unlock another way. (The first scrolling bridge screen you open, one of the elements is randomly selected to unlock the Omega screen)

Then I made the dialer. It wasn't a separate program at first, which (rightfully) annoyed some of my users. Afterall, I was adding some rather invasive permissions. So I forked the code, remove the dialer from the main program, and stripped as much of the main stuff out of the dialer as I could find. This started one of my many fights with Google, as they eventually blocked the ability for third-party apps to answer phone calls. Thus negating a big part of the dialer. Some crappy anti-virus firm also flagged this app for one of the functions which was basically named forward_SMS_to_email, which they felt was nefarious. That was one of my advertised features! And you had to manually set it up yourself! But I digress... I also had to make the "Technis" library in actual Java, as B4A didn't support libraries back then. And I needed code to access your contact list, which couldn't be done in B4A. Man does Java suck! I made the dialer free since it was an addon to the other app, and required it to work. Back then, you couldn't reply to user reviews so I had a lot of people who didn't read the instructions and got annoyed it didn't work (which also means that anti-virus firm didn't actually use the app)

I was obsessed with updating the app. I tried to add something on a weekly basis. I even lost sleep when I went on vacations, if there was a bug I couldn't fix. I even went home early once to fix a bug. Eventually I stopped pushing major updates leading up to my vacations just to be on the safe side. I even made a remote control section, and turns the original VB6 program into the server.

There isn't much else (till the end anway), I kept getting better and better at Android development. Eventually dipping my toes into SNES-level pseudo 3D effects. Cloning some games (though most I made in VB6 already, but added a Star Trek twist), using more and more Android features (live wallpapers, daydream, widgets, even Wear OS and eventually making my own launcher). A big thing was my own vector art code, which made it easy for me to make shapes with curves that could be rendered at any size with high performance. I was making enough money from this, combined with my other job, that I was living pretty comfortably. I was even able to get rid of my OCD of saving money to the extreme.

Then CBS noticed me, my app was after all selling so well that other stores had sent me free hardware to put my app on their marketplaces. I had a massive userbase of over 20,000 (massive for me anyway), and they were awesome, and I miss them dearly thanks to Google Plus shutting down... CBS first asked me to remove some very specific things (logos, names, etc), so I did and sent an email saying I complied. No, that wasn't enough. A lawyer asked me to remove the app entirely. Since I would rather avoid a lawyer, I complied, LCARS died despite Gene Roddenbery putting it in his contract that if anyone makes functional versions of Star Trek tech, they get to use the name. (At least, according to the company that made a functional tricorder)

Then I stripped all the LCARS stuff out of my LCARS app, and started work on the SCI-FI UI. I had hoped it would be popular enough that I'd still make enough money to spend so much of my time programming. But sadly it was never popular, and I spent far too much time for it to be worth my while, so I gave up.In closing, a major chunk of the LCAR module is actually based on VB6 code from a decade prior (the dates have since been lost to time/Windows), and the code B4A was capable of parsing also evolved over time. Which is why some variables are declared like 'dim varname as string: varname = "value"', and others are 'dim varname as string = "value"'. And sadly B4A never got support for optional parameters, so a lot of functions messily reuse parameters. So please be easy on my code, some of it's not my fault, and other parts are the fault of a very-younger me. The reason modules became LCARSeffects2,3,4,5 is cause I made the animated grid in VB6 in the LCAReffects module. And the naming scheme followed. In my SCIFI UI, I have since made my code a lot more organized.

My other apps:

https://play.google.com/store/apps/details?id=com.omnicorp.scifiui&hl=en_CA
SCI-FI UI - Based on the LCARS UI engine, but built around other franchises like RoboCop, Alien, Terminator, etc

https://play.google.com/store/apps/details?id=com.omnicorp.lcarui.launcher
STARBASE LAUNCHER - The launcher I mentioned

https://play.google.com/store/apps/details?id=com.omnicorp.lcar.wear
SCI-FI watchfaces - A bunch of screens ported to Android Wear

https://play.google.com/store/apps/details?id=com.omnicorp.lwp.deadspace
Unitology Hallucination - A Dead Space-themed Live Wallpaper
