# ExTeal

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `teal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_teal, "~> 0.1.0"}
  ]
end
```

ExTeal will be a beautiful administration dashboard written for Phoenix Apps built
by Motel.  Of course, the primary feature of ExTeal is the ability to administrate
your data using Ecto Schema and queries.  ExTeal acomplishes this by allowing you
to define a ExTeal "resource" that corresponds to each `Ecto` schema in your
application.

![1](/uploads/-/system/personal_snippet/3/ea1cd2604b99ffbad219ec21121455d1/1.png)

## Defining Resources

By default, ExTeal resources are stored in `/lib/{context_web}/resources` of your
application. You can generate a new resource using the `mix teal:resource` task:

```bash
mix teal:resource User
```

The most basic property of a resource is it's `schema` property.  This property
tells ExTeal which Ecto Schema the resource corresponds to:

```elixir
defmodule YourAppWeb.Resources.User do
  alias YourApp.Accounts.User

  def schema, do: User
end
```

Freshly created ExTeal resources only contain an `ID` field definition.
Don't worry, we'll add more fields to our resource soon.

## Registering Resources

Before resources are available within your ExTeal dashboard, they must first be registered with ExTeal. Resources are typically registered in your `lib/your_app_web/teal.ex` file. This file contains various configuration and bootstrapping code related to your ExTeal installation.

```elixir
defmodule YourAppWeb.ExTeal do
  alias YourAppWeb.Resources

  def resources, do: [
    Resources.User
  ]
end
```

Once your resources are registered with ExTeal, they will be available in the ExTeal sidebar:

## Eager Loading

If you routinely need to access a resource's relationships within your fields, it may be a good idea to add the relationship to the `with` function of your resource. This function instructs ExTeal to always eager load the listed relationships when retrieving the resource.

For example, if you access a `Post` resource's `user` relationship within the `Post` resource's `subtitle` method, you should add the `user` relationship to the `Post` resource's `with` function:


```elixir
defmodule YourAppWeb.Resources.Post do
  alias YourApp.Accounts.Post

  def with, do: [:user]
end
```

## Defining Fields

Each ExTeal resource contains a `fields` function. This function returns an array of fields, which generally extend the `ExTeal/Fields/Field` struct. ExTeal ships with a variety of fields out of the box, including fields for text inputs, booleans, dates, file uploads, Markdown, and more.

To add a field to a resource, we can simply add it to the resource's `fields` function:

```elixir
defmodule YourAppWeb.Resources.Post do
  alias YourApp.Accounts.Post
  alias ExTeal.Fields.{ID, Text}

  def fields, do: [
    ID.new() |> sortable(),
    Text.new(:name) |> sortable()
  ]
end
```

### Field Column Conventions

ExTeal will "humanize" the schema name of the field to determine the displayable name. However, if necessary, you may pass the displayable name as the second argument to the field's `new` method:

```elixir
Text.new(:name, "Full Name")
```

## Showing / Hiding Fields

Often, you will only want to display a field in certain situations. For example, there is typically no need to show a `Password` field on a resource index listing. Likewise, you may wish to only display a `Created At` field on the creation / update forms. ExTeal makes it a breeze to hide / show fields on certain screens.

The following functions may be used to show / hide fields based on the display context:

- `hideFromIndex`
- `hideFromDetail`
- `hideWhenCreating`
- `hideWhenUpdating`
- `onlyOnIndex`
- `onlyOnDetail`
- `onlyOnForms`
- `exceptOnForms`

You may chain any of these methods onto your field's definition in order to instruct Ecto where the field should be displayed:

```elixir
Text.new(:name) |> hideFromIndex()
```

## Field Panels

If your resource contains many fields, your resource "detail" screen can become crowded. For that reason, you may choose to break up groups of fields into their own "panels":

You may do this by creating a new `Panel` instance within the `fields` method of a resource. Each panel requires a name and an array of fields that belong to that panel:

```elixir
defmodule YourAppWeb.Resources.User do
  alias YourApp.Accounts.User
  alias ExTeal.Fields.{ID, Text}
  alias ExTeal.Panel

  def fields, do: [
    ID.new() |> sortable(),
    Panel.new('Address Information', fn() ->
      Text.new(:address_line_1, 'Address') |> hideFromIndex(),
      Text.new(:address_line_2) |> hideFromIndex(),
      Text.new(:city) |> hideFromIndex(),
      Text.new(:state) |> hideFromIndex(),
      Text.new(:zip, 'Postal Code') |> hideFromIndex(),
      Country.new(:country, 'Country') |> hideFromIndex(),
    end)
  ]
end
```

![panels](/uploads/-/system/personal_snippet/3/8a72a8c1da09f61a6e2703e8c666bf1b/panels.png)

## Sortable Fields

