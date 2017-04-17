# Paperstencil

A crossover between Wordprocessor and Web form.

Paperstencil helps enterprises to roll-out data collection solutions, contracts, signatures, payment related solutions of their business needs in few minutes.

Wordprocessors such as "MS Word" are good for constructing documents. Web forms are good at validating and capturing user input. Meet "Paperstencil", a cross over product between Wordprocessor and Web form.

### Mixing words and form elements
![Mixing words and form elements](https://s3.amazonaws.com/paperstencil/assets/wordprocessor.gif)

### Page layout
With Paperstencil, text or form element can be positioned at any part of page by using table (and nested tables). Table border shall be configured to be hidden.

![Mixing words and form elements](https://s3.amazonaws.com/paperstencil/assets/layout.gif)

## Features

* Create "PDF Form" like natural looking document without external plugins.
* Validate and capture user signature and other user inputs such as address, email, date etc.
* Constructed documents shall be viewed on both Desktop and Tablets without external plugins.
* Constructed document shall be shared as web link, thus making it easy to embed in other web assets and email.
* Table/Nested tables make it easy to structure custom page layouts.
* Accept payments (Work in progress - Stripe integration?)

## Demo / Tour
Go to [http://www.paperstencil.com/demo](http://www.paperstencil.com/demo) to experience paperstencil in action.

## Hosted version
Hosted version of paperstencil is available at [paperstencil.com](http://www.paperstencil.com/)

## Technology

Requires **ruby 2.1.0** and **rails 4.1.0**

<u>General config files :</u>

* config/database.yml - Database settings
* config/paperstencil.yml - Application related config
* Create \<\<HOME_DIR\>\>/.paperstencil/secret.yml based on config/secret_template.yml - Secret keys required by the application.

<u>Production config files :</u>

* config/deploy/nginx.conf - General nginx config.
* config/deploy/paperstencil.com - Nginx config for Paperstencil.com.
* config/god/unicorn.god - Unicorn config for god, the process manager.
* config/deploy.rb - Capistrano deploy config for Paperstencil.com.

## License
Apache License, Version 2.0


**Cheers!**


    
