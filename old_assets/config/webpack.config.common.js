'use strict';

const VueLoaderPlugin      = require('vue-loader/lib/plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const helpers              = require('./helpers');
const isDev                = process.env.NODE_ENV === 'development';

const webpackConfig = {
  entry: {
    polyfill: '@babel/polyfill',
    main: helpers.root('src', 'main'),
  },
  resolve: {
    extensions: [ '.js', '.vue' ],
    alias: {
      'vue$': isDev ? 'vue/dist/vue.runtime.js' : 'vue/dist/vue.runtime.min.js',
      '@': helpers.root('src')
    }
  },
  externals: {
    moment: 'moment'
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
        include: [ helpers.root('src') ]
      },
      {
        test: /\.js$/,
        loader: 'babel-loader',
        include: [ helpers.root('src') ]
      },
      {
        test: /\.css$/,
        use: [
          isDev ? 'vue-style-loader' : MiniCssExtractPlugin.loader,
          { loader: 'css-loader', options: { sourceMap: isDev, importLoaders: 1 } },
          'postcss-loader'
        ]
      },
    ]
  },
  plugins: [
    new VueLoaderPlugin(),
  ]
};

module.exports = webpackConfig;
