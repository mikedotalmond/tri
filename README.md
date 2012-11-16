tri
===

A (basic) GPU experiment using Haxe + HxSL, targeting FlashPlayer and Air.

<a href="http://mikedotalmond.co.uk/wp-content/uploads/2012/11/tri/" title="tri" target="_blank" >Example</a>

why?
---
I wanted something that I could use to render a decent number of polygons and update all of the vertices each frame, this is the result.

ByteArray/DomainMemory is used to store the index and vertex buffer data to upload to the GPU; there's a single drawTriangles call per frame that sends the buffers.


can i see?
---
In the <a href="http://mikedotalmond.co.uk/wp-content/uploads/2012/11/tri/" title="tri" target="_blank">example / test</a>
 project the position and colour of 23549 triangles (about 71K vertices) are modified every frame on the CPU. There are no textures in use, only vertex colours being set and moified. 


There's also a little vertex shader action going on. Just because... and, I like HxSL.

As with the desktop build, the Air Android build runs at 60fps while doing that. Additionally, both SWFs have the advanced telemetry flag set, so if your'e on the Adobe Scout pre-release you can have a look at the various metrics and inspect the actionscript calls that are being made.  


from?
---
Based on some Haxe stage3D and HxSL examples;

* http://haxe.org/doc/advanced/flash3d
* http://haxe.org/manual/hxsl
* http://ncannasse.fr/blog/announcing_hxsl