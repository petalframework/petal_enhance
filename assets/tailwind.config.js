const colors = require("tailwindcss/colors");

const denim = {
  50: "#f5f9fa",
  100: "#e0f0fb",
  200: "#bcdef7",
  300: "#8dbdea",
  400: "#5d97da",
  500: "#4775cb",
  600: "#3b59b5",
  700: "#2f4392",
  800: "#212d68",
  900: "#131c42",
};

const orchid = {
  50: "#fff7fd",
  100: "#fbe0f7",
  200: "#f9bdf1",
  300: "#ec94ed",
  400: "#cc6edc",
  500: "#a753c3",
  600: "#8640a7",
  700: "#66308d",
  800: "#492273",
  900: "#301057",
};

module.exports = {
  content: [
    "../lib/*_web/**/*.*ex",
    "./js/**/*.js",
    "../deps/petal_components/**/*.*ex",
  ],
  theme: {
    extend: {
      colors: {
        primary: orchid,
        secondary: denim,
      },
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
    require("@tailwindcss/aspect-ratio"),
  ],
  darkMode: "class",
};
