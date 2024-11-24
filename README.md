# GuidedTour

A simple Stimulus controller and a helper that enables you to show a guided tour overlay on your website. It requires Bootstrap to be installed and have Popover loaded.

This gem comes with the npm package [@itsbede/guided-tour](https://www.npmjs.com/package/@itsbede/guided-tour) that is installed and included into your apps `app/javascript/controller/application.js` by running the installer.

## Requirements

- Rails >= 7.1
- stimulus-rails
- jsbundling-rails with esbuild
- Node.js & Yarn

## Installation

1. Add to your Gemfile:
    ```ruby
    gem 'guided_tour'
    ```
2. Run installer
    ```bash
      ./bin/rails guided_tour:install
    ```
   
## Usage
In your view
```html
<!-- this is the example markup of you page that you want to guide the user through -->
<ul>
  <li id="foo">Foo</li>
  <li id="bar">Bar</li>
  <li id="baz">Baz</li>
</ul>

<!-- this is the gems helper code --> 
<%= guide_through(t('home.guide')) %>

<!-- if you like to go hardcoded you can hand in the map directly -->
<%= guide_through(
    { foo: "This is explanation for the element with the html id foo",
      bar: "This is explanation for the element with the html id bar",
      baz: "This is explanation for the element with the html id baz" }
) %>
```

In your locale .yml
```yaml
# config/locales/en.yml
---
en:
  # ...
  home:
    guide:
      foo: This is explanation for the element with the html id foo
      bar: This is explanation for the element with the html id bar
      baz: This is explanation for the element with the html id baz
  # ...
```

## Customization

You can customize the header and the navigation buttons of the popover by defining this keys in your locale .yml

```yaml
en:
  guided-tour:
    next-btn-text: "Your custom Next button text"
    prev-btn-text: "Your custom Back button text"
    done-btn-text: "Your custom Done button text"
    step-line: "Step {{current}} of {{total}}"

de:
  guided-tour:
    next-btn-text: "Weiter"
    prev-btn-text: "Zurück"
    done-btn-text: "Fertig"
    step-line: "Erklärung {{current}} von {{total}}"
```

Make sure to include `{{current}}` and `{{total}}` in your `step-line` key to have the progress of the tour shown.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
