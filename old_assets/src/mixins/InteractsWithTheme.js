const colorArray = function (colors, count) {
  return [ ...Array(count).keys() ].map((index) => {
    return colors[index % colors.length];
  });
};

const hexToRgb = function (hex) {
  // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
  const shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
  hex = hex.replace(shorthandRegex, (m, r, g, b) => {
    return r + r + g + g + b + b;
  });

  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
};

export const InteractsWithTheme = {
  methods: {
    colorsForData (data_length) {
      const theme = window.ExTeal.config.theme;
      return colorArray(theme.metric_colors, data_length);
    },

    colorsForTrend (colors, type, index) {
      const selectedColor = colors[index];

      if (type == 'line') {
        const { r, g, b } = hexToRgb(selectedColor);
        return { borderColor: selectedColor, backgroundColor: `rgba(${r}, ${g}, ${b}, 0.7)` };
      }
      return { backgroundColor: selectedColor, borderColor: 'transparent' };
    }
  }
};
