[![Coverage Status](https://coveralls.io/repos/github/ehainer/docusign/badge.svg?branch=master)](https://coveralls.io/github/ehainer/docusign?branch=master)
[![Build Status](https://travis-ci.org/ehainer/docusign.svg?branch=master)](https://travis-ci.org/ehainer/docusign)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

# Docusign

Trying to simplify the Docusign process with the help of the [docusign_rest](https://github.com/jondkinney/docusign_rest) gem.

<span color="red">**Note:** This gem is used on a different project and will likely only ever be updated as needed to support that project... unless I happen to become overcome with boredom and decide to implement a bunch more features.</span>

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

On any model you want to treat as a "signer" of a document, add `documentable` to create an association to documents:

```ruby
class User < ApplicationRecord

  documentable

end
```

With the new `documents` association you can now create embeddable Docusign documents with signers (among other things), like so:

```ruby
@user = User.first
# Subject is a required field, body is not. Both parameters translate to the email subject/body of the delivered document
@user.documents.create(subject: 'New Document', body: 'Welcome to your new document')
```

### Determining the Default Signer

By default, the signer will try to be obtained via one of two methods. First, it will look for a method on the documentable association named `to_signer`. This method, if defined should return a hash containing at least 4 keys: `name`, `email`, `role_name`, and `embedded`.

If the `to_signer` method is not found, it will then try to call the `name` and `email` methods of the documentable association to obtain each. The default role_name is `Issuer` and the default embedded parameter is `true`, and 99% of the time should be fine.

If the name or email could not be determined, the document will fail to save, and therefore not be created within Docusign. The resulting errors will be found on `<document>.errors`

### Customizing the Document

Optionally, you can pass a block to either the `create` or `build` method of documents, and use the document argument passed to it to further tailor the document to your needs.

```ruby
@user = User.first
@user.documents.create(subject: 'New Document') do |d|
  # Define the file you want to use as the document to sign.
  # You can provide as many file paths as you'd like in this method, or call it multiple times
  d.add_file '/path/to/the/pdf/document.pdf'
  
  # Without arguments, will attempt to add the default signer per the rules laid out in 'Determining the Default Signer' above
  d.add_signer
  
  # Or pass a hash with signer data
  d.add_signer name: 'Bob', email: 'bob@example.org', embedded: false
  
  # Or, pass a block to add "tabs" to the document (see: "Defining Tabs" below for more information)
  d.add_signer do
    sign_at 'Your Name', 0, 0
    initial_at 'Initial Here', 100, 0
  end
end
```

### Defining Tabs

While Docusign itself does support a huge variety of [tabs](https://docs.docusign.com/esign/restapi/Envelopes/EnvelopeRecipientTabs/), the `docusign_rest` gem that this depends on, does not. As of the writing of this readme, this gem supports defining tabs that `docusign_rest` supports. The full list, including the method used to create each is:

| Tab Type        | Method Name                 |
|-----------------|-----------------------------|
| Text Input      | text_at                     |
| Check box       | checkbox_at                 |
| Number Input    | number_at                   |
| Date Input      | date_at                     |
| Date Signed     | date_signed_at / signed_at  |
| Email Input     | email_at                    |
| Full Name Input | full_name_at / fullname_at  |
| List            | list_at                     |
| Radio Button    | radio_group_at / radio_at   |
| Initial         | inital_here_at / initial_at |
| Signature       | sign_here_at / sign_at      |
| Title           | title_at                    |

For each tabs *_at method the arguments are the same. The first is a unique string of text to place the tab at (the anchor), the second is the offset X coordinate from that anchor position, the third is the Y offset from that anchor position, and the fourth is an optional hash of additonal parameters supported by docusign_rest (see the [get_tabs](https://github.com/jondkinney/docusign_rest/blob/master/lib/docusign_rest/client.rb#L465-L523) method for details on what parameters are supported)

### Embedding a Document for Signing

Once a document has been created, it can be embedded in an iframe by using the included helper method:

```ruby
# Where @document is an instance of Docusign::Document
<%= embedded_document(@document, width: 1000, height: 1200) %>
# Or, to have a specific signer sign the document, provide the name and email of the recipient
<%= embedded_document(@document, 'Bob Smith', 'bob@example.org', width: 1000, height: 1200) %>
```

Where the first argument is the document you want to embded, the optional second and third arguments are the name/email of the signer you want to sign the document, and the optional last argument is a hash of html options for the iframe (i.e. - width, height, class, style, etc...)

If you prefer to not embed the document, you can retrieve the url of the signing page by calling the documents `url` method

```ruby
<%= @document.url %>
# Or, to have a specific signer sign the document, provide the name and email of the recipient
<%= @document.url('Bob Smith', 'bob@example.org') %>
```

The `url` method also accepts an optional third argument that's useful when not embedding, the return url for Docusign to redirect to after the user completes/declines/cancels the document. Docusign will redirect to that page with an `event` query string parameter representing the resulting user action (signing_complete, decline, cancel)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ehainer/docusign. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.en.html).

