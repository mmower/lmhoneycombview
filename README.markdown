# LMHoneycombView

by Matt Mower &lt;self AT mattmower DOT com&gt; - http://matt.blogs.it/  
Copyright (c) 2008 LucidMac software  http://lucidmac.com/  
Released under the MIT license (see LICENSE) 

# Overview

This control is a Cocoa NSView subclass that presents a honeycomb made up of interlocking columns of regular hexagons ("hex cells") that can be selected using the mouse.

<div class="thumbnail"><a href="http://skitch.com/mattmower/1kps/window"><img src="http://img.skitch.com/20080801-pmtbgm8twr8i4i4753f3j2mhrd.preview.jpg" alt="Window" /></a><br /><span style="font-family: Lucida Grande, Trebuchet, sans-serif, Helvetica, Arial; font-size: 10px; color: #808080">Uploaded with <a href="http://plasq.com/">plasq</a>'s <a href="http://skitch.com">Skitch</a>!</span></div>

The honeycomb view draws cell data from a dataSource that follows an included protocol and is quite flexile. The cell class provides basic drawing and can be extended to customise the appearance of cells.

I originally wrote this control as part of an application I am building. There was enough interest in how it worked that I spent some time extracting a generic honeycomb view control and re-wrote my application to use it. It's broadly 'good enough'.

# How to use

You'll need to build a working version of the control. This can either be done by building it as a framework and including it on your system, add the sources to your directly to your own application, or (as I do) building it as a private framework in your app. XCode is a bit annoying but you can make this work without too much trouble.

Once you have the framework just add an NSView object to your nib file and set the class to LMHoneycombView. You will then need a dataSource that provides cells to the view. Implement the LMHoneycombMatrix protocol in one of your classes and set this to be the dataSource of the view. The dataSource decides how many columns & rows the view has and the view will then pull LMHexCell objects from the dataSource to fill it.

Selection events are dispatched to both the data model and any delegate of the view and include the selected hex cell. LMHexCell can hold a data object and can be subclassed to offer additional functionality.

# Issues & follow-ups

* This control was built from an app that uses Objective-C garbage collection and probably won't work without it. It's unlikely to be much work to make it a dual-framework but it's not important to me right now.

* I've swapped around the drawing code and responsibilities a few times. I'm still not sure it's right yet. I toyed with making the cell a protocol as well and caching the NSBezierPath's in the view itself but felt that extending the cell was likely (I will want custom cell drawing in my own application) making it a reasonable class in itself.

* In my application the grid is 17 columns of 12 cells each. This control was originally not a discrete control but was extracted from the application where lots of stuff was hard wired. I've spent some time looking at the geometry and I think it is now generic. 

* A pretty major issue is to do with resizing. The control draws regular hexagons which are wider than they are tall this means that resizing the control can end up with either a lot of blank space or hexagons being "cut off". At this point I don't know of a means to constrain the aspect ratio of a specific control in a resizing operation - patches welcome!

* Drawing efficiency. The cells are responsible for drawing themself onto the view which is neat and allows cell classes to be customised to draw cells differently (e.g. to put text in them). At present the cell makes a number of calls back to the view to retrieve drawing related information such as border color, selected colour, border thickness and so on. Each of these calls is made for each cell. Passing this information in a struct would be a relatively simple optimisation.

* Hit detection uses the brute force method of querying each cell in turn to see if the mouse down event occurred within it's NSBezierPath. In practice this has not proved too slow for a grid of 204 cells but could probably be optimized using some simple heuristics to narrow down the range of possible cells.

* It shouldn't be too hard to add an Interface Builder palette for the hex view. It shouldn't be too hard but of course the stuff you have to do is a little daunting so this may take a while.

# Getting in touch

If you find this control useful please drop me a line (self AT mattmower DOT com) and let me know how you're using it. I'd welcome patches to address any of the issues raised above or that improve the control generally.
