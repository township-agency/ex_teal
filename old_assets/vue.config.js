let path = require("path");
const PurgecssPlugin = require("purgecss-webpack-plugin");
const glob = require("glob-all");

class TailwindExtractor {
  static extract(content) {
    return content.match(/[A-z0-9-:/]+/g) || [];
  }
}

let base = {
  lintOnSave: undefined,
  outputDir: path.resolve(__dirname, "../priv/static/teal"),
  baseUrl: "http://localhost:8080/teal",
  filenameHashing: false,
  devServer: {
    headers: {
      "Access-Control-Allow-Origin": "*"
    },
    hot: true,
    proxy: "http://localhost:8080/teal"
  },
  chainWebpack: config => {
    config.plugins.delete("html");
    config.plugins.delete("preload");
    config.plugins.delete("prefetch");
  }
};

if (process.env.NODE_ENV === "production") {
  base.baseUrl = "/teal";
  base.configureWebpack = () => {
    return {
      plugins: [
        new PurgecssPlugin({
          paths: glob.sync([
            path.join(__dirname, "./**/*.html"),
            path.join(__dirname, "./src/**/*.vue"),
            path.join(__dirname, "./src/**/*.js"),
            path.join(__dirname, "./src/assets/css/*.css")
          ]),
          extractors: [
            {
              extractor: TailwindExtractor,
              extensions: ["html", "js", "vue", "css"]
            }
          ],
          whitelistPatterns: [/multiselect$/, /flatpickr-*/],
          whitelistPatternsChildren: [/multiselect$/, /flatpickr-*/]
        })
      ]
    };
  };
}

module.exports = base;
