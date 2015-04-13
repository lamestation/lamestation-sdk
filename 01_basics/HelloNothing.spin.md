<p>So let's start with the absolute most basic thing that we can possibly try: a blank file.</p>
<pre><code></code></pre>
<p>Attempting to compile this object results in, well, nothing happening.</p>
<pre><code>Propeller Spin/PASM Compiler &#39;OpenSpin&#39; (c)2012-2014 Parallax Inc. DBA Parallax Semiconductor.
Version 1.00.71 Compiled on Jan 29 2015 19:28:26
Compiling...
HelloNothing.spin
HelloNothing.spin : error : Can not find/open file.</code></pre>
<p>That seems pretty obvious. The spin compiler complains because what else is there for it to do? You haven't written any code yet. This leads us to the first lesson of Spin programming.</p>
<blockquote>
<p><strong>All Spin objects must contain a public function, or a PUB block.</strong></p>
</blockquote>
<p>So let's give the compiler what it wants.</p>
<pre><code>PUB Main</code></pre>
<p>This is the absolute most basic program that can be downloaded to the Propeller. Unsurprisingly, it does absolutely nothing, but hey, at least it downloaded to your board. It's like you're halfway there.</p>
<h1 id="more-with-nothing">More With Nothing</h1>
<p>While we have a program that does nothing, let's see how much more we can do with nothing.</p>
<h2 id="comments">Comments</h2>
<p>Comments are notes that you can leave to yourself or whomever will read your code, explaining how it works, describing what it's for, or maybe just telling jokes.</p>
<p>There are two kinds of comments in Spin:</p>
<ul>
<li>Single line</li>
<li>Multi-line</li>
</ul>
<h3 id="single-line-comments">Single-Line Comments</h3>
<p>Whenever an apostrophe character ( ' ) is used, the rest of the line after it becomes a comment.</p>
<pre><code>this part is code &#39; this part is comment</code></pre>
<p>When you run your program, the comments will be removed, and only the uncommented part will be downloaded to the LameStation.</p>
<pre><code>this part is code</code></pre>
<p>So let's comment up <code>HelloNothing.spin</code>.</p>
<pre><code>&#39; man, this is best code ever!
&#39; more code, code and code.
&#39; cool this code still does nothing!</code></pre>
<p>When it's compiled, the code still ends up as.</p>
<pre><code>PUB Main</code></pre>
<h3 id="multi-line-comments">Multi-Line Comments</h3>
<p>Whenever you add an opening curly brace ( '{' ) to your code, all text that comes after it will be commented out until it reaches a closing curly brace ( '}' ).</p>
<pre><code>{ look at all these comments!
  so commenty; mega comments!
}</code></pre>
<p>It doesn't matter where you put the curly braces either. As long as you don't add them in the middle of code that's supposed to do something, it should compile fine.</p>
<table>
<thead>
<tr class="header">
<th align="left">Bad Code</th>
<th align="left"><code>PUB Ma{jfd93j23rsdfijsd}in</code></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">Good Code</td>
<td align="left"><code>PUB Main {394j39j43433}</code></td>
</tr>
</tbody>
</table>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 01_basics/HelloNothing.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
&#39; man, this is best code ever!
&#39; more code, code and code.
&#39; cool this code still does nothing!
PUB Main
{ look at all these comments!
  so commenty; mega comments!
}

</code></pre>
