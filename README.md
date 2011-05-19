AssignByParts
============

Usage
-----

Just a way to clean up our normal way of having multiple input fields for phone numbers,
or social security numbers.

    assign_by_parts :social_security_number, :area => [0, 2],
                                             :group => [3..4],
                                             :serial => [5..8]


In your views you would have something like:

    = form.input :social_security_number_area
    = form.input :social_security_number_group
    = form.input :social_security_number_serial

Installation
------------

To install into a Rails 3 app just add this to your `Gemfile`:

    gem "assign_by_parts"

Enjoy!