When attaching a field to a resource, you may use the `sortable` method to indicate that the resource index may be sorted by the given field:

```elixir
Text.new(:name) |> sortable()
```

## Field Types


> This portion of the documentation only discusses non-relationship fields.

ExTeal ships with a variety of field types. So, let's explore all of the available types and their options:

- [Avatar](#avatar-field)
- [Boolean](#boolean-field)
- [Code](#code-field)
- [Country](#country-field)
- [Date](#date-field)
- [DateTime](#date-time-field)
- [File](#file-field)
- [Gravatar](#gravatar-field)
- [ID](#id-field)
- [Image](#image-field)
- [Markdown](#markdown-field)
- [Number](#number-field)
- [Password](#password-field)
- [Place](#place-field)
- [Select](#select-field)
- [Status](#status-field)
- [Text](#text-field)
- [Textarea](#textarea-field)
- [Timezone](#timezone-field)
- [Trix](#trix-field)


# Relationships

In addition to the variety of fields we've already discussed, ExTeal has full support for all of Ecto's relationships. Once you add relationship fields to your Ecto schemas, you'll start to experience the full power of the ExTeal dashboard, as the resource detail screen will allow you to quickly view and search a resource's related models:

## HasOne

The `HasOne` field corresponds to a `has_one` Ecto relationship. For example, let's assume a `User` schema `has_one` `Address` schema. We may add the relationship to our `User` Ecto resource like so:

```elixir
HasOne.new(:address)
```

Like other types of ExTeal fields, you can pass in a second argument to change the display name of the relationship.

```elixir
HasOne.new(:address, "Shipping Address")
```

## HasMany

The `HasMany` field corresponds to a `has_many` ecto relationship. For example, let's assume a `User` schema `has_many` `Post` schemas. We may add the relationship to our `User` ExTeal resource like so:

```elixir
defmodule YourAppWeb.Resources.User do
  alias YourApp.Accounts.User
  alias YourApp.Content.Post
  alias ExTeal.Fields.{ID, HasMany}

  def fields, do: [
    ID.new() |> sortable(),
    HasMany.new(:posts)
  ]
end
```

![detail-relationships](/uploads/-/system/personal_snippet/3/dcc2432392f58df515a8a86177d90ba6/detail-relationships.png)

## BelongsTo

The `BelongsTo` field corresponds to a `belongs_to` Ecto relationship. For example, let's assume a `Post` model `belongs_to` a `User` model. We may add the relationship to our `Post` ExTeal resource like so:

```elixir
defmodule YourAppWeb.Resources.Post do
  alias YourApp.Accounts.User
  alias YourApp.Content.Post
  alias ExTeal.Fields.{ID, HasMany}

  def fields, do: [
    ID.new() |> sortable(),
    BelongsTo.new(:user)
  ]
end
```

#### Title Attributes

When a `BelongsTo` field is shown on a resource creation / update screen, a drop-down selection menu or search menu will display the "title" of the resource. For example, a `User` resource may use the `name` attribute as its title. Then, when the resource is shown in a `BelongsTo` selection menu, that attribute will be displayed:

![Belongs To Title](./img/belongs-to-title.png)

To customize the "title" attribute of a resource, you may define a `title` function on the resource class:

```elixir
def title, do: "name"
```

## ManyToMany

The `ManyToMany` field corresponds to a `many_to_many` Ecto relationship. For example, let's assume a `User` schema `many_to_many` `Role` schemas. We may add the relationship to our `User` ExTeal resource like so:

```elixir
defmodule YourAppWeb.Resources.User do
  alias YourApp.Accounts.{User,Role}
  alias ExTeal.Fields.{ID, ManyToMany}

  def fields, do: [
    ID.new() |> sortable(),
    ManyToMany.new(:role)
  ]
end
```

#### Pivot Fields

If your `ManyToMany` relationship interacts with additional "pivot" fields that are stored on the intermediate table of the many-to-many relationship, you may also attach those to your `ManyToMany` Ecto relationship. Once these fields are attached to the relationship field, they will be displayed on the related resource index.

For example, let's assume our `User` schema `many_to_many` `Role` schemas. On our `roles_users` intermediate table, let's imagine we have a `notes` field that contains some simple text notes about the relationship. We can attach this pivot field to the `BelongsToMany` field using the `fields` method:

```elixir
defmodule YourAppWeb.Resources.User do
  alias YourApp.Accounts.{User,Role}
  alias ExTeal.Fields.{ID, ManyToMany, Text}

  def fields, do: [
    ID.new() |> sortable(),
    ManyToMany.new(:role) |> fields(fn() ->
      return [
        Text.new(:notes)
      ]
    end)
  ]
end
```

## Actions

TBD

## Filters

TBD

## Lenses

TBD


