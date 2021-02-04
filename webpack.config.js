const path = require('path');
const webpack = require('webpack');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'elm.js',
    path: path.resolve(__dirname, 'dist'),
  },
  module: {
    rules: [
    {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file-loader?name=[name].[ext]'
    },
    {
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: [
        // https://github.com/klazuka/elm-hot-webpack-loader
        { loader: 'elm-hot-webpack-loader' },
        // https://github.com/elm-community/elm-webpack-loader
        { loader: 'elm-webpack-loader',
          options: {
           cwd: __dirname + '/elm'
         }
        }
      ]
    },
    {
      test: /\.s[ac]ss$/i,
      use: [
        // Creates `style` nodes from JS strings
        'style-loader',
        // Translates CSS into CommonJS
        'css-loader',
        // Compiles Sass to CSS
        'sass-loader',
      ],
    },
    {
       test: /\.(png|svg|jpg|gif)$/,
       use: [
         'file-loader',
       ],
    },
    ]
  },

  // https://github.com/klazuka/example-elm-hot-webpack/blob/master/webpack.config.js
  plugins: [
      new webpack.HotModuleReplacementPlugin()
  ],
  mode: 'development',
  devServer: {
      host: "aurora.local",
      inline: true,
      hot: true,
      stats: 'errors-only',
      historyApiFallback: true
  }
};
