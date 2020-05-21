
module.exports = {
  purge: [
    './src/**/*.html',
    './src/**/*.vue',
  ],
  prefix: '',
  important: false,
  separator: ':',
  shadowLookup: true,
  theme: {
    colors: {
      transparent: 'transparent',
      black: '#000000',
      'grey-lightest': '#FAFAFA',
      'grey-lighter': '#EBEBEB',
      'grey-light': '#DBDBDB',
      grey: '#CCCCCC',
      'grey-dark': '#B8B8B8',
      'grey-darker': '#838383',
      'grey-darkest': '#3D3D3D',
      white: '#ffffff',
      primary: 'var(--primary)',
      'primary-dark': 'var(--primary-dark)',
      'primary-light': 'var(--primary-light)',
      'primary-10': 'var(--primary-10)',
      'primary-30': 'var(--primary-30)',
      'secondary-10': 'var(--secondary-10)',
      success: 'var(--success)',
      'success-dark': 'var(--success-dark)',
      danger: 'var(--danger)',
      'danger-dark': 'var(--danger-dark)',
      info: 'var(--info)',
      warning: 'var(--warning)',
      '90-half': 'var(--grey-90-half)',
      90: 'var(--grey-90)',
      80: 'var(--grey-80)',
      70: 'var(--grey-70)',
      60: 'var(--grey-60)',
      50: 'var(--grey-50)',
      40: 'var(--grey-40)',
      30: 'var(--grey-30)',
      20: 'var(--grey-20)'
    },
    fontFamily: {
      sans: [
        '-apple-system',
        'system-ui',
        'BlinkMacSystemFont',
        'Roboto',
        'Segoe UI',
        'Oxygen',
        'Ubuntu',
        'Cantarell',
        'Fira Sans',
        'Droid Sans',
        'Helvetica Neue',
        'sans-serif'
      ],
      serif: [
        'Constantia',
        'Lucida Bright',
        'Lucidabright',
        'Lucida Serif',
        'Lucida',
        'DejaVu Serif',
        'Bitstream Vera Serif',
        'Liberation Serif',
        'Georgia',
        'serif'
      ],
      mono: [
        'Menlo',
        'Monaco',
        'Consolas',
        'Liberation Mono',
        'Courier New',
        'monospace'
      ],
    },

    borderColor: theme => ({
      ...theme('colors'),
      default: theme('colors.grey-light', 'currentColor')
    }),

    shadows: {
      default: '0 2px 4px 0 rgba(0,0,0,0.10)',
      md: '0 4px 8px 0 rgba(0,0,0,0.12), 0 2px 4px 0 rgba(0,0,0,0.08)',
      lg: '0 15px 30px 0 rgba(0,0,0,0.11), 0 5px 15px 0 rgba(0,0,0,0.08)',
      inner: 'inset 0 2px 4px 0 rgba(0,0,0,0.06)',
    },

    extend: {
      width: {
        sidebar: '15rem',
        view: '3.125rem'
      },
      maxWidth: {
        sidebar: '15rem'
      },
  
      minHeight: {
        textarea: '8.5rem'
      },

      maxHeight: {
        '16': '8rem',
        '3/4': '75%'
      },
  
      margin: {
        sidebar: '15rem'
      },
      lineHeight: {
        '40': '40px'
      },
      inset: {
        '16': '4rem'
      }
    }    
  },

  variants: {
    accessibility: ['responsive', 'focus'],
    alignContent: ['responsive'],
    alignItems: ['responsive'],
    alignSelf: ['responsive'],
    appearance: ['responsive'],
    backgroundAttachment: ['responsive'],
    backgroundColor: ['responsive', 'hover', 'focus'],
    backgroundOpacity: ['responsive', 'hover', 'focus'],
    backgroundPosition: ['responsive'],
    backgroundRepeat: ['responsive'],
    backgroundSize: ['responsive'],
    borderCollapse: ['responsive'],
    borderColor: ['responsive', 'hover', 'focus'],
    borderOpacity: ['responsive', 'hover', 'focus'],
    borderRadius: ['responsive', 'group-hover'],
    borderStyle: ['responsive'],
    borderWidth: ['responsive'],
    boxShadow: ['responsive', 'hover', 'focus'],
    boxSizing: ['responsive'],
    cursor: ['responsive'],
    display: ['responsive', 'group-hover'],
    divideColor: ['responsive'],
    divideOpacity: ['responsive'],
    divideWidth: ['responsive'],
    fill: ['responsive'],
    flex: ['responsive'],
    flexDirection: ['responsive'],
    flexGrow: ['responsive'],
    flexShrink: ['responsive'],
    flexWrap: ['responsive'],
    float: ['responsive'],
    clear: ['responsive'],
    fontFamily: ['responsive'],
    fontSize: ['responsive'],
    fontSmoothing: ['responsive'],
    fontStyle: ['responsive'],
    fontWeight: ['responsive', 'hover', 'focus'],
    height: ['responsive'],
    inset: ['responsive'],
    justifyContent: ['responsive'],
    letterSpacing: ['responsive'],
    lineHeight: ['responsive'],
    listStylePosition: ['responsive'],
    listStyleType: ['responsive'],
    margin: ['responsive'],
    maxHeight: ['responsive'],
    maxWidth: ['responsive'],
    minHeight: ['responsive'],
    minWidth: ['responsive'],
    objectFit: ['responsive'],
    objectPosition: ['responsive'],
    opacity: ['responsive', 'hover', 'focus'],
    order: ['responsive'],
    outline: ['responsive', 'focus'],
    overflow: ['responsive'],
    padding: ['responsive'],
    placeholderColor: ['responsive', 'focus'],
    placeholderOpacity: ['responsive', 'focus'],
    pointerEvents: ['responsive'],
    position: ['responsive'],
    resize: ['responsive'],
    space: ['responsive'],
    stroke: ['responsive'],
    strokeWidth: ['responsive'],
    tableLayout: ['responsive'],
    textAlign: ['responsive'],
    textColor: ['responsive', 'hover', 'focus'],
    textOpacity: ['responsive', 'hover', 'focus'],
    textDecoration: ['responsive', 'hover', 'focus'],
    textTransform: ['responsive'],
    userSelect: ['responsive'],
    verticalAlign: ['responsive'],
    visibility: ['responsive'],
    whitespace: ['responsive'],
    width: ['responsive'],
    wordBreak: ['responsive'],
    zIndex: ['responsive'],
    gap: ['responsive'],
    gridAutoFlow: ['responsive'],
    gridTemplateColumns: ['responsive'],
    gridColumn: ['responsive'],
    gridColumnStart: ['responsive'],
    gridColumnEnd: ['responsive'],
    gridTemplateRows: ['responsive'],
    gridRow: ['responsive'],
    gridRowStart: ['responsive'],
    gridRowEnd: ['responsive'],
    transform: ['responsive'],
    transformOrigin: ['responsive'],
    scale: ['responsive', 'hover', 'focus'],
    rotate: ['responsive', 'hover', 'focus'],
    translate: ['responsive', 'hover', 'focus'],
    skew: ['responsive', 'hover', 'focus'],
    transitionProperty: ['responsive'],
    transitionTimingFunction: ['responsive'],
    transitionDuration: ['responsive'],
    transitionDelay: ['responsive']
  }
};
