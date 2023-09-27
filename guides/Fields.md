# Fields

## Defining Fields

Each Teal resource contains a `fields/0` callback.  This function should return an array of fields, which
generally are built upon the `ExTeal.Field` struct.  Teal ships with a variety of fields, including fields
for text inputs, booleans, dates, rich text, and more.

To add a field to a resource, simple add it to the resources `fields/0`
function.  Typically, fields are created using their `make/2` function.  Teal
generally expects that the first arugment is an atom representing the key on the
schema that Teal is representing, and the second is a human readable string that
is used as a label for the field:


```elixir
alias ExTeal.Fields.{Boolean, Text}

@impl true
def fields, do: [
  Boolean.make(:published),
  Text.make(:full_name, "User Name")
]
```

## Showing / Hiding Fields

Often, you will only want to display a field in certain situations.  For
example, there is typically no need to show a `Password` field on a resource
index listing.  Likewise, you may wish to only display a `Inserted At` timestamp
on the create / update forms.  Teal makes it a breeze to hide / show fields on
certain pages.

The following methods are imported to each module that uses `ExTeal.Resource`
and are contained in `ExTeal.FieldVisibility`:

* `show_on_index/1`
* `hide_from_index/1`
* `hide_from_detail/1`
* `hide_when_updating/1`
* `hide_when_creating/1`
* `only_on_details/1`
* `only_on_forms/1`
* `only_on_index/1`
* `except_on_forms/1`

You can pipe these functions onto any field `make` definition to instruct Teal
where the field should be displayed:

```elixir
Text.make(:full_name) |> hide_from_index()
```

## Embedded Fields

Teal has support for managing data represented on your schemas as both
`embeds_one` and `embeds_many` embedded schemas:

```elixir
defmodule YourAppWeb.ExTeal.PostResource do
  use ExTeal.Resource

  alias ExTeal.Fields.{EmbedsMany, Select, Text}

  @impl true
  def fields do
    [
      Text.make(:first_name),
      Text.make(:last_name),
      EmbedsMany.make(:mailing_addresses)
      |> EmbedsMany.fields([
        Text.make(:address_line_1),
        Text.make(:city),
        Select.make(:state) |> Select.options(states()),
        Text.make(:zip_code)
      ])
    ]
  end
end
```

Teal also supports nested `EmbedsMany` fields:

```elixir
alias ExTeal.Fields.{Boolean, EmbedsMany, Number, Text}

EmbedsMany.make(:line_items)
|> EmbedsMany.fields([
  Number.make(:quantity),
  Text.make(:item_name),
  EmbedsMany.make(:customizations)
  |> EmbedsMany.fields([
    Boolean.make(:validated),
    Number.make(:price)
  ])
])
```




