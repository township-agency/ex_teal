defmodule ExTeal.Theme do
  @moduledoc """
  The Theme module provides functionality for engineers to customize the appearance of Teal by
  changing the colors used in the user interface.  The struct provides the default values,
  and can be overriden by providing a custom struct in the `ExTeal.Manifest` module.
  """
  @derive {Jason.Encoder, only: [:metric_colors]}
  defstruct black: "#22292f",
            white: "white",
            danger: "#F91E17",
            danger_dark: "#BB1611",
            success: "#2CD82E",
            success_dark: "#49B31C",
            info: "#03a9f4",
            primary_light: "#4DC6F3",
            primary: "#00ADEE",
            primary_dark: "#0082B3",
            primary_30: "rgba(64, 153, 222, 0.3)",
            primary_10: "rgba(64, 153, 222, 0.1)",
            logo: "#252d37",
            sidebar_icon: "#b3c1d1",
            metric_colors: [
              "#3B3F73",
              "#4F5599",
              "#767FE6",
              "#838DFF",
              "#196758",
              "#228976",
              "#32CEB0",
              "#38E5C4",
              "#732221",
              "#992D2C",
              "#E64442",
              "#FF4B49",
              "#004E6B",
              "#00688F",
              "#009CD6",
              "#00ADEE",
              "#722748",
              "#98345F",
              "#E54E8F",
              "#FE579F",
              "#6C532F",
              "#8F6E3E",
              "#D7A65E",
              "#EFB868"
            ]

  def color_variables(%__MODULE__{} = theme),
    do: """
      --black: #{theme.black};
      --white: #{theme.white};
      --danger: #{theme.danger};
      --danger-dark: #{theme.danger_dark};
      --success: #{theme.success};
      --success-dark: #{theme.success_dark};
      --info: #{theme.info};
      --primary-light: #{theme.primary_light};
      --primary: #{theme.primary};
      --primary-dark: #{theme.primary_dark};
      --primary-30: #{theme.primary_30};
      --primary-10: #{theme.primary_10};
      --logo: #{theme.logo};
      --sidebar-icon: #{theme.sidebar_icon};
    """
end
