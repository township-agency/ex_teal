defmodule ExTeal.Brand do
  @moduledoc """
  The Brand module provides functionality for engineers to customize the appearance of Teal by
  changing the colors used in the user interface.  The struct provides the default values,
  and can be overriden by providing a custom struct in the `ExTeal.Manifest` module.


  ## Logos

  You can customize the logo used in the sidebar by either providing a URL to the SVG Icons.  Teal renders:

  - `logo_icon_light` - The logo used in the sidebar.  This should be a square icon, and will be rendered at 40px x 40px on light backgrounds.
  - `logo_icon_dark` - The logo used in the sidebar.  This should be a square icon, and will be rendered at 40px x 40px on dark backgrounds.
  - `logo_light` - The logo used in the header.  This should be a horizontal logo, and will be rendered at 160px x 40px on light backgrounds.
  - `logo_dark` - The logo used in the header.  This should be a horizontal logo, and will be rendered at 160px x 40px on dark backgrounds.

  We're working on a Figma file that will provide instructions on how to generate these files for your own logo.

      defmodule MyAppWeb.ExTeal.Brand do
        use ExTeal.Brand

        @impl true
        def title, do: "My Cool App"

        @impl true
        def
      end
  """
end
