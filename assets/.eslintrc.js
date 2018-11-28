module.exports = {
  root: true,

  env: {
    node: true,
    browser: true,
    es6: true
  },

  extends: ["plugin:vue/recommended", "@vue/prettier"],

  rules: {
    "no-console": "off",
    "no-debugger": "off"
  },

  parserOptions: {
    parser: "babel-eslint"
  },
  globals: {
    ExTeal: true,
    config: true
  }
};
