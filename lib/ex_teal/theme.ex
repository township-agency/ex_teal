defmodule ExTeal.Theme do
  @moduledoc """
  The Theme module provides functionality for engineers to customize the appearance of Teal by
  changing the colors used in the user interface.  The struct provides the default values,
  and can be overriden by providing a custom struct in the `ExTeal.Manifest` module.
  """
  @derive {Jason.Encoder, only: [:metric_colors]}
  defstruct transparent: "transparent",
            black: "#22292f",
            white: "white",
            white_50: "rgba(255, 255, 255, 0.5)",
            danger: "#F91E17",
            danger_dark: "#BB1611",
            success: "#2CD82E",
            success_dark: "#49B31C",
            warning: "#ffeb3b",
            info: "#03a9f4",
            primary_light: "#4DC6F3",
            primary: "#00ADEE",
            primary_dark: "#0082B3",
            primary_70: "rgba(64, 153, 222, 0.7)",
            primary_50: "rgba(64, 153, 222, 0.5)",
            primary_30: "rgba(64, 153, 222, 0.3)",
            primary_10: "rgba(64, 153, 222, 0.1)",
            secondary: "#f16522",
            secondary_10: "rgba(241, 101, 34, 0.1)",
            logo: "#252d37",
            sidebar_icon: "#b3c1d1",
            grey_20: "#F8F8F8",
            grey_30: "#E9E9E9",
            grey_40: "#eef1f4",
            grey_50: "#e3e7eb",
            grey_60: "#bacad6",
            grey_70: "#b3b9bf",
            grey_80: "#7c858e",
            grey_90: "#252d37",
            grey_90_half: "rgba(40, 54, 61, 0.5)",
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
      --transparent: #{theme.transparent};
      --black: #{theme.black};
      --white: #{theme.white};
      --white-50: #{theme.white_50};
      --danger: #{theme.danger};
      --danger-dark: #{theme.danger_dark};
      --success: #{theme.success};
      --success-dark: #{theme.success_dark};
      --warning: #{theme.warning};
      --info: #{theme.info};
      --primary-light: #{theme.primary_light};
      --primary: #{theme.primary};
      --primary-dark: #{theme.primary_dark};
      --primary-70: #{theme.primary_70};
      --primary-50: #{theme.primary_50};
      --primary-30: #{theme.primary_30};
      --primary-10: #{theme.primary_10};
      --secondary: #{theme.secondary};
      --secondary-10: #{theme.secondary_10};
      --logo: #{theme.logo};
      --sidebar-icon: #{theme.sidebar_icon};
      --grey-20: #{theme.grey_20};
      --grey-30: #{theme.grey_30};
      --grey-40: #{theme.grey_40};
      --grey-50: #{theme.grey_50};
      --grey-60: #{theme.grey_60};
      --grey-70: #{theme.grey_70};
      --grey-80: #{theme.grey_80};
      --grey-90: #{theme.grey_90};
      --grey-90-half: #{theme.grey_90_half};  
    """
end
