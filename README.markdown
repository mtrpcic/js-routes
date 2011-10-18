# js:routes #

js:routes is a simple `rake task` that gives you access to your Rails routes on the client side.

# Features #
* Lightweight
* Compatible with Rails 3.1.x
* Generates vanilla JavaScript - no external library requirements
* Supports setting custom filename

# Explanation #

js:routes is a single file you can place into your `lib/tasks` directory to give you access to the `js:routes` rake task.  This task provides your rails-style routes on the client side.

    # First, place the js.rake file in /lib/tasks
    your_app/lib/tasks/js.rake

    # You can generate your routes file by doing the following:
    rake js:routes

    # The above commands will place the routes in your_app/public/javascripts/rails_routes.js
    # You can specify your own filename like so:

    rake js:routes[custom_name.js]

# What does this change? ##

For example, let's say you have a `NotesController` with an update action.  You have a post-it note style interface, and need to update the `position` of a note once the user stops dragging it around the screen.  Your code might look something like this:

    $.ajax({
        url: "/note/" + post_id;
        method: 'PUT',
        data:{
            x: post_x,
            y: post_y
        }
    });

You'll notice the inelegant way that the route is being constructed.  js:routes alleviates this by providing your Rails routes.  The above code becomes much more elegant:

    $.ajax({
        url: Paths.note({id: post_id})
        method: 'PUT',
        data:{
            x: post_x,
            y: post_y
        }
    });

# Hangups #

* The generated routes don't have anything to do with the associated HTTP Verb.  You need to specify that yourself, as usual, and as demonstrated in the example above.
* If a route is not available on the client side, please be sure you've re-run `rake js:routes` to regenerate the JavaScript routes file (It's not automatic!)
* This project is **not** available as a plugin/gem.  This is because it provides no application level functionality, and is very specific to the Rails environment.  Simply clone the file into your `lib/tasks` and you're off to the races

# Copyright and Licensing #
Copyright (c) 2011 Mike Trpcic, released under the MIT license.
