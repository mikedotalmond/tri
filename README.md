tri
===

A (basic) GPU experiment using Haxe + HXSL, targeting FlashPlayer and Air.

I wanted something that I could use to render a decent number of polygons and update all of the vertices each frame, this is the result.

In the example/test project the position and colour of 23549 triangles (about 71K vertices) are modified every frame. There are no textures in use, only vertex colours being set and moified. There's also a little vertex shader action going on, just because... and, I like HXSL.

ByteArray/DomainMemory is used to store the index and vertex buffer data to upload to the GPU; there's a single drawTriangles call per frame that sends the buffers.


Based on some Haxe stage3D and HXSL examples;
http://haxe.org/doc/advanced/flash3d
http://haxe.org/manual/hxsl
http://ncannasse.fr/blog/announcing_hxsl