function BlogPreview(container) {
  this.container_ = container;
}

BlogPreview.prototype.show = function(url, opt_noTitle) {
  var feed = new google.feeds.Feed(url);
  var preview = this;
  feed.load(function(result) {
    preview.render_(result, opt_noTitle);
  });
}

BlogPreview.prototype.render_ = function(result, opt_noTitle) {
  if (!result.feed || !result.feed.entries) return;
  while (this.container_.firstChild) {
    this.container_.removeChild(this.container_.firstChild);
  }

  var blog = this.createDiv_(this.container_, "blog");
  if (!opt_noTitle) {
    var header = this.createElement_("h2", blog, "");
    this.createLink_(header, result.feed.link, result.feed.title);
  }

  for (var i = 0; i < result.feed.entries.length; i++) {
    var entry = result.feed.entries[i];
    var div = this.createDiv_(blog, "entry");
    var linkDiv = this.createDiv_(div, "title");
    this.createLink_(linkDiv, entry.link, entry.title.replace("&#8211;", "-"));
    /*
   if (entry.author) {
      this.createDiv_(div, "author", "Posted by " + entry.author);
    } */
    this.createDiv_(div, "body", entry.contentSnippet);
    this.createDiv_(div, "separator-blog-entry", "");
  }
}

BlogPreview.prototype.createDiv_ = function(parent, className, opt_text) {
  return this.createElement_("div", parent, className, opt_text);
}

BlogPreview.prototype.createLink_ = function(parent, href, text) {
  var link = this.createElement_("a", parent, "", text);
  link.href = href;
  return link;
}

BlogPreview.prototype.createElement_ = function(tagName, parent, className,
                                                opt_text) {
  var div = document.createElement(tagName);
  div.className = className;
  parent.appendChild(div);
  if (opt_text) {
    div.appendChild(document.createTextNode(opt_text));
  }
  return div;
}


google.load("feeds", "1");

function latestBlogs() {
 var url = "http://blog.paperstencil.com/rss";
 var blog = new BlogPreview(document.getElementById("blog_latest"));
 blog.show(url, true);
 return false;
}

google.setOnLoadCallback(latestBlogs);

