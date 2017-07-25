[![Coverage Status](https://coveralls.io/repos/github/ehainer/docusign/badge.svg?branch=master)](https://coveralls.io/github/ehainer/docusign?branch=master)
[![Build Status](https://travis-ci.org/ehainer/docusign.svg?branch=master)](https://travis-ci.org/ehainer/docusign)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

# Docusign

Trying to simplify the Docusign creation process and making the Docusign REST api more accessible for future use.

**Note: This gem is used on a different project and will likely only ever be updated as needed to support that project... unless I happen to become overcome with boredom and decide to implement a bunch more features, and can tolerate trying to decrypt Docusign's API documentation for more than 3 minutes.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'docusign', '~> 0.1.0'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install docusign

## Usage

On any model you want to treat as a "signer" of an envelope/template, add `documentable` to create an association to both envelopes and templates:

```ruby
class User < ApplicationRecord

  documentable

end
```

With the new `envelopes` and `templates` association you can now create embeddable Docusign documents with signers (among other things), like so:

```ruby
@user = User.first
# Email subject is a required field, blurb is not. Both parameters translate to the email subject/body of the delivered document
@user.envelopes.create(email_subject: 'New Document', email_blurb: 'Welcome to your new document', status: :sent)
```

Note: The `status` parameter must be set to `sent` in order to actually embed the document. If not set, the default is a draft status, in which no signers may view the document. It is possible to create an envelope ahead of time and "sending" it later by calling `send!` on the instance when ready to embed/send the email.

### Determining the Default Signer

If no signer information is provided (`add_signer` is called with no arguments), a method named `to_signer` will be called automatically (or tried, actually, so it fails gracefully) on the polymorphic association (i.e. - in the above example, on the `User` instance). This method should return a hash of signer data that conforms to the [signer](https://docs.docusign.com/esign/restapi/Envelopes/Envelopes/get/#/definitions/signer) definition. Keys in the hash can be specified either camelCase as per the Docusign documentation, or snake_case.

If the `to_signer` method does not exist or does not return a proper hash, the document will fail to save, and therefore not be created within Docusign. The resulting errors will be found on `<document>.errors`

### Customizing the Document

Optionally, you can pass a block to either the `create` or `build` method of envelopes or templates, and use the argument passed to it to further tailor the document to your needs.

```ruby
@user = User.first
@user.envelopes.create(email_subject: 'New Document') do |e|
  # Define the file you want to use as the document to sign.
  # You can provide as many file paths as you'd like in this method, or call it multiple times
  e.add_document '/path/to/the/pdf/document.pdf'
  
  # Without arguments, will attempt to add the default signer per the rules laid out in 'Determining the Default Signer' above
  e.add_signer
  
  # Or pass a hash with signer data
  e.add_signer name: 'Bob', email: 'bob@example.org', embedded: false
  
  # Or, pass a block to add "tabs" to the document (see: "Defining Tabs" below for more information)
  e.add_signer do
    sign_at 'Your Name', 0, 0
    initial_at 'Initial Here', 100, 0
  end
end
```

### Defining Tabs

As of the time of this writing, the Docusign gem supports all defined [tabs](https://docs.docusign.com/esign/restapi/Envelopes/EnvelopeRecipientTabs/) in the Docusign api. Each method name is defined by the tab name followed by "_at" For example, "Date Signed" is defined at `date_signed_at`, "Envelope ID" is `envelope_id_at`. In the future, support for new tabs can be added just by manipulating the `Docusign.config.tabs` array in the config initializer. The array found there is what defines what methods are available for adding tabs.

For convenience, several shortcut methods have already been created for commonly used tabs, the details of which are:

| Tab Type        | Method Name / Alias         |
|-----------------|-----------------------------|
| Date Signed     | date_signed_at / signed_at  |
| Full Name Input | full_name_at / fullname_at  |
| Radio Button    | radio_group_at / radio_at   |
| Initial         | inital_here_at / initial_at |
| Signature       | sign_here_at / sign_at      |

For each tabs *_at method the arguments are the same. The first is a unique string of text to place the tab at (the anchor), the second is the offset X coordinate from that anchor position, the third is the Y offset from that anchor position, and the fourth is an optional hash of additonal parameters supported by docusign_rest (see the [get_tabs](https://github.com/jondkinney/docusign_rest/blob/master/lib/docusign_rest/client.rb#L465-L523) method for details on what parameters are supported)

All of the first 3 arguments are in fact optional, so it is easy to omit them altogether and go straight to the additional parameters just by providing a hash. The first 3 arguments are just separate since they are likely to be the most often used. So basically:

```ruby
@user.envelopes.create(email_subject: 'New Document') do |e|
  e.add_signer name: 'Bob Smith', email: 'bob@example.org' do
    # Relative text, x offset, y offset
    sign_at 'Your Name', 0, 0

    # OR ...

    # Just define a hash of parameters if you have no need for "relative" positioning
    sign_at x_position: 275, y_position: 2542, tab_label: 'Sign Here'
  end
end
```

### Embedding a Document for Signing

Once a document has been created, it can be embedded in an iframe by using the included helper method:

```ruby
# Where @envelope is an instance of Docusign::Document
<%= embedded_document(@envelope, width: 1000, height: 1200) %>
# Or, to have a specific signer sign the document, provide the instance of a specific signer as the second argument
<%= embedded_document(@envelope, @signer, width: 1000, height: 1200) %>
```

Where the first argument is the document you want to embded, the optional second argument is the signer (instance of `Docusign::Signer`) you want to sign the document, and the optional last argument is a hash of html options for the iframe (i.e. - width, height, class, style, etc...)

If you prefer to not embed the document, you can retrieve the url of the signing page by calling the documents `url` method

```ruby
<%= @envelope.url %>
# Or, to have a specific signer sign the document, provide the instance of the specific signer
<%= @envelope.url(signer) %>
```

Note that by default, calling `url` on the envelope should default to signing as the next eligible signer in the routing order. When a signer completes signing, it will update their status and cause the next call to `url` to choose the next eligible signer, if any.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ehainer/docusign. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.en.html).

