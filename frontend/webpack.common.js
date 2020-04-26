const { join, resolve } = require("path");
const HtmlWebPackPlugin = require("html-webpack-plugin");

console.log(`curent padh ${resolve(__dirname)}`);

module.exports = {
  entry: {
    app: [join(__dirname, "src", "index.js")]
  },
  output: {
    filename: "[name].bundle.js",
    path: resolve(__dirname, "dist"),
    publicPath: "/"
  },
  module: {
    rules: [
      { test: /\.html$/, use: ["html-loader"] },
      { test: /\.css$/, use: ["style-loader", "css-loader"] },
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: { loader: "babel-loader" }
      },
      {
        test: /\.jpe?g$|\.ico$|\.gif$|\.png$|\.svg$|\.woff$|\.ttf$|\.wav$|\.mp3$/,
        loader: "file-loader?name=[name].[ext]"
      }
    ]
  },
  plugins: [
    new HtmlWebPackPlugin({
      template: "./src/index.html",
      filename: "./index.html"
    })
  ]
};
