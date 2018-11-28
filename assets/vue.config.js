let path = require("path");
const PurgecssPlugin = require("purgecss-webpack-plugin");
const glob = require("glob-all");

class TailwindExtractor {
  static extract(content) {
    return content.match(/[A-z0-9-:/]+/g) || [];
  }
}

module.exports = {
  lintOnSave: undefined,
  outputDir: path.resolve(__dirname, "../priv/static/teal"),
  baseUrl: "teal",
  configureWebpack: () => {
    if (process.env.NODE_ENV !== "production") {
      return;
    }
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
  }
};
